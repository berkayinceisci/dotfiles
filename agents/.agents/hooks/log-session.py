#!/usr/bin/env python3
"""Render a Claude Code session transcript (.jsonl) to a readable markdown log.

Two modes:
  * hook mode (default): reads the Stop-hook JSON payload on stdin and pulls
    `transcript_path` + `cwd` from it.
  * backfill mode: `--transcript PATH` names the .jsonl directly (no stdin),
    used to re-render historical sessions.

Output path mirrors Claude's own projects tree, with a readable title prefix:
    <CONFIG_DIR>/projects/<slug>/<session_id>.jsonl
        ->  <CONFIG_DIR>/my-session-logs/<slug>/<title-slug>__<session_id>.md
so the log tree is a 1:1 parallel of the transcript tree. Everything is derived
from the transcript path itself (not $CLAUDE_CONFIG_DIR), so it is correct no
matter which profile launched claude.

The whole session is re-rendered every call (idempotent, last-writer-wins via an
atomic replace) so a crash/kill after any completed turn still leaves a current
log — unlike the old wrapper, which only wrote on clean exit.
"""

import argparse
import glob
import json
import os
import re
import sys
import time


def log(msg, verbose):
    if verbose:
        print(f"[log-session] {msg}", file=sys.stderr)


def read_stdin_payload():
    """Hook mode: parse the JSON the Stop hook sends on stdin."""
    raw = sys.stdin.read()
    if not raw.strip():
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {}


def first_user_text(entries):
    """Extract the first real user message, for the log's H1 title."""
    for entry in entries:
        msg = entry.get("message", {})
        if msg.get("role") != "user":
            continue
        content = msg.get("content", "")
        text = ""
        if isinstance(content, str):
            text = content
        elif isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get("type") == "text":
                    text = c.get("text", "")
                    break
                if isinstance(c, str):
                    text = c
                    break
        text = text.strip()
        # Skip command/system envelope noise; want the first human line.
        if not text or text.startswith("<") or text.startswith("Caveat:"):
            continue
        first_line = text.splitlines()[0].strip()
        return first_line[:120]
    return ""


def ai_title(entries):
    """Claude's own auto-generated session title (the terminal `✳` title). It is
    emitted as repeated {"type":"ai-title","aiTitle":...} lines that refine over
    the session, so return the LAST (most current) one. Empty if none yet."""
    title = ""
    for entry in entries:
        if entry.get("type") == "ai-title":
            t = (entry.get("aiTitle") or "").strip()
            if t:
                title = t
    return title


def session_title(entries):
    """Best human-readable title: Claude's own ai-title if it has generated one,
    else the first human message."""
    return ai_title(entries) or first_user_text(entries)


def slugify(text, maxlen=60):
    """Filesystem-safe, readable slug of a title string (ascii, lowercase,
    dash-separated). Empty if there is nothing usable."""
    text = (text or "").lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return text[:maxlen].strip("-")


def load_entries(jsonl_path):
    entries = []
    with open(jsonl_path, "r", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return entries


def render_markdown(entries, session_id, slug, out):
    """Write the whole conversation as markdown to file object `out`."""
    title = session_title(entries) or session_id
    out.write(f"# {title}\n\n")
    out.write("| Field | Value |\n|-|-|\n")
    out.write(f"| Session | `{session_id}` |\n")
    out.write(f"| Project | `{slug}` |\n\n---\n\n")

    for entry in entries:
        etype = entry.get("type")
        if etype == "file-history-snapshot":
            continue
        # Claude compacts the LIVE context but keeps every message on disk; mark
        # where it happened so the reader knows why earlier detail may fade.
        if etype == "system" and entry.get("subtype") == "compact_boundary":
            out.write("---\n\n**⋯ context compacted here ⋯**\n\n---\n\n")
            continue
        msg = entry.get("message", {})
        role = msg.get("role", "")
        content = msg.get("content", "")

        if role == "user":
            if isinstance(content, str):
                if content.strip():
                    out.write(f"## User\n\n{content}\n\n")
            elif isinstance(content, list):
                for c in content:
                    if isinstance(c, dict) and c.get("type") == "text":
                        out.write(f"## User\n\n{c.get('text', '')}\n\n")
                    elif isinstance(c, str):
                        out.write(f"## User\n\n{c}\n\n")

        elif role == "assistant":
            if isinstance(content, list):
                for c in content:
                    if not isinstance(c, dict):
                        continue
                    ctype = c.get("type", "")
                    if ctype == "text":
                        text = c.get("text", "")
                        if text:
                            out.write(f"## Assistant\n\n{text}\n\n")
                    elif ctype == "thinking":
                        thinking = c.get("thinking", "")
                        if thinking:
                            out.write(f"## Assistant (Thinking)\n\n{thinking}\n\n")
                    elif ctype == "tool_use":
                        tool = c.get("name", "unknown")
                        inp = c.get("input", {})
                        out.write(f"## Assistant (Tool: {tool})\n\n")
                        if tool in ("Read", "Glob", "Grep"):
                            path = inp.get("file_path", inp.get("path", inp.get("pattern", "")))
                            out.write(f"Reading/searching: `{path}`\n\n")
                        elif tool == "Edit":
                            out.write(f"Editing: `{inp.get('file_path', '')}`\n\n")
                        elif tool == "Write":
                            out.write(f"Writing: `{inp.get('file_path', '')}`\n\n")
                        elif tool == "Bash":
                            cmd = str(inp.get("command", ""))[:200]
                            out.write(f"```bash\n{cmd}\n```\n\n")
                        else:
                            out.write(f"Input: {str(inp)[:200]}...\n\n")
            elif isinstance(content, str) and content:
                out.write(f"## Assistant\n\n{content}\n\n")

    out.write("---\n")


def ensure_symlink(cwd, target_dir, name, verbose):
    """Create/refresh `<cwd>/<name>` -> target_dir, but never clobber a real
    file/dir the user owns (only (re)point an existing symlink or a missing
    entry)."""
    link = os.path.join(cwd, name)
    if os.path.islink(link):
        try:
            if os.readlink(link) == target_dir:
                return
            os.unlink(link)
        except OSError as exc:
            log(f"symlink refresh failed: {exc}", verbose)
            return
    elif os.path.exists(link):
        # A real (non-symlink) cc-sessions exists — leave it alone.
        log(f"{link} exists and is not a symlink; skipping", verbose)
        return
    try:
        os.symlink(target_dir, link)
        log(f"symlink {link} -> {target_dir}", verbose)
    except OSError as exc:
        log(f"symlink create failed: {exc}", verbose)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--transcript", help="backfill mode: path to a .jsonl")
    ap.add_argument("--cwd", help="working dir for the cc-sessions symlink")
    ap.add_argument("--no-symlink", action="store_true",
                    help="do not create the in-repo cc-sessions symlink")
    ap.add_argument("--link-name", default="cc-sessions",
                    help="name of the in-repo directory symlink")
    ap.add_argument("--delay", type=float, default=0.0,
                    help="sleep this many seconds before reading the transcript "
                         "(lets Claude flush the turn's final message first)")
    ap.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()

    # When run from the Stop hook, the assistant's final message may not be
    # flushed to the transcript yet; a short delay lets it land before we read.
    if args.delay > 0:
        time.sleep(args.delay)

    if args.transcript:
        transcript = args.transcript
        cwd = args.cwd
    else:
        payload = read_stdin_payload()
        transcript = payload.get("transcript_path", "")
        cwd = payload.get("cwd", "")

    if not transcript or not os.path.isfile(transcript):
        log(f"no usable transcript ({transcript!r}); nothing to do", args.verbose)
        return 0

    # <CONFIG>/projects/<slug>/<id>.jsonl  ->  parts we need
    transcript = os.path.realpath(transcript)
    slug_dir = os.path.dirname(transcript)                 # <CONFIG>/projects/<slug>
    slug = os.path.basename(slug_dir)
    config_dir = os.path.dirname(os.path.dirname(slug_dir))  # <CONFIG>
    session_id = os.path.splitext(os.path.basename(transcript))[0]

    # Only real top-level sessions are UUID-named. Skip subagent sidecars
    # (agent-*.jsonl), workflow journals (journal.jsonl), and anything else that
    # isn't a session transcript (they live deeper in the projects tree and
    # would otherwise mis-derive the config dir).
    if not re.match(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
                    session_id):
        log(f"skipping non-session transcript {session_id}", args.verbose)
        return 0

    out_dir = os.path.join(config_dir, "my-session-logs", slug)
    os.makedirs(out_dir, exist_ok=True)

    entries = load_entries(transcript)
    if not entries:
        log("transcript parsed to zero entries; skipping", args.verbose)
        return 0

    # Name the log by Claude's own ai-title (falling back to the first human
    # message), plus the session_id (unique, keeps the 1:1 map to the
    # transcript). Falls back to id-only for sessions with no title yet.
    title_slug = slugify(session_title(entries))
    name = f"{title_slug}__{session_id}.md" if title_slug else f"{session_id}.md"
    out_file = os.path.join(out_dir, name)

    # The title is stable across turns, so this path is stable. But remove any
    # OTHER file for this same session_id — an old id-only name from before this
    # scheme, or a stale title — so there is exactly one .md per session.
    for stale in glob.glob(os.path.join(out_dir, f"*{session_id}.md")):
        if os.path.basename(stale) != name:
            try:
                os.remove(stale)
            except OSError:
                pass

    # Atomic write so a concurrent reader never sees a half-rendered file.
    tmp = out_file + f".tmp.{os.getpid()}"
    with open(tmp, "w") as out:
        render_markdown(entries, session_id, slug, out)
    os.replace(tmp, out_file)
    log(f"wrote {out_file} ({len(entries)} entries)", args.verbose)

    if cwd and not args.no_symlink and os.path.isdir(cwd):
        ensure_symlink(cwd, out_dir, args.link_name, args.verbose)

    return 0


if __name__ == "__main__":
    sys.exit(main())

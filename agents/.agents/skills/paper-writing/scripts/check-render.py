#!/usr/bin/env python3
"""check-render.py: verify that the .tex sources reach the PDF.

Strips LaTeX comments and markup from each section source, splits the
text into segments at commands, math, table cells and environments, and
checks that every run of N consecutive words in a segment appears in
the pdftotext output. A missing run means text was commented out,
swallowed by a macro, or lost in an edit. Build the PDF first.

A run that a column or page break splits 2+2, with float captions or
headings in between, is bridged and not reported; its neighbours are
accepted through it. Runs that remain reported are either real losses
or breaks the bridge could not cover (a hyphenated word split across a
page, a figure's own text longer than WINDOW words between the halves):
read each one against the PDF before dismissing it. A reported run of
the form "<last word before> the <first words of a sentence>" is the
signature of a sentence swallowed by a comment or a macro.

Usage: check-render.py [-v] [-n N] <doc-dir> [section.tex ...]
"""
import re, subprocess, sys, pathlib

WINDOW = 600   # words a column or page break may insert between the halves of a run (a table page can be long)

def norm_words(text, pdf=False):
    text = text.replace("\u00ad", "")
    if pdf:
        text = re.sub(r"-\s*\n\s*", "", text)        # words hyphenated at line or page ends
    text = re.sub(r"[\u2018\u2019\u201c\u201d`']", "", text)
    text = text.replace("\u03bc", "u").replace("\u00b5", "u")
    text = text.replace("-", "").replace("\u2013", "").replace("\u2014", "")
    return [w.lower() for w in re.findall(r"[A-Za-z0-9]+(?:\.[0-9]+)?", text)]

def source_segments(tex):
    lines = []
    for line in tex.split("\n"):
        line = re.sub(r"^%.*$", "", line)
        line = re.sub(r"(?<!\\)%.*$", "", line)
        lines.append(line)
    s = "\n".join(lines)
    s = re.sub(r"\\begin\{(tabular|table|figure|tikzpicture)\*?\}.*?\\end\{\1\*?\}", " ", s, flags=re.S)
    s = s.replace("~", " ").replace("\\,", " ").replace("\\ ", " ")
    s = s.replace("\\%", "%").replace("\\&", "&").replace("\\_", "_")
    s = re.sub(r"\\(emph|textbf|texttt|textit|mysub|hypoc)\b", "", s)
    s = re.sub(r"(\\ref\{[^}]*\})([a-z])\b", r"\1", s)   # subfigure letter after a \ref
    parts = re.split(r"\\[A-Za-z@]+\*?(?:\[[^\]]*\])?(?:\{[^{}]*\})*|\$[^$]*\$|\\\[.*?\\\]|[{}&]|\\\\", s, flags=re.S)
    return parts

def main():
    args = sys.argv[1:]
    verbose = False; n = 4
    while args and args[0].startswith("-"):
        a = args.pop(0)
        if a == "-v": verbose = True
        elif a == "-n": n = int(args.pop(0))
    docdir = pathlib.Path(args.pop(0))
    pdf = docdir / "main.pdf"
    if args:
        files = [docdir / f for f in args]
    else:
        main_tex = (docdir / "main.tex").read_text()
        names = re.findall(r"^\\input\{([a-z-]+)\}", main_tex, flags=re.M)
        files = [docdir / f"{x}.tex" for x in names
                 if not re.match(r"^(z-|macros|title|bib|todo)", x)]
    # pdftotext in default mode mostly follows the two columns, but pages
    # with floats can interleave; the left and right half-page extracts
    # cover those cases. A run passes if any extraction contains it.
    info = subprocess.run(["pdfinfo", str(pdf)], capture_output=True, text=True, check=True).stdout
    m = re.search(r"Page size:\s+([\d.]+) x ([\d.]+)", info)
    w, h = (float(m.group(1)), float(m.group(2))) if m else (612.0, 792.0)
    def extract(*opts):
        t = subprocess.run(["pdftotext", *opts, str(pdf), "-"], capture_output=True, text=True, check=True).stdout
        t = re.sub(r"^\s*\d+(\.\d+)*\s*$", "", t, flags=re.M)   # page and stray section numbers
        return " " + " ".join(norm_words(t, pdf=True)) + " "
    half = str(int(w / 2))
    texts = [extract(), extract("-x", "0", "-y", "0", "-W", half, "-H", str(int(h))),
             extract("-x", half, "-y", "0", "-W", half, "-H", str(int(h)))]
    pdf_joined = "\n".join(texts)
    pdf_lists = [t.split() for t in texts]

    def bridged(words):
        """True if the run is split 2+2 by a column or page break: its
        first two words end somewhere and its last two words start within
        the next WINDOW words of some extraction (float captions, headings
        and page furniture sit in between)."""
        head, tail = words[:2], words[2:]
        for lst in pdf_lists:
            for i in range(len(lst) - 1):
                if lst[i:i+2] == head:
                    window = lst[i+2:i+2+WINDOW]
                    for j in range(len(window) - len(tail) + 1):
                        if window[j:j+len(tail)] == tail:
                            return True
        return False

    missing = 0
    for f in files:
        if not f.exists():
            continue
        for seg in source_segments(f.read_text()):
            words = norm_words(seg)
            runs = [words[i:i+n] for i in range(0, max(0, len(words) - n + 1))]
            found = [f" {' '.join(r)} " in pdf_joined for r in runs]
            # a break between two words leaves up to n-1 consecutive runs
            # unfound; the one split 2+2 bridges, and its neighbours are
            # accepted through it. A dropped word or phrase has no bridged
            # run near it, because every 2+2 split then has an absent half.
            br = [False if ok else bridged(r) for r, ok in zip(runs, found)]
            for i, r in enumerate(runs):
                if found[i]:
                    continue
                if br[i] or (i > 0 and br[i-1]) or (i + 1 < len(runs) and br[i+1]):
                    if verbose:
                        print(f"{f.name}: bridged across a break: '{' '.join(r)}'", file=sys.stderr)
                    continue
                print(f"{f.name}: not in PDF: '{' '.join(r)}'")
                missing += 1
        if verbose:
            print(f"[check-render] {f.name}: checked", file=sys.stderr)
    print(f"== {missing} missing run(s) of {n} words across {len(files)} file(s)")
    sys.exit(1 if missing else 0)

if __name__ == "__main__":
    main()

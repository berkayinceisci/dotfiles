#!/usr/bin/env python3
# Parse free-text task input into TickTick API fields.
# Input: argv[1] or stdin.  Output: JSON {"title", "dueDate", "isAllDay"}.

import json
import re
import sys


def _fallback(text):
    return {"title": text.strip(), "dueDate": None, "isAllDay": False}


def parse(text):
    text = text.strip()
    if not text:
        return _fallback(text)

    try:
        from dateparser.search import search_dates
    except ImportError:
        return _fallback(text)

    try:
        matches = search_dates(
            text,
            languages=["en"],
            settings={
                "PREFER_DATES_FROM": "future",
                "RETURN_AS_TIMEZONE_AWARE": True,
            },
        )
    except Exception:
        matches = None
    if not matches:
        return _fallback(text)

    # Task date phrases are usually trailing; take the last match.
    phrase, dt = matches[-1]

    time_re = re.compile(
        r"(\b\d{1,2}:\d{2}\b|\b\d{1,2}\s*(am|pm)\b|\bnoon\b|\bmidnight\b|\bat\s+\d)",
        re.IGNORECASE,
    )
    is_all_day = not bool(time_re.search(phrase))

    title = re.sub(re.escape(phrase), "", text, count=1, flags=re.IGNORECASE)
    title = re.sub(r"\s+", " ", title).strip()
    title = re.sub(r"^(on|by|at|next|this)\s+", "", title, flags=re.IGNORECASE)
    title = re.sub(r"\s+(on|by|at|next|this)$", "", title, flags=re.IGNORECASE).strip()
    if not title:
        title = text

    if dt.tzinfo is None:
        dt = dt.astimezone()
    if is_all_day:
        dt = dt.replace(hour=0, minute=0, second=0, microsecond=0)

    return {
        "title": title,
        "dueDate": dt.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "isAllDay": is_all_day,
    }


if __name__ == "__main__":
    text = sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()
    print(json.dumps(parse(text)))

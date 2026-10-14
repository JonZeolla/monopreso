#!/usr/bin/env python3
"""Build a GitHub contribution-calendar SVG for the "about me" slide.

Usage: github_activity.py [--login jonzeolla] [--out modules/shared/generated/github-activity.svg]

Run by start.sh on every `task start`. The output is gitignored. If the fetch
fails and an earlier file exists, that file is kept; if neither exists the slide
renders nothing, because an empty calendar on a projector reads as "this person
does not code".
"""

import argparse
import datetime as dt
import json
import re
import sys
import urllib.request
from pathlib import Path

API = "https://github-contributions-api.jogruber.de/v4/{login}?y=last"
# Cell fill by contribution level 0..4, tuned for the dark slide ground.
LEVELS = ["#243247", "#2b4a73", "#3a68a8", "#4f8fe0", "#5aa9ff"]
MUTED, INK = "#8b98ab", "#c9d1d9"
CELL, GAP, LEFT, TOP = 14, 4, 64, 56
MONTHS = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
]


def fetch(login):
    with urllib.request.urlopen(API.format(login=login), timeout=15) as res:
        return json.load(res)


def build(login, data):
    days = data["contributions"]
    total = data["total"]["lastYear"]
    first = dt.date.fromisoformat(days[0]["date"])
    offset = (first.weekday() + 1) % 7  # Sunday-first rows
    pitch = CELL + GAP
    weeks = (offset + len(days) + 6) // 7
    width, height = LEFT + weeks * pitch + 8, TOP + 7 * pitch + 12
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="100%" '
        f'role="img" aria-label="github.com/{login}: {total:,} contributions in the last year" '
        'font-family="ui-monospace,SFMono-Regular,Menlo,monospace">',
        f'<text x="0" y="18" fill="{INK}" font-size="16">github.com/{login}</text>',
        f'<text x="{width}" y="18" fill="{INK}" font-size="16" text-anchor="end">'
        f"{total:,} contributions in the last year</text>",
    ]
    last_month = None
    for i, day in enumerate(days):
        d = dt.date.fromisoformat(day["date"])
        col, row = (offset + i) // 7, (offset + i) % 7
        x, y = LEFT + col * pitch, TOP + row * pitch
        if d.month != last_month and (row == 0 or i == 0 or d.day <= 7):
            last_month = d.month
            out.append(
                f'<text x="{x}" y="{TOP - 12}" fill="{MUTED}" font-size="12">{MONTHS[d.month - 1]}</text>'
            )
        level = max(0, min(4, int(day.get("level", 0))))
        out.append(
            f'<rect x="{x}" y="{y}" width="{CELL}" height="{CELL}" rx="3" fill="{LEVELS[level]}" '
            f'data-date="{day["date"]}" data-count="{int(day["count"])}"/>'
        )
    for row, name in ((1, "Mon"), (3, "Wed"), (5, "Fri")):
        out.append(
            f'<text x="0" y="{TOP + row * pitch + 11}" fill="{MUTED}" font-size="12">{name}</text>'
        )
    out.append("</svg>")
    svg = "\n".join(out)
    if re.search(r"<script|javascript:|\bon\w+=", svg, re.I):
        raise ValueError("refusing to emit SVG with script-like content")
    return svg


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--login", default="jonzeolla")
    ap.add_argument("--out", default="modules/shared/generated/github-activity.svg")
    args = ap.parse_args()
    if not re.fullmatch(r"[A-Za-z\d](?:[A-Za-z\d]|-(?=[A-Za-z\d])){0,38}", args.login):
        sys.exit(f"invalid login: {args.login}")
    out = Path(args.out)
    try:
        svg = build(args.login, fetch(args.login))
    except Exception as err:  # network down, API change: never block `task start`
        print(
            f"[github-activity] {err}; "
            + ("keeping existing file" if out.exists() else "no calendar"),
            file=sys.stderr,
        )
        return
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(svg + "\n")


if __name__ == "__main__":
    main()

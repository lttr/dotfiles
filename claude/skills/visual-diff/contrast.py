#!/usr/bin/env python3
"""Check a report's palette against WCAG AA.

    python3 contrast.py report.html

Parses the light `:root {}` and the dark `@media (prefers-color-scheme: dark)` block,
then checks every pair the layout actually puts together: 4.5:1 for text, 3:1 for
diagram strokes and other graphical objects. Exits non-zero if anything fails.
"""
import re, sys

PAIRS = [  # (fg token, bg token, minimum ratio)
    ("fg", "bg", 4.5), ("fg", "card", 4.5),
    ("muted", "bg", 4.5), ("muted", "card", 4.5), ("muted", "tint", 4.5),
    ("add", "bg", 4.5), ("add", "card", 4.5),
    ("del", "bg", 4.5), ("del", "card", 4.5),
    ("accent", "bg", 4.5), ("accent", "card", 4.5),
    ("diagram-fg", "diagram-bg", 4.5),
    ("diagram-fg", "add-fill", 4.5), ("diagram-fg", "del-fill", 4.5),
    ("diagram-fg", "accent-fill", 4.5),
    ("add", "diagram-bg", 3.0), ("del", "diagram-bg", 3.0), ("accent", "diagram-bg", 3.0),
    ("add", "add-fill", 3.0), ("del", "del-fill", 3.0), ("accent", "accent-fill", 3.0),
]

def lum(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    ch = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (f(c) for c in ch)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def ratio(a, b):
    l1, l2 = sorted((lum(a), lum(b)), reverse=True)
    return (l1 + 0.05) / (l2 + 0.05)

def tokens(css):
    return dict(re.findall(r"--([a-z-]+):\s*(#[0-9a-fA-F]{3,6})\b", css))

css = open(sys.argv[1]).read()
light = tokens(re.search(r":root \{(.*?)\}", css, re.S).group(1))
dark = dict(light)
dark.update(tokens(re.search(r"prefers-color-scheme: dark.*?:root \{(.*?)\}", css, re.S).group(1)))

bad = 0
for mode, t in (("light", light), ("dark", dark)):
    print(f"== {mode}")
    for fg, bg, need in PAIRS:
        if fg not in t or bg not in t:
            continue
        v = ratio(t[fg], t[bg])
        ok = v >= need
        bad += not ok
        print(f"  {'OK  ' if ok else 'FAIL'} {fg}/{bg:16s} {v:5.2f}  (need {need})")
print("\nAA clean" if not bad else f"\n{bad} failing pair(s)")
sys.exit(1 if bad else 0)

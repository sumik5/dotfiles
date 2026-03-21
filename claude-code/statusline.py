#!/usr/bin/env python3
"""Pattern 5: Braille dots - dotted progress bar using braille characters"""
import json, os, sys, time

data = json.load(sys.stdin)

BRAILLE = ' ⣀⣄⣤⣦⣶⣷⣿'
R = '\033[0m'
DIM = '\033[2m'

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def braille_bar(pct, width=5):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ''
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar

def fmt(label, pct):
    p = round(pct)
    return f'{DIM}{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {p}%'

model = data.get('model', {}).get('display_name', 'Claude')
model = model.replace(' context)', ')').replace(' (', '(')
parts = [model]

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('ctx', ctx))

five_hour = data.get('rate_limits', {}).get('five_hour', {})
five = five_hour.get('used_percentage')
if five is not None:
    resets_at = five_hour.get('resets_at')
    now = time.time()
    suffix = ''
    if resets_at is not None and resets_at > now:
        remaining = int(resets_at - now)
        h, m = divmod(remaining // 60, 60)
        suffix = f' ({h}h {m}m)'
    parts.append(fmt('5h', five) + suffix)

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(fmt('7d', week))

# フォルダ名: $HOME を ~ に置換して末尾に追加
cwd = data.get('cwd', '')
if cwd:
    home = os.path.expanduser('~')
    cwd_display = cwd.replace(home, '~', 1)
    parts.append(f'{DIM}📂 {cwd_display}{R}')

print(f' {DIM}│{R} '.join(parts), end='')

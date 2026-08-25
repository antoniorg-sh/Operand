#!/usr/bin/env bash

cap=$(cat /sys/class/power_supply/BAT0/capacity)
stat=$(cat /sys/class/power_supply/BAT0/status)

ws=$(swaymsg -t get_workspaces -r | python3 -c '
import json, sys
wss = json.load(sys.stdin)
outs = {}
for w in sorted(wss, key=lambda w: w["num"]):
    mark = "[{}]".format(w["num"]) if w["visible"] else str(w["num"])
    outs.setdefault(w["output"], []).append(mark)
print("  |  ".join("{}: {}".format(o, " ".join(l)) for o, l in sorted(outs.items())))
')

out="BAT ${cap}% ${stat}  |  ${ws}"

if [ "$1" = "--print" ]; then
    echo "$out"
else
    swaynag --message "  $out  " --type warning >/dev/null 2>&1 &
    p=$!
    ( sleep 4; kill "$p" 2>/dev/null ) &
fi

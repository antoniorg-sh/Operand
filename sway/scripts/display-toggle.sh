#!/usr/bin/env bash

banner() {
  swaynag --message "$1" --type warning >/dev/null 2>&1 &
  local p=$!
  ( sleep 5; kill "$p" 2>/dev/null ) &
}

outputs_json() { swaymsg -t get_outputs -r 2>/dev/null; }

externals_present() {
  outputs_json | python3 -c '
import json, sys
outs = json.load(sys.stdin)
sys.exit(0 if any(o["name"] != "eDP-1" for o in outs) else 1)
'
}

laptop_enabled() {
  outputs_json | python3 -c '
import json, sys
outs = json.load(sys.stdin)
sys.exit(0 if any(o["name"] == "eDP-1" and o["active"] for o in outs) else 1)
'
}

acer_at_native() {
  outputs_json | python3 -c '
import json, sys
for o in json.load(sys.stdin):
    if o["name"] == "HDMI-A-1":
        cm = o.get("current_mode") or {}
        sys.exit(0 if cm.get("width") == 2560 else 1)
sys.exit(1)
'
}

dell_name() {
  outputs_json | python3 -c '
import json, sys
for o in json.load(sys.stdin):
    if o["name"].startswith("DP-"):
        print(o["name"])
        break
'
}

set_normal() {
  swaymsg -- output eDP-1 enable mode 1920x1080@60Hz position 960 2160 >/dev/null 2>&1
  swaymsg -- output HDMI-A-1 mode 1920x1080@120Hz position -1080 0 transform 270 >/dev/null 2>&1
  local dp; dp=$(dell_name)
  [ -n "$dp" ] && swaymsg -- output "$dp" mode 2560x1440@59.95Hz position 0 0 >/dev/null 2>&1
  banner "Normal display: all screens on"
}

set_reading() {
  local i
  for i in 1 2 3 4 5; do
    swaymsg -- output eDP-1 disable >/dev/null 2>&1
    sleep 0.5
    swaymsg -- output HDMI-A-1 mode 2560x1440@59.951Hz position -1440 0 transform 270 >/dev/null 2>&1
    acer_at_native && break
  done
  local dp; dp=$(dell_name)
  [ -n "$dp" ] && swaymsg -- output "$dp" mode 2560x1440@59.95Hz position 0 0 >/dev/null 2>&1
  if acer_at_native; then
    banner "Reading: laptop OFF, Acer 1440p. Toggle back (SUPER+SHIFT+R) before unplugging!"
  else
    banner "Reading FAILED to commit Acer 1440p after 5 tries -- check output states"
  fi
}

if [ "${1:-}" = "default" ]; then
  externals_present && set_reading
  exit 0
fi

if laptop_enabled; then
  if externals_present; then
    set_reading
  else
    banner "No external monitor connected -- staying on laptop"
  fi
else
  set_normal
fi

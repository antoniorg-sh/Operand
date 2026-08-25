#!/usr/bin/env bash

pidfile="${XDG_RUNTIME_DIR:-/tmp}/dock-display.pid"
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile" 2>/dev/null)" 2>/dev/null; then
  exit 0
fi
echo $$ > "$pidfile"
trap 'rm -f "$pidfile"' EXIT

enabled_count() { hyprctl monitors 2>/dev/null | grep -c '^Monitor '; }

externals_present() {
  hyprctl monitors all 2>/dev/null | grep '^Monitor ' | grep -qv 'Monitor eDP-1'
}

laptop_on() { hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1" >/dev/null 2>&1; }

apply_docked() {
  hyprctl keyword monitor "eDP-1,disable" >/dev/null 2>&1
  hyprctl keyword monitor "HDMI-A-1,2560x1440@59.95,-1440x0,1,transform,1" >/dev/null 2>&1
  local dp
  dp=$(hyprctl monitors all 2>/dev/null | grep -oE '^Monitor DP-[0-9]+' | head -1 | awk '{print $2}')
  [ -n "$dp" ] && hyprctl keyword monitor "$dp,2560x1440@59.95,0x0,1" >/dev/null 2>&1
}

restart_wallpaper() {
  killall hyprpaper 2>/dev/null
  sleep 0.3
  hyprpaper >/dev/null 2>&1 &
}

state=""
while true; do
  if [ "$(enabled_count)" -eq 0 ]; then
    laptop_on
    state=""
    sleep 1
    continue
  fi

  if externals_present; then now="docked"; else now="mobile"; fi
  if [ "$now" != "$state" ]; then
    if [ "$now" = "docked" ]; then apply_docked; else laptop_on; fi
    sleep 0.5
    restart_wallpaper
    state="$now"
  fi

  sleep 1.5
done

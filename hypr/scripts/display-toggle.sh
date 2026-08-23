#!/usr/bin/env bash
# display-toggle.sh — manually flip between NORMAL and READING display profiles.
# Bound to SUPER+SHIFT+R.
#
#   NORMAL  : all screens on. Dell 2560x1440, Acer 1920x1080@120 rotated 90 CW,
#             laptop 1920x1080. Everyday setup, zero risk.
#   READING : laptop OFF so the Acer can run native 2560x1440 rotated (sharpest
#             for reading). Freeing the laptop's display pipe is what lets the
#             rotated 1440p mode commit on the Intel UHD 620.
#
# SAFETY: never turns the laptop off unless an external monitor is connected to
# fall back on. It CANNOT rescue you if you physically unplug while in READING
# mode -- this machine can't reliably re-enable the sole laptop panel from a
# zero-monitor state. Rule: toggle back to NORMAL (SUPER+SHIFT+R) before you
# unplug the externals.

notify() { hyprctl notify -1 5000 "rgb(88c0d0)" "$1" >/dev/null 2>&1; }

# Any connected non-laptop output? (monitors all includes connected-but-disabled)
externals_present() {
  hyprctl monitors all 2>/dev/null | grep '^Monitor ' | grep -qv 'Monitor eDP-1'
}

# Is the laptop currently an ENABLED monitor? (monitors -j lists only enabled)
laptop_enabled() {
  hyprctl monitors -j 2>/dev/null | grep -q '"eDP-1"'
}

# Whichever DP-* the Dell shows up as (its port enumeration isn't stable).
# Anchor to "^Monitor DP-" so we don't match the substring "DP-1" inside "eDP-1".
dell_name() { hyprctl monitors all 2>/dev/null | grep -oE '^Monitor DP-[0-9]+' | head -1 | awk '{print $2}'; }

restart_wallpaper() {
  killall hyprpaper 2>/dev/null
  sleep 0.3
  hyprpaper >/dev/null 2>&1 &
}

set_normal() {
  hyprctl keyword monitor "eDP-1,1920x1080@60,960x2160,1" >/dev/null 2>&1
  hyprctl keyword monitor "HDMI-A-1,1920x1080@120,-1080x0,1,transform,1" >/dev/null 2>&1
  local dp; dp=$(dell_name)
  [ -n "$dp" ] && hyprctl keyword monitor "$dp,2560x1440@59.95,0x0,1" >/dev/null 2>&1
  restart_wallpaper
  notify "Normal display: all screens on"
}

set_reading() {
  # Free the laptop pipe FIRST, then bring the Acer to native 1440p rotated.
  hyprctl keyword monitor "eDP-1,disable" >/dev/null 2>&1
  hyprctl keyword monitor "HDMI-A-1,2560x1440@59.95,-1440x0,1,transform,1" >/dev/null 2>&1
  local dp; dp=$(dell_name)
  [ -n "$dp" ] && hyprctl keyword monitor "$dp,2560x1440@59.95,0x0,1" >/dev/null 2>&1
  restart_wallpaper
  notify "Reading: laptop OFF, Acer 1440p. Toggle back (SUPER+SHIFT+R) before unplugging!"
}

if laptop_enabled; then
  # Currently NORMAL -> want READING, but only if it's safe to drop the laptop.
  if externals_present; then
    set_reading
  else
    notify "No external monitor connected -- staying on laptop (won't black your screen)"
  fi
else
  # Currently READING -> back to NORMAL.
  set_normal
fi

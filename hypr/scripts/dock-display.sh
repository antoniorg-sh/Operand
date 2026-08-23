#!/usr/bin/env bash
# dock-display.sh — auto-switch the monitor profile based on whether the desk
# externals are plugged in. Detection keys off the Dell (DP-2): present => docked.
#
#   DOCKED  (DP-2 connected): laptop OFF; Dell + Acer both at native 2560x1440;
#                             Acer rotated 90 CW (vertical). Sharpest reading setup.
#   MOBILE  (DP-2 absent):    laptop ON (preferred mode). Always leaves a screen.
#
# SAFETY INVARIANT (most important part): never allow zero enabled monitors.
# Every loop, before any profile logic, if nothing is lit we force the laptop on.
# This means undocking can leave you dark for at most one short poll interval, and
# it self-heals even if the dock-state tracking is wrong or the watcher restarts
# mid-transition. Disabling a physical panel is only safe with this backstop.

pidfile="${XDG_RUNTIME_DIR:-/tmp}/dock-display.pid"
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile" 2>/dev/null)" 2>/dev/null; then
  exit 0
fi
echo $$ > "$pidfile"
trap 'rm -f "$pidfile"' EXIT

# Count of currently ENABLED monitors (text output: one "Monitor " line each).
enabled_count() { hyprctl monitors 2>/dev/null | grep -c '^Monitor '; }

# Docked = any external (non-laptop) output is connected. `monitors all` lists
# connected-but-disabled outputs too; a truly unplugged one vanishes entirely.
# We match "any non-eDP-1" rather than a fixed port name because the Dell's
# enumeration isn't stable (seen as both DP-1 and DP-2).
externals_present() {
  hyprctl monitors all 2>/dev/null | grep '^Monitor ' | grep -qv 'Monitor eDP-1'
}

# Re-enable the laptop. NOTE: the "preferred,auto" form is a silent no-op on this
# hardware -- only the explicit mode string actually turns the panel back on.
laptop_on() { hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1" >/dev/null 2>&1; }

apply_docked() {
  # Free the laptop's pipe FIRST, then request the Acer at native 1440p rotated.
  # With 3 pipes lit the rotated-1440p modeset falls back to 1080p (Intel UHD 620
  # can't scan out a rotated 1440p plane alongside a third display).
  hyprctl keyword monitor "eDP-1,disable" >/dev/null 2>&1
  # Acer is always HDMI-A-1: native 1440p, rotated 90 CW, left of the Dell.
  hyprctl keyword monitor "HDMI-A-1,2560x1440@59.95,-1440x0,1,transform,1" >/dev/null 2>&1
  # Dell may enumerate as DP-1 or DP-2; drive whichever DP-* is connected.
  local dp
  # Anchor to "^Monitor DP-" so we don't match "DP-1" inside "eDP-1".
  dp=$(hyprctl monitors all 2>/dev/null | grep -oE '^Monitor DP-[0-9]+' | head -1 | awk '{print $2}')
  [ -n "$dp" ] && hyprctl keyword monitor "$dp,2560x1440@59.95,0x0,1" >/dev/null 2>&1
}

restart_wallpaper() {
  # hyprpaper sizes each wallpaper to monitor geometry at load time; a rotation or
  # resolution change needs a reload or it renders half off-screen.
  killall hyprpaper 2>/dev/null
  sleep 0.3
  hyprpaper >/dev/null 2>&1 &
}

state=""
while true; do
  # 1) HARD SAFETY: never zero screens. Force the laptop on and reset state so the
  #    profile logic re-evaluates cleanly next tick.
  if [ "$(enabled_count)" -eq 0 ]; then
    laptop_on
    state=""
    sleep 1
    continue
  fi

  # 2) Profile switching, only on an actual dock-state change.
  if externals_present; then now="docked"; else now="mobile"; fi
  if [ "$now" != "$state" ]; then
    if [ "$now" = "docked" ]; then apply_docked; else laptop_on; fi
    sleep 0.5
    restart_wallpaper
    state="$now"
  fi

  sleep 1.5
done

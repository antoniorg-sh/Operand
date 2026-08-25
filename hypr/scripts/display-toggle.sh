#!/usr/bin/env bash

notify() { hyprctl notify -1 5000 "rgb(88c0d0)" "$1" >/dev/null 2>&1; }

externals_present() {
  hyprctl monitors all 2>/dev/null | grep '^Monitor ' | grep -qv 'Monitor eDP-1'
}

laptop_enabled() {
  hyprctl monitors -j 2>/dev/null | grep -q '"eDP-1"'
}

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
  hyprctl keyword monitor "eDP-1,disable" >/dev/null 2>&1
  hyprctl keyword monitor "HDMI-A-1,2560x1440@59.95,-1440x0,1,transform,1" >/dev/null 2>&1
  local dp; dp=$(dell_name)
  [ -n "$dp" ] && hyprctl keyword monitor "$dp,2560x1440@59.95,0x0,1" >/dev/null 2>&1
  restart_wallpaper
  notify "Reading: laptop OFF, Acer 1440p. Toggle back (SUPER+SHIFT+R) before unplugging!"
}

if laptop_enabled; then
  if externals_present; then
    set_reading
  else
    notify "No external monitor connected -- staying on laptop"
  fi
else
  set_normal
fi

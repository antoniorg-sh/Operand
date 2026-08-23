#!/usr/bin/env bash
# On-demand status overlay: battery + workspaces per monitor.
# Waybar replacement — shown via Hyprland's built-in notify banner (SUPER+W).

cap=$(cat /sys/class/power_supply/BAT0/capacity)
stat=$(cat /sys/class/power_supply/BAT0/status)

monitors=$(hyprctl monitors)
# "workspace ID 4 (4) on monitor HDMI-A-1:" -> "4 HDMI-A-1"
ws=$(hyprctl workspaces | awk '/^workspace ID/ {gsub(":", "", $NF); print $3, $NF}' | sort -n)

# active workspace per monitor: "Monitor eDP-1 (ID 0):" ... "active workspace: 3 (3)"
declare -A active
while read -r mon id; do
    active[$mon]=$id
done < <(awk '/^Monitor /{m=$2} /active workspace:/{print m, $3}' <<< "$monitors")

out="BAT ${cap}% ${stat}"
for m in $(awk '/^Monitor /{print $2}' <<< "$monitors"); do
    list=""
    while read -r id mon; do
        [ "$mon" = "$m" ] || continue
        [ "$id" -lt 0 ] && continue   # special workspaces have negative IDs
        if [ "$id" = "${active[$m]}" ]; then
            list+=" [$id]"
        else
            list+=" $id"
        fi
    done <<< "$ws"
    out+="  |  $m:$list"
done

# --print for debugging in a terminal instead of the on-screen banner
if [ "$1" = "--print" ]; then
    echo "$out"
else
    hyprctl notify -1 4000 0 "  $out  "
fi

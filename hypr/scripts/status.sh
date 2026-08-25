#!/usr/bin/env bash

cap=$(cat /sys/class/power_supply/BAT0/capacity)
stat=$(cat /sys/class/power_supply/BAT0/status)

monitors=$(hyprctl monitors)
ws=$(hyprctl workspaces | awk '/^workspace ID/ {gsub(":", "", $NF); print $3, $NF}' | sort -n)

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

if [ "$1" = "--print" ]; then
    echo "$out"
else
    hyprctl notify -1 4000 0 "  $out  "
fi

#!/bin/sh
WP=$(find ~/documents/SYNC/wallpapers -type f | shuf -n 1)
swaymsg output "*" background $WP fill


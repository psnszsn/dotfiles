#!/usr/bin/env bash
# requires jq

IFS=:
INITIAL_WORKSPACE=$(swaymsg -t get_workspaces \
  | jq '.[] | select(.focused==true).name' \
  | cut -d"\"" -f2)

swaymsg -t get_outputs | jq -r '.[]|"\(.name):\(.current_workspace)"' | grep -v '^null:null$' | \
while read -r name current_workspace; do
    echo "moving ${current_workspace} up..."
    swaymsg workspace "${current_workspace}"
    swaymsg move workspace to output up   
done
swaymsg workspace $INITIAL_WORKSPACE

#!/bin/sh
# Prints one JSON object describing the default-route interface and, if it is
# an iwd station, the connected wifi network. Used by the network popover.

# busctl waits 25s by default; a stuck iwd shouldn't stall every refresh.
bus() { busctl --system --timeout=2 "$@" 2>/dev/null; }

route=$(ip -j route show default)
dev=$(printf '%s' "$route" | jq -r '.[0].dev // empty')
gateway=$(printf '%s' "$route" | jq -r '.[0].gateway // empty')
addr=""
[ -n "$dev" ] && addr=$(ip -j -4 addr show dev "$dev" | jq -r '.[0].addr_info[0] // empty | "\(.local)/\(.prefixlen)"')

ssid=""
diag="{}"
# iwd device objects (which carry the Station interface) live at /net/connman/iwd/<adapter>/<device>;
# only the one whose interface carries the default route is relevant.
station=""
if [ -n "$dev" ]; then
  for obj in $(bus --list tree net.connman.iwd | grep -E '^/net/connman/iwd/[0-9]+/[0-9]+$'); do
    if [ "$(bus -j get-property net.connman.iwd "$obj" net.connman.iwd.Device Name | jq -r '.data // empty')" = "$dev" ]; then
      station=$obj
      break
    fi
  done
fi
if [ -n "$station" ]; then
  net=$(bus -j get-property net.connman.iwd "$station" net.connman.iwd.Station ConnectedNetwork | jq -r '.data // empty')
  if [ -n "$net" ]; then
    ssid=$(bus -j get-property net.connman.iwd "$net" net.connman.iwd.Network Name | jq -r '.data // empty')
    diag=$(bus -j call net.connman.iwd "$station" net.connman.iwd.StationDiagnostic GetDiagnostics | jq -c '.data[0] | map_values(.data)')
  fi
fi

jq -nc --arg dev "$dev" --arg addr "$addr" --arg gateway "$gateway" --arg ssid "$ssid" --argjson diag "${diag:-{\}}" \
  '{dev: $dev, addr: $addr, gateway: $gateway, ssid: $ssid, rssi: $diag.RSSI, frequency: $diag.Frequency, security: $diag.Security, mode: $diag.RxMode}'

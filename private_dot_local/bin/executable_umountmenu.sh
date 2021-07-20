#!/bin/bash

menu="$@"

disks=$(udiskie-info -a -o "{ui_label}" -f is_partition -f 'is_mounted')

[ -z "$disks" ] && {
	notify-send "Mount Menu" "No unmountable device"
	exit 0
}

selected=$(printf "$disks" | $menu)

[ -z "$selected" ] && exit 1

partpath=$(echo "$selected" | cut -d: -f1)

udisksctl unmount -b "$partpath" || notify-send "Mount Menu" "Error unmounting device"

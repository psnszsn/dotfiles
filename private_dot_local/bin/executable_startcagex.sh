#!/bin/bash
#
# This is a script to demonstrate cage + Xwayland as a replacement for standalone Xorg.
# You can modify this to launch classic X window managers / DEs.
#
# Note that you should disable any x11 compositors. I.e. to launch xfce4:
# xfwm4 --compositor=off &
# exec xfce4-session
#

DNUM=:5

cage -- Xwayland $DNUM -retro -noreset &

export DISPLAY=$DNUM

# idea lifted from https://gist.github.com/tullmann/476cc71169295d5c3fe6
MAX=10
CT=0
while ! xdpyinfo >/dev/null 2>&1; do
    sleep 0.50s
    CT=$(( CT + 1 ))
    if [ "$CT" -ge "$MAX" ]; then
        echo "FATAL: $0: Gave up waiting for X server $DISPLAY"
        exit 11
    fi
done

export WAYLAND_DISPLAY=null # Hack, but works
export GDK_BACKEND=x11
unset SDL_VIDEODRIVER

exec awesome


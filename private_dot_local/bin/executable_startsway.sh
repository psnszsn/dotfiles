#!/bin/sh
export KITTY_ENABLE_WAYLAND=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export MOZ_WAYLAND_USE_VAAPI=1
export MOZ_DBUS_REMOTE=1

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway

export BROWSER=firefox
export TERMINAL=alacritty
export QT_QPA_PLATFORMTHEME=qt5ct

# export WLR_DRM_NO_MODIFIERS=1

# export GTK_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus
# export QT_IM_MODULE=ibus

# export WLR_NO_HARDWARE_CURSORS=1
# export GTK_IM_MOUDLE=xim
# export XMODIFIERS=@im=ibus
# export QT_IM_MODULE=ibus
# eval `ssh-agent`
# export XKB_LOG_LEVEL=critical

# if [ "$XDG_RUNTIME_DIR" == "" ]
# then
# 	export XDG_RUNTIME_DIR=/tmp
# fi
export BEMENU_OPTS="-i --fn 'Hack 13' -m '-1'"

# exec sway -d -Ddamage=rerender 2>~/sway.log
# exec sway -d 2> ~/desktop/sway.log

if test -z "$DBUS_SESSION_BUS_ADDRESS"
then
    exec dbus-run-session -- sway
    # exec dbus-run-session -- sway -d 2> ~/sway.log
else
    exec sway
fi

# exec systemd-cat --identifier sway sway

# systemctl --user import-environment
# exec systemctl --wait --user start sway.service

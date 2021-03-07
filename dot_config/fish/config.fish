abbr -a nv nvim
abbr -a pass gopass
abbr -a q exit
abbr -a o xdg-open
abbr -a swayconfig "nvim ~/.config/sway/config"
abbr -a refl "sudo reflector --verbose --country Romania -l 10 --sort rate --save /etc/pacman.d/mirrorlist"
abbr -a g git
abbr -a c cargo
abbr -a m make
abbr -a n 'nnn -a'
abbr -a pacman "sudo pacman"
abbr -a ip "ip -c"
abbr -a start "systemctl start"
abbr -a stop "systemctl stop"
abbr -a status "systemctl status"
abbr -a dl "downloads/"
abbr -a "pip" "pip install --user"
abbr -a nin "ninja -C build"
abbr -a cal "cal -m"
abbr -a dush "du -sh"
abbr -a lst "exa -la -s modified"
abbr -a lsls "fd --changed-within 1d -X exa -dl -rs modified"
abbr -a apk "sudo apk"
abbr -a yay paru
abbr -a j z
abbr -a p paru
abbr -a cz chezmoi


if command -v direnv > /dev/null
    direnv hook fish | source
end

if command -v zoxide > /dev/null
	zoxide init fish | source
end

if command -v exa > /dev/null
	abbr -a l 'exa -l'
	abbr -a ls 'exa'
	abbr -a ll 'exa -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end


set -gx FZF_DEFAULT_COMMAND 'fd --type file --hidden'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type directory --hidden'

set -gx NNN_PLUG 'f:finder;o:fzcd;d:diffs;t:nmount;v:imgview;p:preview-tui;z:autojump'

set -x fish_user_paths \
        ~/.cargo/bin \
        ~/go/bin \
        ~/.local/share/npm/bin \
# set -x

# set -x XDG_DATA_DIRS /home/vlad/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share

eval (dircolors -c)

#if test -f $HOME/vladDotfiles/xdg_basedir/env.fish
#	source $HOME/vladDotfiles/xdg_basedir/env.fish;
#end

if status is-login
    if test -z "$DISPLAY" -a $XDG_VTNR = 1
        echo "dissspl"
    end

    if string match -q "/dev/tty1" (tty)
        #exec startsway.sh
    end
end



function fish_vi_cursor_handle --on-variable fish_bind_mode --on-event fish_postexec
  switch $fish_bind_mode
    case insert
        __fish_cursor_xterm line
    case default
        __fish_cursor_xterm block
    case visual
        __fish_cursor_xterm underscore
    end 
end

function fish_vi_cursor_handle_preexec --on-event fish_preexec
   __fish_cursor_xterm block
end

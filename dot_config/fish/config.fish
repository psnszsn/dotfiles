abbr -a nv nvim
abbr -a q exit
abbr -a o xdg-open
abbr -a swayconfig "chezmoi edit ~/.config/sway/config --apply"
abbr -a refl "sudo reflector --verbose --country Romania -l 10 --sort rate --save /etc/pacman.d/mirrorlist"
abbr -a g git
abbr -a c cargo
abbr -a m make
abbr -a pacman "sudo pacman"
abbr -a nin "ninja -C build"
abbr -a cal "cal -m"
abbr -a dush "du -sh"
abbr -a lst "exa -la -s modified"
abbr -a lsls "fd --changed-within 1d -X exa -dl -rs modified"
abbr -a py python
abbr -a cz chezmoi
abbr -a j just
abbr -a nvd "alacritty -e nvim &"
abbr -a cs cd
abbr -a k kubectl
abbr -a lf yazi
abbr -a y yazi
alias myip="curl https://ipinfo.io"

if command -v doas > /dev/null
	for cmd in ifup ifdown wg-quick apk service
		abbr -a $cmd "doas $cmd"
	end
	abbr -a sudo 'doas'
end

if not test -L (which ip)
	abbr -a ip "ip -c"
end

if command -v direnv > /dev/null
    direnv hook fish | source
end

if command -v zoxide > /dev/null
	zoxide init fish | source
end

if command -v doas > /dev/null
	abbr -a sudo 'doas'
end

if command -v eza > /dev/null
	abbr -a l 'eza -l'
	abbr -a ls 'eza'
	abbr -a ll 'eza -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
	abbr -a lll 'ls -la'
end


set -gx FZF_DEFAULT_COMMAND 'fd --type file --hidden'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type directory --hidden'
set -gx MANPAGER 'nvim +Man!'

fish_add_path -p ~/.cargo/bin ~/go/bin ~/.local/share/npm/bin

# eval (dircolors -c)


if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        echo "dissspl"
    end

    if string match -q "/dev/tty1" (tty)
        #exec startsway.sh
    end
end

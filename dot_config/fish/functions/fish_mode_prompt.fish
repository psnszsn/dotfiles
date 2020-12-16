function fish_mode_prompt --description 'Displays the current mode'
    if string match -q "/dev/tty*" (tty) 
        fish_default_mode_prompt
    end
end


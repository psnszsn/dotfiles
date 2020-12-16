function fish_user_key_bindings
    fish_vi_key_bindings
    bind -s --preset L end-of-line
    bind -s --preset H beginning-of-line
    bind -s --preset dL kill-line
    bind -s --preset dH backward-kill-line
    bind -s --preset -m insert cL kill-line force-repaint
    bind -s --preset -m insert cH backward-kill-line force-repaint
    bind -s --preset yL kill-line yank
    bind -s --preset yH backward-kill-line yank
    bind -s --preset -M visual L end-of-line
    bind -s --preset -M visual H beginning-of-line
    #fzf_key_bindings
    bind \cf fzf-file-widget
    bind -M insert \cf fzf-file-widget
    # bind \cj 'cd (autojump -s | sed "/_____/Q; s/^[0-9,.:]*\s*//" |  fzf --height 40% --reverse --inline-info)'
    # bind -M insert \cj 'cd (autojump -s | sed "/_____/Q; s/^[0-9,.:]*\s*//" |  fzf --height 40% --reverse --inline-info)'
end

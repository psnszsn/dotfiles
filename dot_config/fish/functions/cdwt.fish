function cdwt
    set -l worktree (git worktree list | fzf --prompt="Select worktree: " | awk '{print $1}')
    if test -n "$worktree"
        cd $worktree
    end
end

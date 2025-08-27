function cdwt
    set -l current_repo_root (git rev-parse --show-toplevel 2>/dev/null)
    set -l relative_path ""
    
    if test -n "$current_repo_root"
        set relative_path (string replace "$current_repo_root" "" (pwd))
    end
    
    set -l worktree (git worktree list | fzf --prompt="Select worktree: " | awk '{print $1}')
    if test -n "$worktree"
        set -l target_path "$worktree$relative_path"
        if test -d "$target_path"
            cd "$target_path"
        else
            cd $worktree
        end
    end
end

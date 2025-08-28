function nva -d "Attach to running nvim instance by selecting from fzf menu"
    if test -n "$NVIM"
        echo "Already inside nvim"
        return 1
    end
    
    set nvim_sockets (lsof -Ua | grep nvim | grep LISTEN | awk '{print $2 "\t" $9}')
    
    if test (count $nvim_sockets) -eq 0
        echo "No running nvim sockets found"
        return 1
    end
    
    set pid_cwd_socket_list
    for line in $nvim_sockets
        set pid (echo $line | cut -f1)
        set socket (echo $line | cut -f2)
        set cwd (readlink /proc/$pid/cwd 2>/dev/null)
        set cmdline (cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ')
        if test -n "$cwd"; and string match -q "*--embed*" "$cmdline"
            set pid_cwd_socket_list $pid_cwd_socket_list "$pid	$cwd	$socket"
        end
    end
    
    if test (count $pid_cwd_socket_list) -eq 0
        echo "No accessible nvim processes found"
        return 1
    end
    
    # echo "Available nvim instances:"
    # printf '%s\n' $pid_cwd_socket_list | awk -F'\t' '{print $2 " (PID: " $1 ")"}'
    set selected (printf '%s\n' $pid_cwd_socket_list | fzf --delimiter='\t' --with-nth=1,2 --prompt="Select nvim instance: ")
    
    if test -z "$selected"
        echo "No selection made"
        return 1
    end
    
    set pid (echo $selected | cut -f1)
    set cwd (echo $selected | cut -f2)
    set socket (echo $selected | cut -f3)
    
    echo "Attaching to nvim process $pid in $cwd"
    echo nvim --server $socket --remote-ui
end

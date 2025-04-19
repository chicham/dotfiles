function __check_tool_with_configs --description "Check tool installation and its configs"
    set -l tool_name $argv[1]
    set -l config_paths $argv[2]
    set -l managed_files $argv[3]
    set -l check_cmd $argv[4]

    set -l success_icon "✓"
    set -l error_icon "✗"

    # Check if tool is installed
    if test -z "$check_cmd"
        set check_cmd "$tool_name --version"
    end

    if command -v $tool_name >/dev/null 2>&1
        # Get version info
        set -l ver_info (eval $check_cmd 2>&1 | head -n 1)
        echo "  $success_icon $tool_name: $ver_info"
    else
        echo "  $error_icon $tool_name: not installed"
    end

    # Check config files
    if test -n "$config_paths"
        set -l config_list (string split ":" $config_paths)

        for cfg in $config_list
            set -l managed_status ""
            if contains $cfg $managed_files
                set managed_status "(managed by chezmoi)"
            end

            set -l file_path "$HOME/$cfg"
            if test -f $file_path
                echo "    $success_icon config: $cfg $managed_status"
            else
                echo "    $error_icon config: $cfg missing $managed_status"
            end
        end
    end
end
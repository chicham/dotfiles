function remote_exec --description "Run command on remote server and redirect output locally"
  if test (count $argv) -lt 2
    echo "Usage: remote_exec [server] [command]"
    return 1
  end

  set -l server $argv[1]
  set -l command $argv[2..-1]

  # Run command on remote server and capture output locally
  ssh -t $server "$command"
end

# Completion for remote hosts (first argument)
# Uses Fish's built-in SSH host completion
complete -f -c remote_exec -n "__fish_is_first_arg" -a "(__fish_complete_user_at_hosts)" -d "Remote server"

# Completion for commands (second argument onwards)
# Once a host is selected, provide command completions
complete -f -c remote_exec -n "not __fish_is_first_arg" -a "(__fish_complete_command)" -d "Command"

# Completions for agentask

# Helper function to get available agents
function __fish_agentask_agents
    echo "claude"
    echo "gemini"
    echo "openai"
end

# Agent model configurations (same as in agentask.fish)
set -g CLAUDE_MODELS "claude-opus-4@20250514" "claude-sonnet-4@20250514" "claude-3-7-sonnet@20250219" "claude-3-5-haiku@20241022"
set -g GEMINI_MODELS "gemini-2.5-pro" "gemini-2.5-flash"
set -g OPENAI_MODELS "gpt-4o" "gpt-4" "gpt-3.5-turbo"

# Helper function to get models for a specific agent
function __fish_agentask_models_for_agent
    set -l agent $argv[1]
    switch $agent
        case "claude"
            printf '%s\n' $CLAUDE_MODELS
        case "gemini"
            printf '%s\n' $GEMINI_MODELS
        case "openai"
            printf '%s\n' $OPENAI_MODELS
    end
end

# Helper function to get models based on current command line agent selection
function __fish_agentask_models
    set -l cmd (commandline -opc)
    set -l agent_idx

    # Find --agent flag in command line
    for i in (seq (count $cmd))
        if test "$cmd[$i]" = "--agent"
            if test $i -lt (count $cmd)
                set agent_idx (math $i + 1)
                break
            end
        end
    end

    if test -n "$agent_idx"
        __fish_agentask_models_for_agent $cmd[$agent_idx]
    else
        # Default to gemini models if no agent specified
        __fish_agentask_models_for_agent "gemini"
    end
end

# Completions for agentask
complete -c agentask -s h -l help -d "Show help"
complete -c agentask -s a -l all_files -d "Include ALL files in context"
complete -c agentask -s m -l model -d "Model to use" -xa "(__fish_agentask_models)"
complete -c agentask -l agent -d "AI agent to use" -xa "(__fish_agentask_agents)"

# =============================================================================
# agentask
#
# Author: Gemini
# Last Updated: 2025-06-29
#
# Queries an AI agent with a prompt, supporting both command-line arguments
# and piped input from other commands.
# =============================================================================

# --- Global Model & Agent Configuration ---
set -g CLAUDE_MODELS "claude-opus-4@20250514" "claude-sonnet-4@20250514" "claude-3-7-sonnet@20250219" "claude-3-5-haiku@20241022"
set -g CLAUDE_DEFAULT "claude-3-5-haiku@20241022"
set -g GEMINI_MODELS "gemini-2.5-pro" "gemini-2.5-flash"
set -g GEMINI_DEFAULT "gemini-2.5-flash"
set -g CODEX_PROVIDERS "openai" "openrouter" "azure" "gemini" "ollama" "mistral" "deepseek" "xai" "groq" "arceeai"
set -g CODEX_DEFAULT_PROVIDER "openai"
set -g CODEX_MODELS "gpt-4o" "gpt-4" "gpt-3.5-turbo" "gemini-2.5-pro" "llama3" "mistral-large" "deepseek-coder"
set -g CODEX_DEFAULT "gpt-4o"

# --- Helper Functions ---

# _get_agent_models: Returns the list of available models for a given agent.
function _get_agent_models -a agent
    switch $agent
        case "claude"; string join \n $CLAUDE_MODELS
        case "gemini"; string join \n $GEMINI_MODELS
        case "codex"; string join \n $CODEX_MODELS
        case "*"; return 1
    end
end

# _get_agent_default: Returns the default model name for a given agent.
function _get_agent_default -a agent
    switch $agent
        case "claude"; echo $CLAUDE_DEFAULT
        case "gemini"; echo $GEMINI_DEFAULT
        case "codex"; echo $CODEX_DEFAULT
        case "*"; return 1
    end
end

# _get_codex_providers: Returns the list of available providers for codex.
function _get_codex_providers
    string join \n $CODEX_PROVIDERS
end

# _get_codex_default_provider: Returns the default provider for codex.
function _get_codex_default_provider
    echo $CODEX_DEFAULT_PROVIDER
end


# --- Main `agentask` Function ---

# Queries an AI agent with a prompt, supporting both CLI arguments and piped input.
function agentask -d "A flexible AI agent wrapper with support for piped context and dry runs."
    argparse 'h/help' 'd/dry-run' 'a/all_files' 'm/model=' 'agent=' 'provider=' 'debug' -- $argv
    or return 1

    if set -ql _flag_help
        echo "Usage: agentask [OPTIONS] [QUERY_TEXT]" >&2
        echo "       <command> | agentask [OPTIONS] [QUERY_TEXT]" >&2
        echo "" >&2
        echo "Description:" >&2
        echo "  A powerful, flexible wrapper to query various AI models. It can operate in" >&2
        echo "  several modes:" >&2
        echo "  1. Directly from a query on the command line." >&2
        echo "  2. By processing context piped to it from another command (e.g., git diff)." >&2
        echo "  3. A hybrid of both, where it uses piped context to answer a specific query." >&2
        echo "" >&2
        echo "Options:" >&2
        echo "  -d, --dry-run     Print the complete, final prompt for debugging without calling the AI." >&2
        echo "  -a, --all_files   Include all git-tracked files as context for the agent." >&2
        echo "  --agent AGENT     Specify the AI agent to use (claude, gemini, codex). Defaults to gemini." >&2
        echo "  -m, --model MODEL   Specify the exact model to use (e.g., gpt-4o, claude-3-5-haiku)." >&2
        echo "  --provider PROVIDER  Specify the provider for codex agent (openai, gemini, ollama, etc.)." >&2
        echo "  --debug           Show detailed input/output information during execution." >&2
        echo "  -h, --help        Show this help message and exit." >&2
        return 0
    end

    # To robustly handle piped input without hanging, we read stdin line-by-line.
    set -l stdin_lines
    if not isatty stdin
        while read --line line
            set -a stdin_lines $line
        end
    end
    set -l stdin_content (string join \n $stdin_lines)

    # Determine agent and model, with validation.
    set -l agent
    if set -q _flag_agent
        set agent (string lower $_flag_agent)
    else
        set agent "gemini"
    end

    set -l valid_models (_get_agent_models $agent)
    if test $status -ne 0
        echo "Error: Unknown agent '$agent'. Valid agents are: claude, gemini, codex." >&2
        return 1
    end

    set -l default_model (_get_agent_default $agent)
    set -l model
    if set -q _flag_model
        set model $_flag_model
    else
        set model $default_model
    end

    if not contains $model $valid_models
        echo "Error: Invalid model '$model' for agent '$agent'." >&2
        echo "Valid models for '$agent': "(string join ", " $valid_models) >&2
        return 1
    end

    # Handle provider for codex agent
    set -l provider
    if test "$agent" = "codex"
        if set -q _flag_provider
            set provider $_flag_provider
        else
            set provider (_get_codex_default_provider)
        end

        set -l valid_providers (_get_codex_providers)
        if not contains $provider $valid_providers
            echo "Error: Invalid provider '$provider' for codex agent." >&2
            echo "Valid providers for codex: "(string join ", " $valid_providers) >&2
            return 1
        end
    end

    # Construct the final prompt based on whether input was piped.
    set -l cli_query (string join " " $argv)
    if test -z "$stdin_content" -a -z "$cli_query"
        echo "Error: A prompt is required, either from arguments or piped via stdin." >&2
        return 1
    end

    set -l system_prompt "You are an expert AI assistant, designed to be helpful, clear, and precise. Please process the user's request carefully."
    set -l final_prompt ""
    if test -n "$stdin_content"
        set -l context_block "The following context has been provided:\n\n--- START CONTEXT ---\n$stdin_content\n--- END CONTEXT ---"
        if test -z "$cli_query"
            set cli_query "Provide a comprehensive analysis of the provided context. Summarize its key points and describe its overall purpose."
        end
        set final_prompt "$system_prompt\n\n$context_block\n\nBased on the context above, please fulfill the following request:\n\n$cli_query"
    else
        set final_prompt "$system_prompt\n\nPlease fulfill the following request:\n\n$cli_query"
    end

    # Show debug information if requested
    if set -ql _flag_debug
        _agent_debug "Input Prompt" "$final_prompt"
    end

    # Handle dry-run mode or execute the AI call.
    set -l agent_response
    if set -ql _flag_dry_run
        set -l dry_run_info "Agent: $agent, Model: $model"
        if test "$agent" = "codex"
            set dry_run_info "$dry_run_info, Provider: $provider"
        end
        _agent_debug "🤖 DRY RUN MODE" "$dry_run_info\n--- FINAL PROMPT ---\n$final_prompt\n--- END DRY RUN ---"

        # Generate fake multiline response with EXACT SAME IFS processing as real response
        begin
            set -l IFS
            set agent_response (printf '%s\n' "I'll analyze the provided context and create a conventional commit message.

Looking at the staged changes, I can see updates to the agentcommit function that improve the commit prompt with better formatting and conventional commit requirements.

\`\`\`
git commit -m \"feat(fish): update agentcommit with improved commit instructions

Add conventional commit format requirements and enforce single atomic
commit generation with proper markdown block output formatting. This
ensures the AI generates properly structured commit messages that
follow project conventions.\"
\`\`\`

This commit follows the conventional format with a clear type (feat), scope (fish), and descriptive message under 50 characters for the subject line.")
        end
    else
        set -l info_msg "Asking $agent (model: $model"
        if test "$agent" = "codex"
            set info_msg "$info_msg, provider: $provider"
        end
        set info_msg "$info_msg)..."
        _agent_info "$info_msg"

        # Build command based on agent type
        set -l agent_cmd
        switch $agent
            case "codex"
                set agent_cmd codex --provider "$provider" --model "$model" --quiet "$final_prompt"
            case "claude"
                set agent_cmd claudecode --model "$model" --print "$final_prompt"
            case "gemini"
                set -l agent_cmd_args --model "$model" --prompt "$final_prompt"
                if set -ql _flag_all_files
                    set -a agent_cmd_args --all_files
                end
                set agent_cmd gemini $agent_cmd_args
        end

        # The agent's raw response is captured
        begin
            set -l IFS
            set agent_response ($agent_cmd < /dev/null)
        end
    end
    if test -n "$agent_response"
        # Show debug information for response if requested
        if set -ql _flag_debug
            _agent_debug "Raw AI Response" "$agent_response"
        end

        printf '%s\n' "$agent_response"
        printf '%s\n' "$agent_response" | pbcopy
    else
        _agent_error "Received empty response from AI agent"
        return 1
    end
end

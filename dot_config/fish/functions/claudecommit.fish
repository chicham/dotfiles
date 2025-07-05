# =============================================================================
# claudecommit
#
# Author: Refactored for maintainability
# Last Updated: 2025-07-04
#
# Generates a conventional commit message from staged git changes by calling
# Claude Code's /commit command. This script uses Claude Code's structured output parsing.
# =============================================================================

# Parse command line arguments and return parsed values
function _claudecommit_parse_args
    argparse 'h/help' 'model=' -- $argv
    or return 2

    # Set description from remaining arguments
    set -l description $argv

    # Output parsed values (will be captured by caller)
    if set -ql _flag_help
        echo "help=true"
    else
        echo "help=false"
    end

    if set -ql _flag_model
        echo "model=$_flag_model"
    else
        echo "model=claude-3-5-haiku@20241022"
    end

    echo "description="(string join " " $description)
end

# Display help message
function _claudecommit_show_help
    echo "Usage: claudecommit [OPTIONS] [<commit_description>]" >&2
    echo "" >&2
    echo "Generates a conventional commit message from staged git changes using AI analysis." >&2
    echo "The commit_description argument provides additional context for the commit." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --model MODEL     Specify Claude model (default: claude-3-5-haiku@20241022)" >&2
    echo "  -h, --help        Show this help message" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  claudecommit" >&2
    echo "  claudecommit add user authentication --model claude-3-5-sonnet@20241022" >&2
end

# Generates a conventional commit message from staged git changes
function claudecommit -d "Generate atomic commit messages using Claude Code"
    # This function uses Claude Code's /commit command to generate conventional commit messages.

    # Parse arguments using local variables
    set -l parse_result (_claudecommit_parse_args $argv)
    or return 2

    # Extract parsed values
    set -l help false
    set -l model "claude-3-5-haiku@20241022"
    set -l commit_description ""

    for line in $parse_result
        set -l key_value (string split "=" $line)
        switch $key_value[1]
            case "help"
                set help $key_value[2]
            case "model"
                set model $key_value[2]
            case "description"
                set commit_description $key_value[2]
        end
    end

    if test "$help" = "true"
        _claudecommit_show_help
        return 0
    end

    # Check for staged changes before proceeding
    if git diff --staged --quiet
        _agent_error "No staged changes to commit" "Use 'git add' to stage files first"
        return 1
    end

    _agent_info "Generating commit message with AI..."

    # Build claude command arguments
    set -l claude_args --model "$model" -p

    # Call claude with the commit command
    set -l response
    begin
        set -l IFS
        set response (claude $claude_args "/commit $commit_description" 2>/dev/null)
    end

    if test -z "$response"
        echo "Error: Received an empty response from Claude." >&2
        return 1
    end

    # Extract commit message (response should be just the commit message)
    set -l commit_message
    begin
        set -l IFS
        set commit_message (string trim -- "$response")
    end

    if not _agent_validate_response "$commit_message"
        return 1
    end

    # Display the commit message using bat for better readability
    begin
        echo ""
        echo "📝 Commit Message:"
        printf '%s\n' "$commit_message"
        echo ""
    end | _agent_display_with_bat

    # Execute git commit with --edit flag
    set -l git_command "git commit --edit -m \"$commit_message\""
    printf '%s\n' "$git_command" | pbcopy
    _agent_clipboard "Git commit command copied to clipboard:"
    echo "   $git_command"
end

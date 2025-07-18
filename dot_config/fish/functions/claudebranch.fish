# =============================================================================
# claudebranch
#
# Author: Refactored for maintainability
# Last Updated: 2025-07-04
#
# Generates a branch name by calling Claude Code's /create-branch command.
# This script uses Claude Code's structured output parsing.
# =============================================================================

# Parse command line arguments and return parsed values
function _claudebranch_parse_args
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
function _claudebranch_show_help
    echo "Usage: claudebranch [OPTIONS] [issue_number | description]" >&2
    echo "" >&2
    echo "Generates a branch name from GitHub issue using AI analysis." >&2
    echo "The issue_number can be:" >&2
    echo "  - Specified as an argument" >&2
    echo "  - Extracted from current branch name (if it contains an issue number)" >&2
    echo "  - Omitted if providing only a description" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --model MODEL     Specify Claude model (default: claude-3-5-haiku@20241022)" >&2
    echo "  -h, --help        Show this help message" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  claudebranch 123                    # Use issue #123" >&2
    echo "  claudebranch                        # Extract issue from current branch" >&2
    echo "  claudebranch fix user login bug     # Create branch from description only" >&2
    echo "  claudebranch 456 --model claude-3-5-sonnet@20241022" >&2
end

# Generates a branch name from GitHub issue
function claudebranch -d "Generate branch name using Claude Code"
    # This function uses Claude Code's /create-branch command to generate a branch name.

    # Parse arguments using local variables
    set -l parse_result (_claudebranch_parse_args $argv)
    or return 2

    # Extract parsed values
    set -l help false
    set -l model "claude-3-5-haiku@20241022"
    set -l issue_number ""

    for line in $parse_result
        set -l key_value (string split "=" $line)
        switch $key_value[1]
            case "help"
                set help $key_value[2]
            case "model"
                set model $key_value[2]
            case "description"
                set issue_number $key_value[2]
        end
    end

    if test "$help" = "true"
        _claudebranch_show_help
        return 0
    end

    # Try to get issue number from current branch if no arguments provided
    if test -z "$issue_number"
        # Check if no arguments were provided at all
        if test (count $argv) -eq 0
            set -l current_branch (git branch --show-current 2>/dev/null)
            if test $status -eq 0 -a -n "$current_branch"
                # Extract issue number from branch name (e.g., feature/123-description -> 123)
                set -l extracted_issue (string match -r '\b(\d+)\b' "$current_branch")
                if test -n "$extracted_issue"
                    set issue_number "$extracted_issue"
                    _agent_info "Using issue #$issue_number from current branch: $current_branch"
                else
                    # No issue number found, use branch name as description
                    set issue_number "$current_branch"
                    _agent_warning "No issue number found in current branch" "Using branch name as description: '$current_branch'"
                end
            else
                _agent_error "Cannot determine current branch and no arguments provided" "Provide an issue number or description"
                return 1
            end
        else
            # Arguments were provided, use them as description
            set issue_number (string join " " $argv)
            _agent_warning "No GitHub issue number available" "Creating branch from description only: '$issue_number'"
        end
    end

    _agent_info "Generating branch name with AI..."

    # Build claude command arguments
    set -l claude_args --model "$model" -p

    # Call claude with the create-branch command
    set -l response
    begin
        set -l IFS
        set response (claude $claude_args "/create-branch $issue_number" 2>/dev/null)
    end

    if test -z "$response"
        echo "Error: Received an empty response from Claude." >&2
        return 1
    end

    # Extract branch name (response should be just the branch name)
    set -l branch_name
    begin
        set -l IFS
        set branch_name (string trim -- "$response")
    end

    if not _agent_validate_response "$branch_name"
        return 1
    end

    # Validate branch name format
    if not string match -q "*/*" "$branch_name"
        _agent_error "Invalid branch name format: $branch_name" "Expected format is 'type/description' (e.g., feature/user-auth)"
        return 1
    end

    # Extract type and check if it's valid
    set -l branch_type (string split "/" "$branch_name")[1]
    if not contains "$branch_type" feature fix hotfix chore
        _agent_warning "Unusual branch type '$branch_type'"
        _agent_suggestion "Expected types are feature, fix, hotfix, or chore"
    end

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/$branch_name"
        _agent_error "Branch '$branch_name' already exists" "Choose a different name or delete the existing branch"
        return 1
    end

    # Display the generated branch name using bat for better readability
    begin
        echo ""
        echo "🌿 Generated branch: $branch_name"
        echo ""
    end | _agent_display_with_bat

    # Build the git command to create and switch to the branch
    set -l git_command "git checkout -b $branch_name"

    # Copy the git command to clipboard
    printf '%s\n' "$git_command" | pbcopy
    _agent_clipboard "Git branch command copied to clipboard:"
    echo "   $git_command"
end

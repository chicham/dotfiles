# =============================================================================
# claudepr
#
# Author: Refactored for maintainability
# Last Updated: 2025-07-04
#
# Generates a comprehensive GitHub pull request by calling Claude Code's /create-pr command.
# This script uses Claude Code's structured output parsing.
# =============================================================================

# Parse command line arguments and return parsed values
function _claudepr_parse_args
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
function _claudepr_show_help
    echo "Usage: claudepr [OPTIONS] <pr_description>" >&2
    echo "" >&2
    echo "Creates a comprehensive GitHub pull request for the current branch using AI analysis." >&2
    echo "The pr_description argument describes what the PR accomplishes." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --model MODEL     Specify Claude model (default: claude-3-5-haiku@20241022)" >&2
    echo "  -h, --help        Show this help message" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  claudepr implement user authentication system" >&2
    echo "  claudepr fix login validation bug" >&2
    echo "  claudepr add search functionality --model claude-3-5-sonnet@20241022" >&2
end

# Generates a comprehensive GitHub pull request description
function claudepr -d "Generate comprehensive GitHub pull request using Claude Code"
    # This function uses Claude Code's /create-pr command to generate structured PR data.

    # Parse arguments using local variables
    set -l parse_result (_claudepr_parse_args $argv)
    or return 2

    # Extract parsed values
    set -l help false
    set -l model "claude-3-5-haiku@20241022"
    set -l pr_description ""

    for line in $parse_result
        set -l key_value (string split "=" $line)
        switch $key_value[1]
            case "help"
                set help $key_value[2]
            case "model"
                set model $key_value[2]
            case "description"
                set pr_description $key_value[2]
        end
    end

    if test "$help" = "true"
        _claudepr_show_help
        return 0
    end

    _agent_info "Generating comprehensive GitHub pull request with AI..."

    # Build claude command arguments
    set -l claude_args --model "$model" -p

    # Call claude with the create-pr command
    set -l response
    begin
        set -l IFS
        set response (claude $claude_args "/create-pr $pr_description" 2>/dev/null)
    end

    if test -z "$response"
        echo "Error: Received an empty response from Claude." >&2
        return 1
    end

    # Extract fields from the structured response
    set -l pr_title
    set -l pr_body
    set -l pr_base
    set -l pr_draft
    set -l pr_assignees
    set -l pr_reviewers
    set -l pr_labels
    set -l pr_milestone

    begin
        set -l IFS
        # Extract single-line fields using utility functions
        set pr_title (_agent_extract_field "$response" "TITLE")
        set pr_base (_agent_extract_field "$response" "BASE")
        set pr_draft (_agent_extract_field "$response" "DRAFT")
        set pr_assignees (_agent_extract_field "$response" "ASSIGNEES")
        set pr_reviewers (_agent_extract_field "$response" "REVIEWERS")
        set pr_labels (_agent_extract_field "$response" "LABELS")
        set pr_milestone (_agent_extract_field "$response" "MILESTONE")

        # Extract multiline BODY field using utility function
        set pr_body (_agent_extract_body_field "$response")
    end

    if not _agent_validate_response "$pr_title"
        return 1
    end

    # Display the extracted PR information using bat for better readability
    begin
        echo ""
        echo "🚀 Pull Request:"
        echo "Title: $pr_title"
        if test -n "$pr_body"
            echo ""
            echo "Description:"
            printf '%s\n' "$pr_body"
        end
        echo ""
    end | _agent_display_with_bat

    # Build the gh command with all available fields
    set -l gh_command "gh pr create"

    # Add required fields
    set gh_command "$gh_command --title \"$pr_title\""
    set gh_command "$gh_command --body \"$pr_body\""

    # Add optional fields if present
    if test -n "$pr_base"
        set gh_command "$gh_command --base \"$pr_base\""
    end

    if test "$pr_draft" = "true"
        set gh_command "$gh_command --draft"
    end

    if test -n "$pr_assignees"
        # Split comma-separated assignees and add each one
        for assignee in (string split ',' "$pr_assignees")
            set assignee (string trim "$assignee")
            if test -n "$assignee"
                set gh_command "$gh_command --assignee \"$assignee\""
            end
        end
    end

    if test -n "$pr_reviewers"
        # Split comma-separated reviewers and add each one
        for reviewer in (string split ',' "$pr_reviewers")
            set reviewer (string trim "$reviewer")
            if test -n "$reviewer"
                set gh_command "$gh_command --reviewer \"$reviewer\""
            end
        end
    end

    if test -n "$pr_labels"
        # Split comma-separated labels and add each one with --label flag
        for label in (string split ',' "$pr_labels")
            set label (string trim "$label")
            if test -n "$label"
                set gh_command "$gh_command --label \"$label\""
            end
        end
    end

    if test -n "$pr_milestone"
        set gh_command "$gh_command --milestone \"$pr_milestone\""
    end

    # Add editor flag
    set gh_command "$gh_command --editor"

    # Copy the gh command to clipboard
    printf '%s\n' "$gh_command" | pbcopy
    _agent_clipboard "GitHub pull request command copied to clipboard (with --editor flag):"
    echo "   $gh_command"
end

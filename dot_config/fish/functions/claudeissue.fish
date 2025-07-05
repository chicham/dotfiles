# =============================================================================
# claudeissue
#
# Author: Refactored for maintainability
# Last Updated: 2025-07-04
#
# Generates a comprehensive GitHub issue by calling Claude Code's /create-issue command.
# This script uses Claude Code's structured output parsing.
# =============================================================================

# Parse command line arguments and return parsed values
function _claudeissue_parse_args
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
function _claudeissue_show_help
    echo "Usage: claudeissue [OPTIONS] <issue_description>" >&2
    echo "" >&2
    echo "Creates a comprehensive GitHub issue description using AI analysis." >&2
    echo "The issue_description argument describes what the issue accomplishes." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --model MODEL     Specify Claude model (default: claude-3-5-haiku@20241022)" >&2
    echo "  -h, --help        Show this help message" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  claudeissue implement user authentication system" >&2
    echo "  claudeissue fix login validation bug" >&2
    echo "  claudeissue add search functionality --model claude-3-5-sonnet@20241022" >&2
end

# Generates a comprehensive GitHub issue description
function claudeissue -d "Generate comprehensive GitHub issue using Claude Code"
    # This function uses Claude Code's /create-issue command to generate structured issue data.

    # Parse arguments using local variables
    set -l parse_result (_claudeissue_parse_args $argv)
    or return 2

    # Extract parsed values
    set -l help false
    set -l model "claude-3-5-haiku@20241022"
    set -l issue_description ""

    for line in $parse_result
        set -l key_value (string split "=" $line)
        switch $key_value[1]
            case "help"
                set help $key_value[2]
            case "model"
                set model $key_value[2]
            case "description"
                set issue_description $key_value[2]
        end
    end

    if test "$help" = "true"
        _claudeissue_show_help
        return 0
    end

    if test -z "$issue_description"
        _agent_error "Missing issue description" "Use -h or --help for more information"
        return 1
    end

    _agent_info "Generating comprehensive GitHub issue with AI..."

    # Build claude command arguments
    set -l claude_args --model "$model" -p

    # Call claude with the create-issue command
    set -l response
    begin
        set -l IFS
        set response (claude $claude_args "/create-issue $issue_description" 2>/dev/null)
    end

    if test -z "$response"
        echo "Error: Received an empty response from Claude." >&2
        return 1
    end

    # Extract fields from the structured response
    set -l issue_title
    set -l issue_body
    set -l issue_assignees
    set -l issue_labels
    set -l issue_milestone
    set -l issue_project

    begin
        set -l IFS
        # Extract single-line fields using utility functions
        set issue_title (_agent_extract_field "$response" "TITLE")
        set issue_assignees (_agent_extract_field "$response" "ASSIGNEES")
        set issue_labels (_agent_extract_field "$response" "LABELS")
        set issue_milestone (_agent_extract_field "$response" "MILESTONE")
        set issue_project (_agent_extract_field "$response" "PROJECT")

        # Extract multiline BODY field using utility function
        set issue_body (_agent_extract_body_field "$response")
    end

    if not _agent_validate_response "$issue_title"
        return 1
    end

    # Display the extracted issue information using bat for better readability
    begin
        echo ""
        echo "📋 GitHub Issue:"
        echo "Title: $issue_title"
        if test -n "$issue_labels"
            echo "Labels: $issue_labels"
        end
        if test -n "$issue_body"
            echo ""
            echo "Description:"
            printf '%s\n' "$issue_body"
        end
        echo ""
    end | _agent_display_with_bat

    # Build the gh command with all available fields
    set -l gh_command "gh issue create"

    # Add required fields
    set gh_command "$gh_command --title \"$issue_title\""
    set gh_command "$gh_command --body \"$issue_body\""

    # Add optional fields if present
    if test -n "$issue_assignees"
        # Split comma-separated assignees and add each one
        for assignee in (string split ',' "$issue_assignees")
            set assignee (string trim "$assignee")
            if test -n "$assignee"
                set gh_command "$gh_command --assignee \"$assignee\""
            end
        end
    end

    if test -n "$issue_labels"
        # Split comma-separated labels and add each one
        for label in (string split ',' "$issue_labels")
            set label (string trim "$label")
            if test -n "$label"
                set gh_command "$gh_command --label \"$label\""
            end
        end
    end

    if test -n "$issue_milestone"
        set gh_command "$gh_command --milestone \"$issue_milestone\""
    end

    if test -n "$issue_project"
        set gh_command "$gh_command --project \"$issue_project\""
    end

    # Add editor flag
    set gh_command "$gh_command --editor"

    # Copy the gh command to clipboard
    printf '%s\n' "$gh_command" | pbcopy
    _agent_clipboard "GitHub issue command copied to clipboard (with --editor flag):"
    echo "   $gh_command"
end

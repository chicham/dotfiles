# =============================================================================
# agentcommit
#
# Author: Refactored for maintainability
# Last Updated: 2025-06-30
#
# Generates a conventional commit message from staged git changes by calling
# the `agentask` command. This script is separate from `agentask`.
# =============================================================================

# Parse command line arguments and set flags
function _agentcommit_parse_args
    set -g _agentcommit_args
    set -g _agentcommit_dry_run false
    set -g _agentcommit_help false

    for arg in $argv
        switch $arg
            case '-d' '--dry-run'
                set _agentcommit_dry_run true
            case '-h' '--help'
                set _agentcommit_help true
            case '*'
                set -a _agentcommit_args $arg
        end
    end
end

# Display help message
function _agentcommit_show_help
    echo "Usage: agentcommit [OPTIONS] [<agentask_options>]" >&2
    echo "" >&2
    echo "Analyzes staged git changes and generates a conventional commit message." >&2
    echo "All unknown options are passed directly to the 'agentask' command." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -d, --dry-run     Skip the AI call and use a generic commit message for testing." >&2
    echo "  -h, --help        Show this help message." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  agentcommit --agent claude --model claude-3-5-haiku@20241022" >&2
end

# Generates a conventional commit message from staged git changes.
function agentcommit -d "Generate atomic commit messages using AI agent"
    # This function depends on the `agentask` command being available in the shell environment.

    # Parse arguments
    _agentcommit_parse_args $argv

    if $_agentcommit_help
        _agentcommit_show_help
        set -e _agentcommit_args _agentcommit_dry_run _agentcommit_help
        return 0
    end

    set -l response ""

    # Check for staged changes before proceeding
    if git diff --staged --quiet
        echo "No staged changes to commit. Use 'git add' to stage files." >&2
        return 1
    end

    # --- Commit Prompt Based on commit.md Instructions ---
    # Define the specific prompt for generating a commit message.
    set -l commit_prompt 'Analyze the diff context above and generate a conventional commit message.

**Requirements:**
- Follow conventional commit format: type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore, ci
- Keep subject line under 50 characters, imperative mood, capitalize, no period
- If multiple atomic changes in files, use generic summary title with detailed body
- Include body for complex changes explaining what and why
- Separate subject and body with blank line, wrap body at 72 characters

**Body Content Requirements:**
- Use bullet points to describe each logical change or feature modification
- Each bullet point should represent a distinct change in the diff
- Start each bullet with "- " followed by a concise description
- Focus on WHAT was changed and WHY it was necessary
- Wrap each line at 72 characters maximum
- Do NOT use section headers or groupings like "- agentask:" or "- file:"
- Each bullet point should be a complete, standalone description

**Critical Output Rules:**
- Respond with ONLY the commit message text
- Do NOT include git commands or markdown code blocks
- Do NOT add any explanatory text before or after the message
- Format with proper line breaks between subject and body
- The subject line goes on the first line
- Insert a blank line after the subject
- Body text goes on subsequent lines

**REQUIRED FORMAT EXAMPLE:**
feat(scope): subject line here

- Describe what was changed in this logical unit with proper
  line wrapping at 72 characters
- Explain another distinct change or improvement made
- Add details about configuration or setup changes'

    # Add --dry-run flag to agentask args if in dry run mode
    if $_agentcommit_dry_run
        set -a _agentcommit_args --dry-run
    else
        echo "🤖 Analyzing staged changes with AI..." >&2
    end

    # Call agentask, piping the git diff and passing through all arguments
    if $_agentcommit_dry_run
        # In dry run mode, let agentask show its output to stderr, then use fake response
        git -c color.ui=false --no-pager diff --staged | agentask $_agentcommit_args "$commit_prompt"

        # Generate fake response for parsing demonstration
        set response 'feat(fish): update agentcommit with improved commit instructions

- Add conventional commit format requirements and enforce single atomic
  commit generation with proper markdown block output formatting
- Simplify prompt to output only commit message text
- Remove complex extraction process for git commands'
    else
        # Check if debug flag is in agentask_args to avoid suppressing stderr
        set -l suppress_stderr true
        for arg in $_agentcommit_args
            if test "$arg" = "--debug"
                set suppress_stderr false
                break
            end
        end

        if $suppress_stderr
            begin
                set -l IFS
                set response (git -c color.ui=false --no-pager diff --staged | agentask $_agentcommit_args "$commit_prompt" 2>/dev/null)
            end
        else
            begin
                set -l IFS
                set response (git -c color.ui=false --no-pager diff --staged | agentask $_agentcommit_args "$commit_prompt")
            end
        end

        if test -z "$response"
            echo "Error: Received an empty response from the AI agent." >&2
            return 1
        end
    end


    # --- PARSING AND DISPLAY BLOCK ---
    # The response is now just the commit message, no need for complex extraction
    set -l commit_message
    begin
        set -l IFS
        set commit_message (string trim -- "$response")
    end

    if test -z "$commit_message"
        echo "" >&2
        echo "Error: Received an empty commit message from the AI agent." >&2
        echo "The raw response has been copied to your clipboard for inspection." >&2
        echo "$response" | pbcopy
        return 1
    end

    # Display the commit message using bat for better readability
    printf '%s\n' "$commit_message" | bat --language markdown --style plain --paging never

    # Create git command with --edit flag and copy to clipboard
    set -l git_command_with_editor "git commit --edit -m \"$commit_message\""

    printf '%s\n' "$git_command_with_editor" | pbcopy
    echo "📋 Commit command copied to clipboard"
end

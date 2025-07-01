# =============================================================================
# agentcommit
#
# Author: Refactored for maintainability
# Last Updated: 2025-06-30
#
# Generates a conventional commit message from staged git changes by calling
# the `agentask` command. This script is separate from `agentask`.
# =============================================================================

# Generates a conventional commit message from staged git changes.
function agentcommit -d "Generate atomic commit messages using AI agent"
    # Parse arguments using argparse - ignore unknown options to pass through to agentask
    argparse --ignore-unknown 'h/help' 'd/dry-run' -- $argv
    or return 2

    if set -ql _flag_help
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
        return 0
    end

    set -l response ""

    # Check for staged changes before proceeding
    if git diff --staged --quiet
        _agent_error "No staged changes to commit" "Use 'git add' to stage files first"
        return 1
    end

    # Get current branch name for potential issue detection
    set -l current_branch (git branch --show-current)

    # --- Commit Prompt Based on commit.md Instructions ---
    # Define the specific prompt for generating a commit message.
    set -l commit_prompt "Analyze the diff context above and generate a conventional commit message.

**Requirements:**
- Follow conventional commit format: type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore, ci
- Keep subject line under 50 characters, imperative mood, capitalize, no period
- If multiple atomic changes in files, use generic summary title with detailed body
- Include body for complex changes explaining what and why
- Separate subject and body with blank line, wrap body at 72 characters

**Issue Linking (when applicable):**
- Current branch: $current_branch
- If the changes fix a bug or resolve an issue AND you can extract an issue number from the branch name (e.g., fix/123-description → #123, feature/456-name → #456), include Fixes #issue-number in the commit body
- Only include issue linking if the changes actually resolve/fix something, not for regular feature additions unless they specifically address an open issue
- Issue linking syntax: Fixes #123, Closes #456, or Resolves #789

**Body Content Requirements:**
- Use bullet points to describe each logical change or feature modification
- Each bullet point should represent a distinct change in the diff
- Start each bullet with - followed by a concise description
- Focus on WHAT was changed and WHY it was necessary
- Wrap each line at 72 characters maximum
- Do NOT use section headers or groupings like agentask or file prefixes
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
- Add details about configuration or setup changes

**EXAMPLE WITH ISSUE LINKING (only when changes fix an issue):**
fix(auth): resolve login validation error

- Fix null pointer exception in user validation logic
- Add proper error handling for malformed email addresses
- Update tests to cover edge cases

Fixes #123"

    # Build agentask arguments from remaining argv (unknown options)
    set -l agentask_args $argv
    if set -ql _flag_dry_run
        set -a agentask_args --dry-run
    else
        _agent_info "Generating commit message with AI..."
    end

    # Call agentask, piping the git diff and passing through all arguments
    set -l response
    if set -ql _flag_dry_run
        # In dry run mode, let agentask show its output to stderr, then use fake response
        git -c color.ui=false --no-pager diff --staged | agentask $agentask_args "$commit_prompt"

        # Generate fake response for parsing demonstration
        set response 'feat(fish): update agentcommit with improved commit instructions

- Add conventional commit format requirements and enforce single atomic
  commit generation with proper markdown block output formatting
- Simplify prompt to output only commit message text
- Remove complex extraction process for git commands
- Add issue linking support for bug fixes and issue resolution

Fixes #456'
    else
        # Use utility function to determine stderr suppression
        if _agent_should_suppress_stderr $agentask_args
            begin
                set -l IFS
                set response (git -c color.ui=false --no-pager diff --staged | agentask $agentask_args "$commit_prompt" 2>/dev/null)
            end
        else
            begin
                set -l IFS
                set response (git -c color.ui=false --no-pager diff --staged | agentask $agentask_args "$commit_prompt")
            end
        end
    end


    # --- PARSING AND DISPLAY BLOCK ---
    # The response is now just the commit message, no need for complex extraction
    set -l commit_message
    begin
        set -l IFS
        set commit_message (string trim -- "$response")
    end

    if not _agent_validate_response "$commit_message"
        return 1
    end

    # Display the commit message using bat for better readability
    printf '%s\n' "$commit_message" | _agent_display_with_bat

    # Create git command with --edit flag and copy to clipboard
    set -l git_command_with_editor "git commit --edit -m \"$commit_message\""

    printf '%s\n' "$git_command_with_editor" | pbcopy
    _agent_clipboard "Git commit command copied to clipboard"
end

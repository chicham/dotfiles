# =============================================================================
# agentpr
#
# Author: Refactored for maintainability
# Last Updated: 2025-06-30
#
# Generates a comprehensive GitHub pull request by calling the `agentask` command.
# This script is separate from `agentask`.
# =============================================================================

# Parse command line arguments and set flags
function _agentpr_parse_args
    set -g _agentpr_args
    set -g _agentpr_description
    set -g _agentpr_all_files false
    set -g _agentpr_dry_run false
    set -g _agentpr_help false
    set -g _agentpr_debug false

    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        switch $arg
            case '-a' '--all_files'
                set _agentpr_all_files true
            case '-d' '--dry-run'
                set _agentpr_dry_run true
            case '-h' '--help'
                set _agentpr_help true
            case '--debug'
                set _agentpr_debug true
            case '--agent' '--model'
                # These take a value, add both flag and value to agentask args
                set -a _agentpr_args $arg
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set -a _agentpr_args $argv[$i]
                end
            case '--*' '-*'
                # Other flags go to agentask
                set -a _agentpr_args $arg
            case '*'
                # Non-flag arguments are description
                set -a _agentpr_description $arg
        end
        set i (math $i + 1)
    end
end

# Display help message
function _agentpr_show_help
    echo "Usage: agentpr [OPTIONS] <pr_description> [<agentask_options>]" >&2
    echo "" >&2
    echo "Creates a comprehensive GitHub pull request for the current branch using AI analysis." >&2
    echo "The pr_description argument describes what the PR accomplishes." >&2
    echo "All unknown options are passed directly to the 'agentask' command." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -a, --all_files   Browse entire repository for context" >&2
    echo "  -d, --dry-run     Skip the AI call and use a generic PR template for testing" >&2
    echo "  --debug           Show detailed input/output information during execution" >&2
    echo "  -h, --help        Show this help message" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  agentpr implement user authentication system" >&2
    echo "  agentpr -a fix login validation bug" >&2
    echo "  agentpr add search functionality --agent claude --model claude-3-5-haiku@20241022" >&2
end

# Generates a comprehensive GitHub pull request description
function agentpr -d "Generate comprehensive GitHub pull request using AI agent"
    # This function depends on the `agentask` command being available in the shell environment.

    # Parse arguments
    _agentpr_parse_args $argv

    if $_agentpr_help
        _agentpr_show_help
        set -e _agentpr_args _agentpr_description _agentpr_all_files _agentpr_dry_run _agentpr_help _agentpr_debug
        return 0
    end

    set -l response ""
    set -l pr_description ""
    if test (count $_agentpr_description) -gt 0
        set pr_description (string join " " $_agentpr_description)
    end

    # Get current branch name
    set -l current_branch (git branch --show-current)

    # --- Pull Request Prompt Based on create-pr.md Instructions ---
    # Define the specific prompt for generating a GitHub pull request.
    set -l pr_prompt "Create pull request for branch '$current_branch': $pr_description

**Process:**
1. **Extract issue number** - From arguments or branch name pattern (e.g., \`123-feature\` → #123)
2. **Verify status** - Check for uncommitted changes, ask user if found
3. **Analyze commits** - Review commit history to generate comprehensive description
4. **Push and create PR** - Push branch, create PR with proper title format

**Pull Request Requirements:**
- **Mandatory title format**: \"Fixes #issue-number: Brief description\"
- **Must link to an issue**: Every PR must reference an existing issue
- **Description requirements**:
  - Summary of changes
  - Testing performed
  - Breaking changes (if any)
  - Screenshots/demos for UI changes

**Instructions:**
1. Analyze the commit history provided above to understand what changes will be included in this PR from branch '$current_branch'
2. If no commit history is provided, create a generic PR based on the description: \"$pr_description\"
3. Extract issue number from the branch name '$current_branch' (e.g., feature/123-description → #123) or use a placeholder if none found
4. Create descriptive PR title: \"Fixes #issue-number: Detailed description of what was implemented\"
5. Generate comprehensive PR description based on the commit messages (or description if no commits) using GitHub markdown

**Required Sections:**
- ## Summary (summarize what the commits in this branch accomplish)
- ## Changes Made (summarize the key changes based on commit messages)
- ## Test Plan (only if manual testing is needed)
- ## Breaking Changes (only if there are breaking changes)

**Critical Output Rules:**
- Respond with ONLY a gh command enclosed in <github> tags
- Include complete PR details in the --body argument with proper escaping
- Use proper GitHub markdown formatting with proper newlines between sections
- Do NOT add any explanatory text before or after the tags

**REQUIRED FORMAT:**
<github>
gh pr create --title \\\"Fixes #issue-number: [complete PR title]\\\" --body \\\"[complete escaped body with all sections: Summary, Changes Made, Test Plan, Breaking Changes]\\\"
</github>"

    # Add flags to agentask args if requested
    if $_agentpr_all_files
        set -a _agentpr_args --all_files
    end

    if $_agentpr_dry_run
        set -a _agentpr_args --dry-run
    end

    if $_agentpr_debug
        set -a _agentpr_args --debug
    end

    # Show debug information for the prompt if requested
    if $_agentpr_debug
        echo "" >&2
        echo "🐛 DEBUG - PR Prompt:" >&2
        echo "====================" >&2
        echo -e "$pr_prompt" >&2
        echo "====================" >&2
        echo "" >&2
        echo "🐛 DEBUG - agentask args: $_agentpr_args" >&2
        echo "" >&2
    end

    if not $_agentpr_dry_run
        echo "🤖 Generating comprehensive GitHub pull request with AI..." >&2
    end

    # Call agentask with the PR prompt and git log context
    if $_agentpr_dry_run
        # In dry run mode, let agentask handle the dry run display including git logs
        begin
            set -l IFS
            set response (git log --pretty=format:"%h %s" --no-merges origin/main..HEAD | agentask $_agentpr_args "$pr_prompt")
        end

        # Generate fake response for parsing demonstration (includes text outside tags to verify parsing)
        set response 'I\'ll analyze your current branch and create a comprehensive GitHub pull request.

After reviewing the commit history, here\'s what I recommend:

<github>
gh pr create --title "Fixes #123: implement comprehensive user authentication system" --body "## Summary\\nImplemented a secure and robust user authentication system with registration, login, logout, and password management features. This PR adds all the necessary components for a complete authentication workflow following modern security best practices.\\n\\n## Changes Made\\n- \`src/auth/controller.js\`: Added authentication endpoints (register, login, logout, password reset)\\n- \`src/auth/middleware.js\`: Implemented JWT token validation and session management\\n- \`src/models/user.js\`: Created user model with bcrypt password hashing\\n- \`src/routes/auth.js\`: Added authentication routes with proper validation\\n- \`tests/auth/\`: Added comprehensive test suite for all authentication flows\\n- \`docs/api/auth.md\`: Updated API documentation\\n\\n## Test Plan\\n- [ ] User registration with email validation\\n- [ ] Login with valid credentials\\n- [ ] Login with invalid credentials (should fail)\\n- [ ] Password reset workflow\\n- [ ] Session management and token expiration\\n- [ ] Rate limiting on authentication endpoints\\n- [ ] All existing tests continue to pass\\n\\n## Breaking Changes\\nNone. This is a new feature that doesn\'t affect existing functionality."
</github>

This pull request includes all the authentication system components with proper security measures and comprehensive testing. The implementation follows best practices and maintains backward compatibility.'
    else
        # Check if debug flag is in agentask_args to avoid suppressing stderr
        set -l suppress_stderr true
        for arg in $_agentpr_args
            if test "$arg" = "--debug"
                set suppress_stderr false
                break
            end
        end

        if $suppress_stderr
            begin
                set -l IFS
                set response (git log --pretty=format:"%h %s" --no-merges origin/main..HEAD | agentask $_agentpr_args "$pr_prompt" 2>/dev/null)
            end
        else
            begin
                set -l IFS
                set response (git log --pretty=format:"%h %s" --no-merges origin/main..HEAD | agentask $_agentpr_args "$pr_prompt")
            end
        end

        if test -z "$response"
            echo "Error: Received an empty response from the AI agent." >&2
            set -e _agentpr_args _agentpr_description _agentpr_all_files _agentpr_dry_run _agentpr_help _agentpr_debug
            return 1
        end
    end

    # --- PARSING AND DISPLAY BLOCK ---
    # Show debug information for the raw response if requested
    if $_agentpr_debug
        echo "" >&2
        echo "🐛 DEBUG - Raw AI Response:" >&2
        echo "============================" >&2
        echo "$response" >&2
        echo "============================" >&2
        echo "" >&2
    end

    # Extract the gh command from within <github> tags
    set -l gh_command
    begin
        set -l IFS
        # Extract content between <github> and </github> tags, handling multiline content
        set gh_command (printf '%s\n' "$response" | sed -n '/<github>/,/<\/github>/p' | sed '1s/<github>//; $s/<\/github>//' | string join '\n' | string trim)
    end

    # Show debug information for the extracted command if requested
    if $_agentpr_debug
        echo "" >&2
        echo "🐛 DEBUG - Extracted gh command:" >&2
        echo "================================" >&2
        echo "$gh_command" >&2
        echo "================================" >&2
        echo "" >&2
    end

    if test -z "$gh_command"
        echo "" >&2
        echo "Error: Could not find gh command within <github> tags." >&2
        echo "The raw response has been copied to your clipboard for inspection." >&2
        echo "$response" | pbcopy
        set -e _agentpr_args _agentpr_description _agentpr_all_files _agentpr_dry_run _agentpr_help _agentpr_debug
        return 1
    end

    # Extract title and body from the gh command using awk and printf
    set -l pr_title
    set -l pr_body
    begin
        set -l IFS
        set pr_title (printf '%s\n' "$gh_command" | awk -F'--title "' '{if(NF>1){split($2,a,"\""); print a[1]}}')
        set -l raw_body (printf '%s\n' "$gh_command" | awk -F'--body "' '{if(NF>1){split($2,a,"\""); print a[1]}}')
        # Convert \n sequences to actual newlines for display
        set pr_body (printf "$raw_body" | sed 's/\\n/\n/g')
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
    end | bat --language markdown --style plain --paging never

    # Modify gh command to open in editor
    set -l gh_command_with_editor (string replace "gh pr create" "gh pr create --editor" "$gh_command")

    # Copy the gh command to clipboard
    printf '%s\n' "$gh_command_with_editor" | pbcopy
    echo "📋 GitHub pull request command copied to clipboard (with --editor flag):"
    echo "   $gh_command_with_editor"

    # Clean up global variables
    set -e _agentpr_args _agentpr_description _agentpr_all_files _agentpr_dry_run _agentpr_help _agentpr_debug
end

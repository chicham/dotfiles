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
2. **Analyze commits** - Review commit history to generate comprehensive description
3. **Parse user instructions** - Extract any specific requirements from the description: \"$pr_description\"
4. **Generate structured output** - Output specific fields for PR creation

**Pull Request Requirements:**
- **Title format**: \"Brief description\" (clean title without issue linking syntax)
- **Issue linking**: Reference issues via commit messages OR PR body, but avoid duplication
- **Description requirements**:
  - Summary of changes
  - Testing performed
  - Breaking changes (if any)
  - Screenshots/demos for UI changes

**Instructions:**
1. Analyze the commit history provided above to understand what changes will be included in this PR from branch '$current_branch'
2. If no commit history is provided, create a generic PR based on the description: \"$pr_description\"
3. **Check commit messages for existing issue linking**: Look for 'Fixes #', 'Closes #', 'Resolves #' keywords in commit messages
4. Extract issue number from the branch name '$current_branch' (e.g., feature/123-description → #123) or use a placeholder if none found
5. Create descriptive PR title: \"Detailed description of what was implemented\"
6. Generate comprehensive PR description based on the commit messages (or description if no commits) using GitHub markdown
7. **Parse user instructions**: Look for specific field requests in \"$pr_description\" such as:
   - Assignee mentions (\"assign to @username\" or \"assignee: username\")
   - Reviewer requests (\"review by @team\" or \"reviewer: username\")
   - Label specifications (\"label: bug\" or \"labels: enhancement,feature\")
   - Draft status (\"draft\" or \"WIP\")
   - Milestone mentions (\"milestone: v1.0\")
   - Base branch (\"base: develop\" or \"target: main\")

**Required Sections:**
- ## Summary (summarize what the commits in this branch accomplish)
- ## Changes Made (summarize the key changes based on commit messages)
- ## Test Plan (only if manual testing is needed)
- ## Breaking Changes (only if there are breaking changes)

**Issue Linking Rules:**
- **If any commit message already contains issue linking keywords** (Fixes #, Closes #, Resolves #), DO NOT add additional \"Fixes #issue-number\" to the PR body
- **Only add \"Fixes #issue-number\" to the PR body if NO commits contain issue linking keywords** and an issue number can be extracted from the branch name
- This prevents duplicate issue linking which can cause confusion

**CRITICAL: FOLLOW OUTPUT FORMAT EXACTLY**
- You MUST respond with ONLY the structured fields listed below
- Do NOT include any explanatory text, introductions, or conclusions
- Do NOT add phrases like \"Here's the pull request\" or \"Based on the analysis\"
- Do NOT include any text before the first TITLE: line
- Do NOT include any text after the last field
- Your response must start immediately with \"TITLE:\" and end with the last field value
- Use proper GitHub markdown formatting only within the BODY field content
- Generate additional fields based on user instructions and commit analysis

**EXACT REQUIRED FORMAT (your entire response must match this structure):**
TITLE: [complete PR title]
BODY: [complete PR body with all sections using GitHub markdown]
BASE: [target branch, typically 'main' or as specified by user]
DRAFT: [true/false - true if incomplete, WIP, or user specified draft]
ASSIGNEES: [comma-separated list of GitHub usernames from user instructions or empty]
REVIEWERS: [comma-separated list of GitHub usernames/teams from user instructions or empty]
LABELS: [comma-separated list of labels from user instructions or inferred from changes]
MILESTONE: [milestone name from user instructions or empty]"

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
        _agent_debug "PR Prompt" "$pr_prompt"
        _agent_debug "agentask args: $_agentpr_args"
    end

    if not $_agentpr_dry_run
        _agent_info "Generating comprehensive GitHub pull request with AI..."
    end

    # Call agentask with the PR prompt and git log context
    if $_agentpr_dry_run
        # In dry run mode, let agentask handle the dry run display including git logs
        begin
            set -l IFS
            set response (git log --pretty=format:"%h %s" --no-merges origin/main..HEAD | agentask $_agentpr_args "$pr_prompt")
        end

        # Generate fake response for parsing demonstration
        set response 'TITLE: Implement comprehensive user authentication system
BODY: ## Summary
Implemented a secure and robust user authentication system with registration, login, logout, and password management features. This PR adds all the necessary components for a complete authentication workflow following modern security best practices.

## Changes Made
- `src/auth/controller.js`: Added authentication endpoints (register, login, logout, password reset)
- `src/auth/middleware.js`: Implemented JWT token validation and session management
- `src/models/user.js`: Created user model with bcrypt password hashing
- `src/routes/auth.js`: Added authentication routes with proper validation
- `tests/auth/`: Added comprehensive test suite for all authentication flows
- `docs/api/auth.md`: Updated API documentation

## Test Plan
- [ ] User registration with email validation
- [ ] Login with valid credentials
- [ ] Login with invalid credentials (should fail)
- [ ] Password reset workflow
- [ ] Session management and token expiration
- [ ] Rate limiting on authentication endpoints
- [ ] All existing tests continue to pass

## Breaking Changes
None. This is a new feature that doesn\'t affect existing functionality.
BASE: main
DRAFT: false
ASSIGNEES: @me
REVIEWERS: team-security,john-doe
LABELS: enhancement,security
MILESTONE: v2.0'
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
        _agent_debug "Raw AI Response" "$response"
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
        # Extract single-line fields
        set pr_title (printf '%s\n' "$response" | grep '^TITLE:' | sed 's/^TITLE: *//')
        set pr_base (printf '%s\n' "$response" | grep '^BASE:' | sed 's/^BASE: *//')
        set pr_draft (printf '%s\n' "$response" | grep '^DRAFT:' | sed 's/^DRAFT: *//')
        set pr_assignees (printf '%s\n' "$response" | grep '^ASSIGNEES:' | sed 's/^ASSIGNEES: *//')
        set pr_reviewers (printf '%s\n' "$response" | grep '^REVIEWERS:' | sed 's/^REVIEWERS: *//')
        set pr_labels (printf '%s\n' "$response" | grep '^LABELS:' | sed 's/^LABELS: *//')
        set pr_milestone (printf '%s\n' "$response" | grep '^MILESTONE:' | sed 's/^MILESTONE: *//')

        # Extract multiline BODY field - from BODY: line until next field or end
        set pr_body (printf '%s\n' "$response" | awk '/^BODY: */ {
            sub(/^BODY: */, "");
            body = $0;
            while ((getline line) > 0 && line !~ /^[A-Z]+: */) {
                if (body) body = body "\n" line; else body = line;
            }
            print body;
            exit
        }')
    end

    # Show debug information for the extracted fields if requested
    if $_agentpr_debug
        set -l fields_debug "TITLE: $pr_title
BASE: $pr_base
DRAFT: $pr_draft
ASSIGNEES: $pr_assignees
REVIEWERS: $pr_reviewers
LABELS: $pr_labels
MILESTONE: $pr_milestone
BODY:
$pr_body"
        _agent_debug "Extracted fields" "$fields_debug"
    end

    if not _agent_validate_response "$pr_title"
        set -e _agentpr_args _agentpr_description _agentpr_all_files _agentpr_dry_run _agentpr_help _agentpr_debug
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
        # Split comma-separated labels and add each one
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

    # Clean up global variables
    set -e _agentpr_args _agentpr_description _agentpr_all_files _agentpr_dry_run _agentpr_help _agentpr_debug
end

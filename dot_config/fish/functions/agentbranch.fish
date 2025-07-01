# =============================================================================
# agentbranch
#
# Author: AI-generated based on agentcommit and agentissue patterns
# Last Updated: 2025-07-01
#
# Generates a branch name from repository changes by calling the `agentask` command.
# This script is separate from `agentask`.
# =============================================================================

# Generates a branch name with an AI-generated name based on repository changes
function agentbranch -d "Generate branch name with AI based on repository changes"
    # Parse arguments using argparse - ignore unknown options to pass through to agentask
    argparse --ignore-unknown 'h/help' 'd/dry-run' 'debug' 'i/issue=' -- $argv
    or return 2

    if set -ql _flag_help
        echo "Usage: agentbranch [OPTIONS] [<agentask_options>]" >&2
        echo "" >&2
        echo "Analyzes repository changes and generates a branch name with AI assistance." >&2
        echo "The branch name follows conventional patterns: feature/brief-description or fix/brief-description." >&2
        echo "When an issue is provided, branch name will be: feature/123-derived-from-issue." >&2
        echo "All unknown options are passed directly to the 'agentask' command." >&2
        echo "" >&2
        echo "Options:" >&2
        echo "  -i, --issue NUM   Use GitHub issue context for branch naming (format: feature/NUM-description)" >&2
        echo "  -d, --dry-run     Skip the AI call and use a generic branch name for testing." >&2
        echo "  --debug           Show detailed input/output information during execution." >&2
        echo "  -h, --help        Show this help message." >&2
        echo "" >&2
        echo "Examples:" >&2
        echo "  agentbranch --issue 123" >&2
        echo "  agentbranch --agent claude --model claude-3-5-haiku@20241022" >&2
        return 0
    end

    # Fetch issue context if provided
    set -l issue_context ""
    if set -ql _flag_issue
        _agent_info "Fetching issue #$_flag_issue context..."
        set issue_context (gh issue view $_flag_issue --json title,body --template '=== Issue #{{.number}} ===
Title: {{.title}}

Body:
{{.body}}')

        if test $status -ne 0
            _agent_error "Could not fetch issue #$_flag_issue" "Check if the issue exists and you have access"
            return 1
        end
    end

    # Check if we're on main branch and have changes
    set -l current_branch (git branch --show-current)
    if test "$current_branch" != "main"
        _agent_warning "Not on main branch. Currently on: $current_branch"
        _agent_suggestion "Switch to main first with 'git checkout main'"
    end

    # Check for any changes (staged, unstaged, or untracked)
    set -l has_changes false

    # Check for staged changes
    if not git diff --staged --quiet
        set has_changes true
    end

    # Check for unstaged changes
    if not git diff --quiet
        set has_changes true
    end

    # Check for untracked files
    if test (git ls-files --others --exclude-standard | wc -l) -gt 0
        set has_changes true
    end

    if not $has_changes
        _agent_error "No changes detected in repository" "Make some changes first to base branch name on"
        return 1
    end

    # --- Branch Naming Prompt Based on fix-issue.md patterns ---
    set -l branch_prompt
    if set -ql _flag_issue
        set branch_prompt "Analyze the GitHub issue and repository changes to generate an appropriate branch name.

**IMPORTANT: Issue-based branch naming format required**
- MUST use format: feature/$_flag_issue-brief-description
- Replace 'brief-description' with 2-4 kebab-case words derived from issue title/body
- Examples: feature/123-user-authentication, feature/456-login-validation

**Context:** GitHub issue details and current repository file changes.

**Analysis Guidelines:**
- Primary: Use issue title and body to understand the intended work
- Secondary: Consider actual file changes to refine the description
- Focus on the main feature/fix described in the issue
- Use clear, descriptive terms that match the issue intent

**Critical Output Rules:**
- Respond with ONLY the branch name
- No explanatory text, commands, or markdown
- MUST start with: feature/$_flag_issue-
- Example: feature/$_flag_issue-user-auth-system"
    else
        set branch_prompt 'Analyze the repository changes and generate an appropriate branch name.

**Context:** Repository file changes including staged, unstaged, and untracked files.

**Requirements:**
- Follow conventional branch naming patterns:
  - Feature branches: feature/brief-description
  - Bug fixes: fix/brief-description
  - Hotfixes: hotfix/brief-description
  - Chores: chore/brief-description
- Use kebab-case for descriptions (lowercase with hyphens)
- Keep descriptions concise but descriptive (2-4 words)
- Infer branch type from the nature of changes

**Critical Output Rules:**
- Respond with ONLY the branch name
- No explanatory text, commands, or markdown
- Format: type/brief-description
- Examples: feature/user-auth, fix/login-validation, chore/update-deps'
    end

    # Build agentask arguments from remaining argv (unknown options)
    set -l agentask_args $argv
    if set -ql _flag_dry_run
        set -a agentask_args --dry-run
    end
    if set -ql _flag_debug
        set -a agentask_args --debug
    end

    # Show debug information for the prompt if requested
    if set -ql _flag_debug
        _agent_debug "Branch Naming Prompt" "$branch_prompt"
    end

    if not set -ql _flag_dry_run
        _agent_info "Generating branch name with AI..."
    end

    # Prepare minimal context data for branch naming
    set -l context_data ""

    # Add issue context if provided
    if set -ql _flag_issue
        set context_data "$context_data$issue_context\n\n"
    end

    # Add minimal file change summary
    set context_data "$context_data=== File Changes Summary ===\n"
    set context_data "$context_data"(git status --porcelain)

    # Add file names and change types only (no content)
    if not git diff --staged --quiet
        set context_data "$context_data\n=== Staged Files ===\n"
        set context_data "$context_data"(git diff --staged --name-status)
    end

    if not git diff --quiet
        set context_data "$context_data\n=== Modified Files ===\n"
        set context_data "$context_data"(git diff --name-status)
    end

    # Add untracked file names only (no content, limit to 10 files)
    set -l untracked_files (git ls-files --others --exclude-standard | head -10)
    if test (count $untracked_files) -gt 0
        set context_data "$context_data\n=== New Files ===\n"
        printf '%s\n' $untracked_files
    end

    # Call agentask with the branch naming prompt
    set -l response
    if set -ql _flag_dry_run
        # In dry run mode, simulate the call without actually executing agentask
        _agent_debug "DRY RUN - Would call agentask with context data"
        # Generate fake response for parsing demonstration
        if set -ql _flag_issue
            set response "feature/$_flag_issue-user-authentication-system"
        else
            set response 'feature/agent-branch-command'
        end
    else
        # Use utility function to determine stderr suppression
        if _agent_should_suppress_stderr $agentask_args
            set response (printf '%s\n' "$context_data" | agentask $agentask_args "$branch_prompt" 2>/dev/null)
        else
            set response (printf '%s\n' "$context_data" | agentask $agentask_args "$branch_prompt")
        end
    end

    # --- PARSING AND VALIDATION BLOCK ---
    set -l branch_name (string trim -- "$response")

    # Show debug information for the raw response if requested
    if set -ql _flag_debug
        _agent_debug "Raw AI Response" "$response"
        _agent_debug "Extracted branch name: $branch_name"
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

    # Display the proposed branch name using bat for better readability
    echo "🌿 Proposed branch: $branch_name" | _agent_display_with_bat

    # Create git command and copy to clipboard (don't execute)
    set -l git_command "git checkout -b $branch_name"
    printf '%s\n' "$git_command" | pbcopy
    _agent_clipboard "Git command copied to clipboard: $git_command"
end

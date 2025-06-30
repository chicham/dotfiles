# =============================================================================
# agentissue
#
# Author: Refactored for maintainability
# Last Updated: 2025-06-30
#
# Generates a comprehensive GitHub issue by calling the `agentask` command.
# This script is separate from `agentask`.
# =============================================================================

# Parse command line arguments and set flags
function _agentissue_parse_args
    set -g _agentissue_args
    set -g _agentissue_description
    set -g _agentissue_all_files false
    set -g _agentissue_dry_run false
    set -g _agentissue_help false
    set -g _agentissue_debug false

    set -l parsing_flags true
    for arg in $argv
        if test "$parsing_flags" = "true"
            switch $arg
                case '-a' '--all_files'
                    set _agentissue_all_files true
                case '-d' '--dry-run'
                    set _agentissue_dry_run true
                case '-h' '--help'
                    set _agentissue_help true
                case '--debug'
                    set _agentissue_debug true
                case '-*'
                    set -a _agentissue_args $arg
                case '*'
                    set parsing_flags false
                    set -a _agentissue_description $arg
            end
        else
            set -a _agentissue_description $arg
        end
    end
end

# Display help message
function _agentissue_show_help
    echo "Usage: agentissue [OPTIONS] <issue_description> [<agentask_options>]" >&2
    echo "" >&2
    echo "Creates a comprehensive GitHub issue description using AI analysis." >&2
    echo "All unknown options are passed directly to the 'agentask' command." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -a, --all_files   Browse entire repository for context" >&2
    echo "  -d, --dry-run     Skip the AI call and use a generic issue template for testing" >&2
    echo "  --debug           Show detailed input/output information during execution" >&2
    echo "  -h, --help        Show this help message" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  agentissue implement user authentication system" >&2
    echo "  agentissue -a fix login validation bug" >&2
    echo "  agentissue add search functionality --agent claude --model claude-3-5-haiku@20241022" >&2
end

# Generates a comprehensive GitHub issue description
function agentissue -d "Generate comprehensive GitHub issue using AI agent"
    # This function depends on the `agentask` command being available in the shell environment.

    # Parse arguments
    _agentissue_parse_args $argv

    if $_agentissue_help
        _agentissue_show_help
        set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help _agentissue_debug
        return 0
    end

    if test (count $_agentissue_description) -eq 0
        echo "Usage: agentissue [flags] <issue description>" >&2
        echo "Use -h or --help for more information." >&2
        set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help _agentissue_debug
        return 1
    end

    set -l response ""
    set -l issue_description (string join " " $_agentissue_description)

    # --- Issue Prompt Based on create-issue.md Instructions ---
    # Define the specific prompt for generating a GitHub issue.
    set -l issue_prompt "Create a comprehensive GitHub issue for: $issue_description

**Process:**
1. **Clarify requirements** - Infer missing details from context and provide comprehensive information
2. **Research context** - Consider existing codebase patterns and implementation details
3. **Parse user instructions** - Extract any specific requirements from the description: \"$issue_description\"
4. **Generate structured output** - Output specific fields for issue creation

**Required information:**
- Clear problem statement and expected outcome
- Steps to reproduce (bugs) or acceptance criteria (features)
- Technical requirements and constraints
- Appropriate labels (bug/feature/enhancement)

**Instructions:**
1. Analyze the issue description: \"$issue_description\"
2. **Parse user instructions**: Look for specific field requests in \"$issue_description\" such as:
   - Assignee mentions (\"assign to @username\" or \"assignee: username\")
   - Label specifications (\"label: bug\" or \"labels: enhancement,feature\")
   - Milestone mentions (\"milestone: v1.0\")
   - Project assignments (\"project: Roadmap\")
   - Template usage (\"template: Bug Report\")
3. Create comprehensive issue with proper GitHub markdown formatting
4. Structure the body with: Description, Acceptance Criteria, Technical Requirements, Implementation Notes

**CRITICAL: FOLLOW OUTPUT FORMAT EXACTLY**
- You MUST respond with ONLY the structured fields listed below
- Do NOT include any explanatory text, introductions, or conclusions
- Do NOT add phrases like \"Here's the issue\" or \"Based on the analysis\"
- Do NOT include any text before the first TITLE: line
- Do NOT include any text after the last field
- Your response must start immediately with \"TITLE:\" and end with the last field value
- Use proper GitHub markdown formatting only within the BODY field content
- Generate additional fields based on user instructions and issue analysis

**EXACT REQUIRED FORMAT (your entire response must match this structure):**
TITLE: [complete issue title]
BODY: [complete issue body with all sections using GitHub markdown]
ASSIGNEES: [comma-separated list of GitHub usernames from user instructions or empty]
LABELS: [comma-separated list of labels from user instructions or inferred from issue type]
MILESTONE: [milestone name from user instructions or empty]
PROJECT: [project name from user instructions or empty]"

    # Add --all_files flag to agentask args if requested
    if $_agentissue_all_files
        set -a _agentissue_args --all_files
    end

    # Add flags to agentask args
    if $_agentissue_dry_run
        set -a _agentissue_args --dry-run
    end

    if $_agentissue_debug
        set -a _agentissue_args --debug
    end

    # Show debug information for the prompt if requested
    if $_agentissue_debug
        echo "" >&2
        echo "🐛 DEBUG - Issue Prompt:" >&2
        echo "========================" >&2
        echo -e "$issue_prompt" >&2
        echo "========================" >&2
        echo "" >&2
    end

    if not $_agentissue_dry_run
        echo "🤖 Generating comprehensive GitHub issue with AI..." >&2
    end

    # Call agentask with the issue prompt
    if $_agentissue_dry_run
        # In dry run mode, let agentask show its output to stderr, then use fake response
        agentask $_agentissue_args "$issue_prompt"

        # Generate fake response for parsing demonstration
        set response 'TITLE: feat: implement comprehensive user authentication system
BODY: ## Description
Implement a secure and robust user authentication system that supports user registration, login, logout, and password management. This system should follow modern security best practices and integrate seamlessly with the existing application architecture.

## Acceptance Criteria
- [ ] Users can register with email and password
- [ ] Email validation during registration process
- [ ] Secure login with proper session management
- [ ] Logout functionality that properly clears sessions
- [ ] Password reset via email workflow
- [ ] Input validation and sanitization
- [ ] Rate limiting for authentication endpoints
- [ ] Proper error handling and user feedback

## Technical Requirements
- Use bcrypt for password hashing with minimum 12 rounds
- Implement JWT tokens for session management
- Add CSRF protection for authentication forms
- Follow existing database schema conventions
- Include comprehensive error logging
- Ensure compatibility with current middleware stack
- Add proper database migrations for user tables

## Implementation Notes
- Review existing user model structure in models/user.js
- Follow the authentication patterns used in the admin module
- Update the existing middleware/auth.js for new token handling
- Consider integration with the current email service
- Add unit tests following the patterns in tests/auth/
- Update API documentation in docs/api/
ASSIGNEES: @me
LABELS: feature,enhancement,security,backend
MILESTONE: v2.0
PROJECT: Authentication'
    else
        # Don't suppress stderr if debug mode is enabled
        if not $_agentissue_debug
            begin
                set -l IFS
                set response (agentask $_agentissue_args "$issue_prompt" 2>/dev/null)
            end
        else
            begin
                set -l IFS
                set response (agentask $_agentissue_args "$issue_prompt")
            end
        end

        if test -z "$response"
            echo "Error: Received an empty response from the AI agent." >&2
            set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help _agentissue_debug
            return 1
        end
    end

    # --- PARSING AND DISPLAY BLOCK ---
    # Show debug information for the raw response if requested
    if $_agentissue_debug
        echo "" >&2
        echo "🐛 DEBUG - Raw AI Response:" >&2
        echo "============================" >&2
        echo "$response" >&2
        echo "============================" >&2
        echo "" >&2
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
        # Extract single-line fields
        set issue_title (printf '%s\n' "$response" | grep '^TITLE:' | sed 's/^TITLE: *//')
        set issue_assignees (printf '%s\n' "$response" | grep '^ASSIGNEES:' | sed 's/^ASSIGNEES: *//')
        set issue_labels (printf '%s\n' "$response" | grep '^LABELS:' | sed 's/^LABELS: *//')
        set issue_milestone (printf '%s\n' "$response" | grep '^MILESTONE:' | sed 's/^MILESTONE: *//')
        set issue_project (printf '%s\n' "$response" | grep '^PROJECT:' | sed 's/^PROJECT: *//')

        # Extract multiline BODY field - from BODY: line until next field or end
        set issue_body (printf '%s\n' "$response" | awk '/^BODY: */ {
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
    if $_agentissue_debug
        echo "" >&2
        echo "🐛 DEBUG - Extracted fields:" >&2
        echo "============================" >&2
        echo "TITLE: $issue_title" >&2
        echo "ASSIGNEES: $issue_assignees" >&2
        echo "LABELS: $issue_labels" >&2
        echo "MILESTONE: $issue_milestone" >&2
        echo "PROJECT: $issue_project" >&2
        echo "BODY:" >&2
        printf '%s\n' "$issue_body" >&2
        echo "============================" >&2
        echo "" >&2
    end

    if test -z "$issue_title"
        echo "" >&2
        echo "Error: Could not extract TITLE field from response." >&2
        echo "The raw response has been copied to your clipboard for inspection." >&2
        echo "$response" | pbcopy
        set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help _agentissue_debug
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
    end | bat --language markdown --style plain --paging never

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
    echo "📋 GitHub issue command copied to clipboard (with --editor flag):"
    echo "   $gh_command"

    # Clean up global variables
    set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help
end

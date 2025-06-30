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
3. **Create comprehensive issue** - Include all necessary information for implementation

**Required information:**
- Clear problem statement and expected outcome
- Steps to reproduce (bugs) or acceptance criteria (features)
- Technical requirements and constraints
- Appropriate labels (bug/feature/enhancement)

**Critical Output Rules:**
- Respond with ONLY a gh command enclosed in <github> tags
- Include complete issue details in the --body argument with proper escaping
- Structure the body with: Description, Acceptance Criteria, Technical Requirements, Implementation Notes
- Do NOT add any explanatory text before or after the tags

**REQUIRED FORMAT:**
<github>
gh issue create --title \"[complete issue title]\" --body \"[complete escaped body with all sections: Description, Acceptance Criteria, Technical Requirements, Implementation Notes]\" --label \"[labels]\"
</github>"

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
        set response 'I\'ll analyze your request and create a comprehensive GitHub issue for implementing a user authentication system.

After reviewing the codebase, here\'s what I recommend:

<github>
gh issue create --title "feat: implement comprehensive user authentication system" --body "## Description\nImplement a secure and robust user authentication system that supports user registration, login, logout, and password management. This system should follow modern security best practices and integrate seamlessly with the existing application architecture.\n\n## Acceptance Criteria\n- [ ] Users can register with email and password\n- [ ] Email validation during registration process\n- [ ] Secure login with proper session management\n- [ ] Logout functionality that properly clears sessions\n- [ ] Password reset via email workflow\n- [ ] Input validation and sanitization\n- [ ] Rate limiting for authentication endpoints\n- [ ] Proper error handling and user feedback\n\n## Technical Requirements\n- Use bcrypt for password hashing with minimum 12 rounds\n- Implement JWT tokens for session management\n- Add CSRF protection for authentication forms\n- Follow existing database schema conventions\n- Include comprehensive error logging\n- Ensure compatibility with current middleware stack\n- Add proper database migrations for user tables\n\n## Implementation Notes\n- Review existing user model structure in models/user.js\n- Follow the authentication patterns used in the admin module\n- Update the existing middleware/auth.js for new token handling\n- Consider integration with the current email service\n- Add unit tests following the patterns in tests/auth/\n- Update API documentation in docs/api/" --label "feature,enhancement,security,backend"
</github>

This issue includes all the necessary details for implementing a secure authentication system that follows your project\'s existing patterns and best practices. The implementation should enhance security while maintaining a smooth user experience.'
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

    # Extract the gh command from within <github> tags using ripgrep
    set -l gh_command
    begin
        set -l IFS
        set gh_command (printf '%s\n' "$response" | rg -oP '<github>\K.*?(?=</github>)' | string trim)
    end

    # Show debug information for the extracted command if requested
    if $_agentissue_debug
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
        set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help _agentissue_debug
        return 1
    end

    # Extract title and body from the gh command using awk and printf
    set -l issue_title
    set -l issue_body
    set -l issue_labels
    begin
        set -l IFS
        set issue_title (printf '%s\n' "$gh_command" | awk -F'--title "' '{if(NF>1){split($2,a,"\""); print a[1]}}')
        set -l raw_body (printf '%s\n' "$gh_command" | awk -F'--body "' '{if(NF>1){split($2,a,"\" --"); print a[1]}}')
        set issue_body (printf "$raw_body")
        set issue_labels (printf '%s\n' "$gh_command" | awk -F'--label "' '{if(NF>1){split($2,a,"\""); print a[1]}}')
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
    end | bat --language markdown --style plain --paging always

    # Copy the gh command to clipboard
    printf '%s\n' "$gh_command" | pbcopy
    echo "📋 GitHub issue command copied to clipboard:"
    echo "   $gh_command"

    # Clean up global variables
    set -e _agentissue_args _agentissue_description _agentissue_all_files _agentissue_dry_run _agentissue_help
end

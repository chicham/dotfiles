# =============================================================================
# agentcommit
#
# Author: Gemini
# Last Updated: 2025-06-29
#
# Generates a conventional commit message from staged git changes by calling
# the `agentask` command. This script is separate from `agentask`.
# =============================================================================

# Generates a conventional commit message from staged git changes.
function agentcommit -d "Generate atomic commit messages using AI agent"
    # This function depends on the `agentask` command being available in the shell environment.

    # --- Argument Parsing (Manual Passthrough) ---
    # Manually parse arguments to separate agentcommit's options from agentask's options.
    set -l agentask_args
    set -l is_dry_run false
    set -l show_help false

    for arg in $argv
        switch $arg
            case '-d' '--dry-run'
                set is_dry_run true
            case '-h' '--help'
                set show_help true
            case '*'
                # Collect all other arguments to pass to agentask.
                set -a agentask_args $arg
        end
    end

    if $show_help
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
        echo "No staged changes to commit. Use 'git add' to stage files." >&2
        return 1
    end

    # --- Commit Prompt Based on commit.md Instructions ---
    # Define the specific prompt for generating a commit message.
    set -l commit_prompt 'Analyze the diff context above and generate a conventional commit message.

**Requirements:**
- Follow conventional commit format: type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore
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

**CRITICAL MULTILINE FORMATTING REQUIREMENTS:**
- The commit message MUST be formatted across multiple lines within the quoted string
- NEVER put the entire commit message on a single line
- ALWAYS include line breaks in the git commit command between subject and body
- The subject line goes on the first line after the opening quote
- Insert a blank line after the subject
- Body text goes on subsequent lines before the closing quote

**Critical Output Rules:**
- Respond with ONLY a markdown code block containing the COMPLETE git commit command
- Do NOT add any explanatory text before or after the code block
- Include the full git command with -m flag and quoted message
- MANDATORY: Use proper line breaks within the quoted commit message

**REQUIRED FORMAT EXAMPLE:**
```
git commit -m "feat(scope): subject line here

- Describe what was changed in this logical unit with proper
  line wrapping at 72 characters
- Explain another distinct change or improvement made
- Add details about configuration or setup changes"
```

**DO NOT FORMAT LIKE THIS (WRONG - single line):**
```
git commit -m "feat(scope): subject line here Body text all on one line"
```'

    # Add --dry-run flag to agentask args if in dry run mode
    if $is_dry_run
        set -a agentask_args --dry-run
    else
        echo "🤖 Analyzing staged changes with AI..." >&2
    end

    # Call agentask, piping the git diff and passing through all arguments
    if $is_dry_run
        # In dry run mode, let agentask show its output to stderr, then use fake response
        git -c color.ui=false --no-pager diff --staged | agentask $agentask_args "$commit_prompt"

        # Generate fake response for parsing demonstration
        set response 'Here is a commit message for the staged changes:

```
git commit -m "feat(fish): update agentcommit with improved commit instructions

Add conventional commit format requirements and enforce single atomic
commit generation with proper markdown block output formatting."
```'
    else
        # Check if debug flag is in agentask_args to avoid suppressing stderr
        set -l suppress_stderr true
        for arg in $agentask_args
            if test "$arg" = "--debug"
                set suppress_stderr false
                break
            end
        end

        if $suppress_stderr
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

        if test -z "$response"
            echo "Error: Received an empty response from the AI agent." >&2
            return 1
        end
    end


    # --- PARSING AND DISPLAY BLOCK ---
    set -l git_command_lines
    begin
        set -l IFS
        set git_command_lines (printf '%s\n' "$response" | awk 'BEGIN{RS="```"} NR==2 {print}' | string trim)
    end

    if test (count $git_command_lines) -eq 0
        set -l temp_response (string trim -- "$response")
        set git_command_lines "git commit -m \"$temp_response\""
        set -l temp_lines $git_command_lines
        set git_command_lines
        printf '%s\n' "$temp_lines" | while read --line line
            set -a git_command_lines $line
        end
    end

    if test (count $git_command_lines) -eq 0
        echo "" >&2
        echo "Error: Could not find or construct a 'git commit' command from the agent's response." >&2
        echo "The raw response has been copied to your clipboard for inspection." >&2
        echo "$response" | pbcopy
        return 1
    end

    # Extract just the commit message content (remove git commit -m "..." wrapper)
    # Since git_command_lines is now a single multiline string, handle it directly
    set -l commit_message
    begin
        set -l IFS
        set commit_message (string replace 'git commit -m "' '' -- "$git_command_lines")
        set commit_message (string replace --regex '"$' '' -- "$commit_message")
    end

    echo ""
    printf '%s\n' "$commit_message"
    echo ""
    printf '%s\n' $git_command_lines | pbcopy
    echo "📋 Commit command copied to clipboard."
end

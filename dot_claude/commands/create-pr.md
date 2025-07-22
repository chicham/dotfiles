---
description: "Create pull request from current branch with comprehensive description"
allowed-tools: [mcp__github__create_pull_request, mcp__github__get_issue, mcp__github__get_pull_request_files, mcp__github__get_pull_request_diff, mcp__github__list_pull_requests, mcp__github__update_pull_request, Bash(gh repo view:*), Bash(git branch:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(gh:*)]
---

# Pull Request Creator

## Context

- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
- Commit history: !`git log --pretty=format:"%h %s" --no-merges origin/main..HEAD`
- Files changed: !`git diff --name-only origin/main..HEAD`

## Your task

Create a pull request for the current branch: $ARGUMENTS

**Process:**
1. Extract issue number from $ARGUMENTS or branch name pattern
2. If issue number found, fetch issue details using mcp__github__get_issue
3. Analyze commit history and code changes to generate comprehensive description
4. Compare PR changes against issue requirements to determine completeness
5. Mark as draft if PR doesn't fully address the issue
6. Parse user instructions for specific requirements
7. Generate structured output with all PR fields

**🚨 OUTPUT FORMAT:**
- Respond with ONLY structured fields below
- NO explanatory text, introductions, or conclusions
- Start with "TITLE:" and end with "MILESTONE: [value]"

**EXACT FORMAT:**
TITLE: [complete PR title]
BODY: ```markdown
[complete PR body with sections: Summary, Issue Reference (if applicable), Testing, Breaking Changes, Screenshots/demos if UI, Missing Elements (if draft)]
```
BASE: [target branch - typically 'main']
DRAFT: [true/false - true if incomplete/WIP or doesn't fully solve referenced issue]
ASSIGNEES: [comma-separated usernames or empty]
REVIEWERS: [comma-separated usernames/teams or empty]
LABELS: [comma-separated labels or empty]
MILESTONE: [milestone name or empty]

**Draft Logic:**
- Set DRAFT: true if PR doesn't fully implement all issue requirements
- Include "Missing Elements" section in body listing unaddressed requirements
- Use clear language about what still needs to be done

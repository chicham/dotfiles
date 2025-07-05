---
description: "Create pull request from current branch with comprehensive description"
allowed-tools: ["mcp__github__create_pull_request", "Bash"]
---

# Pull Request Creator

Create pull request for current branch: $ARGUMENTS

**Dynamic Context:**
- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
- Commit history: !`git log --pretty=format:"%h %s" --no-merges origin/main..HEAD`
- Files changed: !`git diff --name-only origin/main..HEAD`
- Available labels: !`gh label list --json name --jq '.[].name' 2>/dev/null | tr '\n' ',' | sed 's/,$//'`
- Open PRs: !`gh pr list --json number,title,headRefName`

**Process:**
1. Extract issue number from $ARGUMENTS or branch name pattern
2. Analyze commit history to generate comprehensive description
3. Parse user instructions for specific requirements
4. Generate structured output with all PR fields

**🚨 OUTPUT FORMAT:**
- Respond with ONLY structured fields below
- NO explanatory text, introductions, or conclusions
- Start with "TITLE:" and end with "MILESTONE: [value]"

**EXACT FORMAT:**
TITLE: [complete PR title]
BODY: ```markdown
[complete PR body with sections: Summary, Testing, Breaking Changes, Screenshots/demos if UI]
```
BASE: [target branch - typically 'main']
DRAFT: [true/false - true if incomplete/WIP]
ASSIGNEES: [comma-separated usernames or empty]
REVIEWERS: [comma-separated usernames/teams or empty]
LABELS: [comma-separated labels or empty]
MILESTONE: [milestone name or empty]

---
allowed-tools: [Bash(gh issue list:*), Bash(gh label list:*), Bash(rg:*), Read, TodoWrite, mcp__github__create_issue]
description: "Create comprehensive GitHub issue with proper documentation"
---

# GitHub Issue Creator

## Context

- Codebase issues: !`rg -i todo\|fixme\|hack\|bug\|xxx --max-count 25 --no-heading`

## Your task

Create a well-documented GitHub issue for: $ARGUMENTS

**Process:**
1. Parse user instructions and extract requirements
2. Determine issue type (bug/feature/enhancement)
3. Research context using dynamic data
4. Generate structured issue with comprehensive sections
5. Parse assignees, labels, milestone, project from $ARGUMENTS

**Instruction Parsing:**
- Assignees: "assign to @username" or "assignee: username"
- Labels: "label: bug" or "labels: enhancement,feature"
- Milestone: "milestone: v1.0"
- Project: "project: Roadmap"

**🚨 OUTPUT FORMAT:**
- Respond with ONLY structured fields below
- NO explanatory text, introductions, or conclusions
- Start with "TITLE:" and end with "PROJECT: [value]"

**EXACT FORMAT:**
TITLE: [complete issue title]
BODY: ```markdown
[complete issue body with sections: Description, Acceptance Criteria/Steps to Reproduce, Technical Requirements, Implementation Notes]
```
ASSIGNEES: [comma-separated usernames or empty]
LABELS: [comma-separated labels or empty]
MILESTONE: [milestone name or empty]
PROJECT: [project name or empty]

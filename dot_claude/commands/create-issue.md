---
description: "Create comprehensive GitHub issue with proper documentation"
allowed-tools: ["mcp__github__create_issue", "Bash", "Read", "TodoWrite"]
---

# GitHub Issue Creator

Create well-documented GitHub issue for: $ARGUMENTS

**Process:**
1. **Clarify requirements** - Ask for missing details (problem statement, acceptance criteria, technical constraints)
2. **Research context** - Use `rg` to search codebase for relevant implementation details
3. **Create comprehensive issue** - Include all necessary information for implementation

**Required information:**
- Clear problem statement and expected outcome
- Steps to reproduce (bugs) or acceptance criteria (features)
- Technical requirements and constraints
- Appropriate labels (bug/feature/enhancement)

**Display before creating:**
```
📋 GitHub Issue:
Title: [Complete issue title]
Labels: [Labels to apply]
Description: [Complete issue body]
```

Don't create until all essential information is gathered and clarified.

---
description: "Prepare repository for implementing GitHub issue"
allowed-tools: ["mcp__github__get_issue", "mcp__github__get_issue_comments", "mcp__github__search_code", "mcp__context7__resolve-library-id", "mcp__context7__get-library-docs", "mcp__hf-mcp-server__model_search", "mcp__hf-mcp-server__paper_search", "Bash", "Write", "Read", "Grep"]
---

# Issue Implementation Starter

Prepare repository for implementing issue: $ARGUMENTS

**Dynamic Context:**
- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
- Related code patterns: !`rg -i "todo|fixme|hack|bug|xxx" --max-count 20 --no-heading`

**Process:**
1. Check for `--print` flag (display only, don't execute)
2. Check branch (if main/master, call `/create-pr` instead)
3. Extract issue number from $ARGUMENTS or branch name
4. Fetch comprehensive issue details and comments
5. Research codebase context and existing implementations
6. Create detailed implementation plan with:
   - Analysis: Problem, root cause, requirements
   - Design: Solution approach, affected components
   - Implementation: Specific steps with file paths
   - Testing: Unit/integration tests, verification
   - Documentation: Updates needed
   - Quality: Validation checklist
7. Display formatted plan before changes

**Output Format:**
```
🛠️ Issue Implementation Plan:
Issue: #[number] - [title]
Type: [bug/feature/enhancement]

Analysis:
- [Problem description and root cause]

Implementation Steps:
1. [Specific step with file paths and changes]
2. [Next step with details]

Testing Strategy:
- [Test plan and verification steps]

Quality Checklist:
- [ ] Tests pass
- [ ] Documentation updated
```

**After plan:**
- If `--print`: Display commands only
- Otherwise: Create branch and implement step by step

---
description: "Create pull request from current branch with comprehensive description"
allowed-tools: ["mcp__github__create_pull_request", "Bash"]
---

# Pull Request Creator

Create pull request for current branch: $ARGUMENTS

**Process:**
1. **Extract issue number** - From $ARGUMENTS or branch name pattern (e.g., `123-feature` → #123)
2. **Verify status** - Check for uncommitted changes, ask user if found
3. **Analyze commits** - Review commit history to generate comprehensive description
4. **Push and create PR** - Push branch, create PR with proper title format

## Pushing and Pull Request Creation
```bash
# Push feature branch
git push origin feature/123-brief-description

# Create PR with mandatory format
# PR title MUST start with: "Fixes #issue-number: Brief description of changes"
```

## Pull Request Requirements
- **Mandatory title format**: "Fixes #issue-number: Brief description"
- **Must link to an issue**: Every PR must reference an existing issue
- **Template compliance**: Fill out PR template completely
- **Description requirements**:
  - Summary of changes
  - Testing performed
  - Breaking changes (if any)
  - Screenshots/demos for UI changes
- **Review requirements**:
  - At least one approving review
  - All CI checks passing
  - No merge conflicts

## Git Operations Best Practices

### Keeping History Linear
```bash
# When pulling changes, always rebase
git pull origin main --rebase

# Interactive rebase to clean up commits before PR
git rebase -i main

# Squash commits if needed to maintain clean history
```

### Handling Merge Conflicts
1. Fetch latest changes: `git fetch origin`
2. Rebase onto main: `git rebase origin/main`
3. Resolve conflicts in IDE
4. Stage resolved files: `git add .`
5. Continue rebase: `git rebase --continue`
6. Force push (safely): `git push origin feature-branch --force-with-lease`

## Code Review Process

### Before Requesting Review
- [ ] All tests pass locally
- [ ] Pre-commit hooks pass
- [ ] Code is self-documented with clear variable/function names
- [ ] Complex logic has comments explaining the "why"
- [ ] No debugging code or console.log statements
- [ ] Documentation updated if needed

### Responding to Review Feedback
- Address all feedback before requesting re-review
- Use "Request changes" resolution to track fixes
- Add comments explaining your approach when needed
- Thank reviewers for their time and feedback

**Display before creating:**
```
🚀 Pull Request:
Title: [Complete PR title]
Description: [Complete PR body]
```

Ensure all tests pass and code quality checks before creation.

---
description: "Prepare repository for implementing GitHub issue"
allowed-tools: ["mcp__github__get_issue", "Bash", "Write"]
---

# Issue Implementation Starter

Prepare repository for implementing issue: $ARGUMENTS

**Process:**
1. **Get issue details** - Fetch issue information using GitHub MCP tools
2. **Prepare repository** - Ensure main branch is current, create feature branch
   ```bash
   # Always start from main
   git checkout main
   git pull origin main --rebase

   # Create and switch to feature branch
   git checkout -b feature/issue-number-brief-description
   ```
3. **Setup structure** - Create any new files/directories specified in issue

## Branch Management

### Branch Naming Convention
- Feature branches: `feature/issue-number-brief-description` (e.g., `feature/123-user-authentication`)
- Bug fixes: `fix/issue-number-brief-description` (e.g., `fix/456-login-validation`)
- Hotfixes: `hotfix/issue-number-brief-description` (e.g., `hotfix/789-security-patch`)
- Chores: `chore/brief-description` (e.g., `chore/update-dependencies`)

### Branch Protection Rules
- **NEVER** commit directly to `main` or `master` branch
- Always create feature branches from the latest `main`
- Delete feature branches after successful merge
- Use branch protection rules to enforce PR reviews

**Display branch creation:**
```
🌿 Creating branch: feature/123-user-authentication
```

**Repository is ready for implementation after completion.**

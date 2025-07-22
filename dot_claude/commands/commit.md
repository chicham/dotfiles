---
allowed-tools: [Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git commit:*), Bash(gh repo view:*), TodoWrite]
description: "Create concise, conventional commits. Body is optional."
---

# Atomic Commit Creator

## Context

- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- Current git status: !`git status --porcelain`
- Current git diff (staged changes): !`git diff --staged`
- Current branch: !`git branch --show-current`

## Your task

Based on the staged changes, create a single, concise git commit for: $ARGUMENTS

**Process:**
1. Analyze the staged diff.
2. Generate a conventional commit message.
3. Add a body if the subject line is not sufficient to explain all the changes.
4. Keep it brief and focused on the "what" and "why".

**Format:**
- `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`
- Body: If needed, explain the change. Wrap at 72 chars.

**🚨 CRITICAL OUTPUT FORMAT:**
- Respond with ONLY the commit message.
- NO explanatory text, introductions, or reasoning.
- The commit title MUST be under 50 chars and use the imperative mood.

---
### Example (Subject only)
```
fix(api): correct authentication error on /login
```
---
### Example (With Body)
```
feat(parser): add support for parsing TOML files

- Implement a new `TomlParser` class.
- Add `toml` as a project dependency.
- This is required for the new configuration system.
```

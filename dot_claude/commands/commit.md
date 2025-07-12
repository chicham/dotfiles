---
description: "Create atomic commits following conventional commit format"
allowed-tools: ["Bash", "TodoWrite"]
---

# Atomic Commit Creator

Create atomic commits with conventional format: $ARGUMENTS

**Dynamic Context:**
- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- Current branch: !`git branch --show-current`
- Staged diff: !`git diff --staged`
- Git status: !`git status --porcelain`

**Process:**
1. Verify staged changes exist
2. Analyze staged diff to understand all changes
3. Generate conventional commit message documenting ALL changes

**Format:**
- `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`
- Body: Document ALL changes with bullet points, wrap at 72 chars

**🚨 CRITICAL OUTPUT FORMAT:**
- Respond with ONLY the commit message - NO other text
- NO explanatory text, introductions, or reasoning
- Proper line breaks between subject and body
- The whole commit title MUST be under 50 chars
- Use imperative mood

**EXACT FORMAT:**
type(scope): subject line here

- Describe what was changed in this logical unit
- Explain another distinct change or improvement made
- Add details about configuration or setup changes

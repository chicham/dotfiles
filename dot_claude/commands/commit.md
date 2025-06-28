---
description: "Create atomic commits following conventional commit format"
allowed-tools: ["Bash", "TodoWrite"]
---

# Atomic Commit Creator

Create atomic commits with conventional format for current changes.

**Process for Atomic Commits:**
1.  **Analyze changes**: Review `git status`/`git diff`, group logically related files.
2.  **Create atomic commits**: One logical change per commit.
3.  **Verify completion**: Ensure all changes are committed appropriately.

**Conventional Format:** `type(scope): description`
-   **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
-   Keep subject line under 50 characters, use imperative mood, and capitalize the subject line.
-   No period at the end of the subject line.
-   Separate subject and body with a blank line.
-   Wrap body at 72 characters.
-   If a file contains multiple atomic changes, use a generic summary title and describe the changes in detail in the body.
-   Include body for complex changes explaining *what* and *why*.

**Example**: `git commit -m "feat(auth): add OAuth2 integration"`

Group unrelated changes into separate commits. Each commit should be self-contained and functional.

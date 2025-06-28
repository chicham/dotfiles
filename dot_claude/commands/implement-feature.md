---
description: "Implement feature code to make existing tests pass (TDD implementation phase)"
allowed-tools: ["Bash", "Read", "Edit", "MultiEdit", "TodoWrite"]
---

# Feature Implementation (TDD)

Implement code to make tests pass for: $ARGUMENTS

**TDD Process:**
1. **Run failing tests** - See current test failures and understand requirements
2. **Research patterns** - Use `rg` to find existing code patterns and architecture
3. **Plan implementation** - Create todo list for implementation steps
4. **Write minimal code** - Implement just enough to make tests pass
5. **Iterate** - Run tests, refine code until all tests pass
6. **Stage changes** - Add implementation files for commit

**Key principles:**
- Don't modify tests - work with existing test requirements
- Follow existing codebase patterns and conventions
- Write genuine solutions, avoid overfitting to tests
- Ensure code passes linting and pre-commit hooks

**Use separate `/user:commit` command with message: `feat: implement [description]`**

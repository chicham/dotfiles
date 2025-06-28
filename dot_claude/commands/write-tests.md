---
description: "Write comprehensive tests for feature (TDD test-first phase)"
allowed-tools: ["Bash", "Read", "Write", "TodoWrite"]
---

# Test Writer (TDD)

Write tests for feature: $ARGUMENTS

**TDD Process:**
1. **Understand requirements** - Analyze feature description and expected behavior
2. **Research test patterns** - Use `rg` to find existing testing framework and patterns
3. **Plan test coverage** - Create todo list for comprehensive test scenarios
4. **Write failing tests** - Create tests that define expected behavior
5. **Verify test failures** - Run tests to confirm they fail for right reasons
6. **Stage test files** - Add test files for commit

**Test coverage:**
- Unit tests for individual functions/methods
- Integration tests for component interactions
- Edge cases and error conditions
- Invalid input scenarios

**Key principles:**
- Write ONLY test code - no implementation or mocks
- Use descriptive test names explaining behavior being tested
- Ensure tests fail due to missing functionality, not syntax errors

**Use separate `/user:commit` command with message: `test: add tests for [description]`**

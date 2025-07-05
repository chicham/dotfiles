---
description: "Python test writer using unittest/absl with hypothesis property testing"
allowed-tools: ["Bash", "Read", "Write", "TodoWrite", "Grep", "mcp__github__search_code"]
---

# Python Test Writer (unittest + absl + hypothesis)

Generate comprehensive Python tests for: $ARGUMENTS

**Dynamic Context:**
- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- Project config: !`fd -e toml pyproject.toml`
- Test dependencies: !`rg "(absl-py|hypothesis)" pyproject.toml 2>/dev/null`
- Existing tests: !`fd -t f -e py "*_test.py" "test_*.py"`
- Test patterns: !`rg "class.*Test|def test_" --type py -A 1 2>/dev/null`
- Absl imports: !`rg "from absl import|import absl" --type py`

**Smart Analysis:**
1. **Detect absl setup** - Find existing absl.testing usage patterns
2. **Map source modules** - Identify code under test and import structure
3. **Plan property testing** - Use hypothesis for comprehensive input generation
4. **Create test files** - Follow project naming (test_*.py or *_test.py)

**Test Framework Stack:**
- **absl.testing.absltest** - Main test runner and TestCase base class
- **absl.testing.parameterized** - Parameterized test cases
- **hypothesis** - Property-based testing with generated inputs
- **unittest.mock** - Mocking for dependencies

**Test Patterns:**
```python
from absl.testing import absltest, parameterized
from hypothesis import given, strategies as st
import unittest.mock as mock

class ModuleTest(parameterized.TestCase):
    @parameterized.named_parameters(...)
    def test_function_with_params(self, ...):

    @given(st.text(), st.integers())
    def test_property_with_hypothesis(self, text_input, int_input):
```

**Smart Commands:**
```bash
# Run tests with absl
python -m absl.testing.absltest discover

# Run specific test file
python path/to/module_test.py

# Coverage with absl tests
coverage run -m absl.testing.absltest discover && coverage report
```

**Coverage Strategy:**
- **Unit tests** - Individual functions with unittest.TestCase
- **Property tests** - hypothesis strategies for edge case generation
- **Parameterized** - Multiple inputs using @parameterized.named_parameters
- **Integration** - Component interactions with proper setup/teardown
- **Error cases** - Exception testing with assertRaises

**Hypothesis Strategies:**
- **Primitives** - st.text(), st.integers(), st.floats()
- **Collections** - st.lists(), st.dictionaries()
- **Custom** - st.builds() for domain objects
- **Constraints** - min_size, max_size, filter predicates

**Quality Automation:**
- Auto-run tests to verify they fail initially
- Check imports and syntax
- Validate test isolation
- Generate property test examples

Auto-stage and suggest commit: `test: add unittest tests with hypothesis for [feature]`

# Gemini Analysis Command

Use Gemini CLI for large codebase analysis when context limits are exceeded. Claude should delegate analysis to Gemini, then implement based on the results.

## Usage for Claude

When Claude encounters tasks requiring full codebase analysis:

```bash
gemini --all_files -p "Analyze the project structure and identify [specific area]"
```

## Key Options

- `--all_files` - Include ALL project files (recommended default)
- `-p, --prompt` - Analysis prompt
- `-m, --model` - Model selection (default: gemini-2.5-pro)
- `-s, --sandbox` - Run in sandbox mode
- `-c, --checkpointing` - Enable file edit checkpointing

## Common Analysis Commands

### Architecture Review
```bash
gemini --all_files -p "Analyze the project architecture and structure. Identify main modules and their relationships."
```

### Security Audit
```bash
gemini --all_files -p "Perform comprehensive security audit. List vulnerabilities, security measures, and recommendations."
```

### Feature Implementation Check
```bash
gemini --all_files -p "Check if [feature] has been implemented. Show all related files, functions, and components."
```

### Test Coverage Analysis
```bash
gemini --all_files -p "Analyze test coverage across the project. Which components lack proper tests?"
```

### Performance Analysis
```bash
gemini --all_files -p "Identify performance bottlenecks and optimization opportunities throughout the codebase."
```

### Research with Web Search
```bash
gemini --all_files -p "Analyze this codebase and search the web for current best practices for [technology/pattern]. Compare implementation with latest standards."
```

## Delegation Workflow

1. **Analysis Phase**: Claude runs Gemini command for exploration
2. **Implementation Phase**: Claude uses Gemini's analysis to implement changes
3. **Separation of Concerns**: Gemini explores, Claude implements

## File-Specific Analysis

When full project context isn't needed:

```bash
# Specific files/directories
gemini -p "@src/ @tests/ Analyze test coverage for source code"

# Single file
gemini -p "@package.json Analyze dependencies and suggest updates"
```

## When Claude Should Use Gemini

- Large codebase analysis exceeding Claude's context limits
- Project-wide architecture reviews
- Comprehensive security audits
- Feature verification across multiple files
- Performance analysis requiring full project understanding
- Research requiring both codebase analysis and web search

**Note**: Claude should use Gemini for analysis and exploration, then implement the recommended changes using standard tools. Include "search the web" in prompts when current best practices or documentation lookup is needed.

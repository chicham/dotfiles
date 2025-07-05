---
description: "Delegate large codebase analysis to Gemini CLI when context limits are exceeded"
allowed-tools: ["Bash", "mcp__github__search_code", "mcp__context7__resolve-library-id", "mcp__context7__get-library-docs", "mcp__hf-mcp-server__hf_doc_search", "mcp__hf-mcp-server__hf_doc_fetch", "mcp__hf-mcp-server__model_search", "mcp__hf-mcp-server__dataset_search", "mcp__hf-mcp-server__paper_search"]
---

# Gemini Analysis Command

Use Gemini CLI for large codebase analysis when context limits are exceeded.

## Usage for Claude

With user instructions:
```bash
gemini --all_files -p "$ARGUMENTS"
```

Default analysis:
```bash
gemini --all_files -p "Analyze the project structure and identify key components and their relationships"
```

## Key Options
- `--all_files` - Include ALL project files (recommended)
- `-p, --prompt` - Analysis prompt
- `-m, --model` - Model selection (default: gemini-2.5-pro)
- `-s, --sandbox` - Run in sandbox mode
- `-c, --checkpointing` - Enable file edit checkpointing

## Common Analysis Types
- **Architecture Review**: "Analyze project architecture and module relationships"
- **Security Audit**: "Perform security audit, list vulnerabilities and recommendations"
- **Feature Check**: "Check if [feature] implemented, show related files/functions"
- **Test Coverage**: "Analyze test coverage, identify untested components"
- **Performance**: "Identify performance bottlenecks and optimization opportunities"
- **Research**: "Analyze codebase and search web for [technology] best practices"

## File-Specific Analysis
```bash
# Specific paths
gemini -p "@src/ @tests/ Analyze test coverage for source code"

# Single file
gemini -p "@package.json Analyze dependencies and suggest updates"
```

## Workflow
1. **Analysis**: Claude runs Gemini for exploration
2. **Implementation**: Claude implements recommended changes
3. **Separation**: Gemini explores, Claude implements

## When to Use Gemini
- Large codebase analysis exceeding context limits
- Project-wide architecture reviews
- Comprehensive security audits
- Feature verification across multiple files
- Performance analysis requiring full project understanding
- Research needing codebase analysis + web search

Include "search the web" in prompts when current best practices lookup is needed.

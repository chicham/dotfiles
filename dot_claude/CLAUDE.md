# CLAUDE.md

## Core Behavior
- **Be honest and direct**: Challenge bad decisions, suggest better approaches, ask clarifying questions, say "no" when appropriate
- **Do exactly what's asked**: Nothing more, nothing less
- **File creation**: NEVER create files unless absolutely necessary; ALWAYS prefer editing existing files
- **Documentation**: NEVER proactively create *.md or README files unless explicitly requested
- **Session management**: **IMPORTANT** - When task is complete, remind user to use `/compact` before switching tasks to reduce costs

## Tool Selection and Usage (CRITICAL)

### Bash Command Protocol
- **NEVER run bash commands directly** - first display the command and ask if user wants to run it
- **Exception**: Only run bash commands when explicitly requested or when part of an established workflow
- **Always explain** what the command does before suggesting it

### Required First Steps
- **Tree-sitter**: NEVER search in `.git` or `.venv` directories unless explicitly requested
- **Before any tool**: Display the message/description/title being sent to verify intent

### Tool Priority by Use Case
- **Semantic code search**: Tree-sitter MCP (classes, variables, AST properties)
- **Text pattern search**: ripgrep `rg` (strings, comments, file contents)
- **File operations**: eza (aliased to `ls`)
- **Library docs**: Context7 MCP
- **ML/AI resources**: Hugging Face MCP
- **GitHub interactions**: GitHub MCP
- **File find operations**: Use `fd` instead of `find` for faster and more user-friendly searching

### Essential Commands
```bash
# File exploration
eza -la --git              # detailed list with git status
eza -T                     # tree view

# Search patterns
rg "pattern" -t js         # search specific file types
rg -A 5 -B 5 "pattern"     # search with context
rg --files-with-matches    # only show file names
```

## Code Quality (CRITICAL)

### Security & Quality
- **NEVER commit secrets, API keys, or passwords** - use env vars or secret management
- Validate `.gitignore` prevents sensitive files from being tracked

## Development Standards
- Write tests for new features following project conventions
- Verify dependencies exist before assuming libraries are available
- Follow existing patterns and naming conventions
- Code is self-documented with clear names
- Complex logic has "why" comments
- No debugging code or console.log statements

### Commit Practices
- Atomic commits with descriptive messages
- Document dependency changes
- Use conventional commit format when project uses it

## Advanced Guidelines
- **API Design**: Workflows first, simple cases simple, max 6-7 function args, excellent error messages
- **Documentation**: Show with code examples, assume minimal context
- **Dependencies**: Audit for vulnerabilities, never commit `.git` or `.venv`

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
- **File finding**: ALWAYS use `fd` (not `find`)
- **Text searching**: ALWAYS use `rg` (not `grep`). Use the `Search` tool when possible
- **Code searching**: Use `ast-grep` for AST-aware searches and refactoring
- **File editing**: Use `sed` for in-place edits, or `sd` for simpler syntax
- **File reading**: Use `bat` for viewing, `head`/`tail` for large files
- **Batch operations**: Combine tools with pipes, `xargs`, or `parallel`
- **File operations**: eza (aliased to `ls`) for listing
- **Library docs**: Context7 MCP
- **ML/AI resources**: Hugging Face MCP
- **GitHub interactions**: GitHub MCP ( ALWAYS use this tool to interact with github)
- **File find operations**: Use `fd` instead of `find` for faster and more user-friendly searching

See "Efficient Unix Tools for File Operations" section below for detailed examples.

### Efficient Unix Tools for File Operations

**PRIORITY ORDER**: Always use the most efficient tool available for the task.

#### File Finding (ALWAYS use `fd` over `find`)
```bash
# Modern tool: fd (PREFERRED)
fd "pattern"                    # find files by name
fd -e py                        # find by extension
fd -t f "test"                  # find files only (-t f), exclude dirs
fd -t d "src"                   # find directories only
fd -H "config"                  # include hidden files
fd -I "node_modules"            # include ignored files (.gitignore)
fd "\.py$" -x wc -l             # execute command on results
fd . /path --max-depth 2        # limit search depth

# Traditional tool: find (fallback only)
find . -name "*.py" -type f
```

#### Text Searching (ALWAYS use `rg` over `grep`)
```bash
# Modern tool: ripgrep/rg (PREFERRED)
rg "pattern"                    # basic search
rg "pattern" -t py              # search specific file types
rg "pattern" -g "*.{js,ts}"     # glob pattern for file types
rg -i "pattern"                 # case-insensitive search
rg -w "word"                    # match whole words only
rg -A 5 -B 5 "pattern"          # show 5 lines context (after/before)
rg --files-with-matches "TODO"  # only show filenames
rg -l "pattern"                 # shorthand for files-with-matches
rg --type-add 'config:*.{yml,yaml,toml,json}' -tconfig "key"
rg "pattern" --json | jq        # structured output for parsing
rg -v "exclude"                 # invert match (show non-matching)
rg --hidden "pattern"           # include hidden files
rg --no-ignore "pattern"        # include ignored files
rg "pattern" -C 3               # context lines (both before/after)

# Traditional tool: grep (avoid unless necessary)
grep -r "pattern" .
```

#### Structured Code Searching (use `ast-grep` for AST-based operations)
```bash
# AST-aware search and refactoring
ast-grep --pattern 'console.log($$$)' -l js,ts
ast-grep --pattern 'function $NAME($$$) { $$$ }' src/
ast-grep --pattern 'class $NAME { $$$ }' --json
ast-grep --pattern 'import { $$ } from "$SRC"' -r 'import { $$ } from "@/$SRC"'
```

#### File Reading (efficient alternatives to `cat`)
```bash
# For quick viewing
bat file.py                     # syntax highlighting, line numbers
bat -A file.py                  # show all (including non-printable)
bat --plain file.py             # no decorations (like cat)

# For large files
head -n 50 file.txt             # first 50 lines
tail -n 50 file.txt             # last 50 lines
tail -f log.txt                 # follow file (streaming logs)
sed -n '10,20p' file.txt        # lines 10-20 only (no full read)

# Traditional
cat file.txt                    # full file read
```

#### In-Place File Editing (CRITICAL for batch operations)
```bash
# Standard tool: sed (PREFERRED for simple edits)
sed -i '' 's/old/new/g' file.txt                    # macOS
sed -i 's/old/new/g' file.txt                       # Linux
sed -i.bak 's/old/new/g' file.txt                   # create backup
sed -i '' '/^$/d' file.txt                          # delete empty lines
sed -i '' '10,20d' file.txt                         # delete lines 10-20
sed -i '' '5i\new line' file.txt                    # insert at line 5

# Multiple file edits with fd + sed
fd -e py -x sed -i '' 's/old_name/new_name/g'

# Batch rename
fd -e txt -x rename 's/\.txt$/.md/'

# Modern alternative: sd (simpler syntax)
sd 'old' 'new' file.txt
sd -f m 'regex' 'replace' file.txt
```

#### Combining Tools for Maximum Efficiency
```bash
# Find and edit in one pass
fd -e py -x sed -i '' 's/import os/import pathlib/g'

# Search and replace across multiple files
rg -l "old_function" -t py | xargs sed -i '' 's/old_function/new_function/g'

# Find, filter, and process
fd -e json -x jq '.version' | sort -u

# Complex refactoring with ast-grep
fd -e js | xargs -I {} ast-grep --pattern 'var $NAME = $$$' -r 'const $NAME = $$$' {}

# Parallel processing for speed
fd -e py | parallel -j8 'ruff format {}'
```

#### Performance Guidelines
- **Always prefer Rust tools** (fd, rg, sd) over traditional tools for speed
- **Use ast-grep** for language-aware refactoring (safer than regex)
- **Use sed** for simple, proven text transformations
- **Combine tools** with pipes and xargs for batch operations
- **Avoid loops** in shell scripts; use tool built-ins or xargs instead

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

### Python-Specific Standards
- The library should not define class hierarchy. Each utility class should be a stateless mixin class. The final Stateful class should be a dataclass that inherit the mixins and a protocol must be used if we need to use types
- Never use pytest with abseil. Instead run the tests as python script
- Run ruff using `ruff check --output-format=concise`
- Always fix ruff issues file by file. You must fix all errors for a target file in one multi edit if possible
- Never use contextual comment. Your comments must always describe how the code is working
- Use `uvx ty check --output-format=concise` to typecheck
- Prefer passing arguments when defining functions
- Comments should be compatible with Sphinx and the Napoleon extension

### Code Change Workflow
- Each edit must be preceded by a description of what is implemented, why it is implemented that way and how it integrates in the code base
- When you need to perform multiple edits or search and replace in multiple files, use efficient tools (fd, rg, sed, xargs) as documented in the "Efficient Unix Tools" section above instead of performing individual updates
- Before applying an update, always describe your changes and how to integrate in the code base or how it fixes the issue

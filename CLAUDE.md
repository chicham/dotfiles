# CLAUDE.md

This document guides AI agents and human developers on project conventions and best practices.

## Repository Overview

This is a dotfiles template repository managed with [chezmoi](https://chezmoi.io/).

## Environment Assumptions

- macOS: Local machine with GUI applications support
- Linux: Can be either local desktop or remote server
- Remote SSH servers (detected via SSH_CONNECTION environment variable):
  - Do not install GUI applications on remote servers
  - Focus on CLI tools and terminal utilities only
  - Avoid root/sudo requirements when possible
- Configuration must maintain feature parity between macOS and Linux except for graphical tools
  - When adding a CLI tool to one platform, add it to the other platform as well
  - Ensure consistent user experience across environments

## Commands

- Apply changes: `chezmoi apply`
- Add file: `chezmoi add ~/.file`
- Edit file: `chezmoi edit ~/.file`
- Merge file: `chezmoi merge ~/.file`
- Update repository: `chezmoi update`

## Installation Procedures

### Chezmoi Script Naming Convention

- Script files in `.chezmoiscripts/` follow specific naming patterns:
  - `run_once_` - Run only once, never again
  - `run_onchange_` - Run when script content changes
  - `run_` - Run every time chezmoi apply is executed
  - Optional ordering prefix can be added: `run_once_before_`, `run_once_after_`, etc.
  - Scripts are automatically made executable by chezmoi

### Adding New Tools

- **Linux Installation**:
  - Get the latest version from GitHub API if possible, else fallback to a specific version
  - Retrieve binaries from GitHub releases if available
  - If GitHub releases aren't available, use installation script/download from developer's website
  - NEVER use sudo for installation

- **macOS Installation**:
  - Add entry in `.chezmoidata/packages.yaml` file
  - This file is read and executed by `.chezmoiscripts/darwin/run_onchange_darwin-install-packages.sh.tmpl`

- **Documentation**:
  - Always update the README.md when a new tool is installed
  - Always update the CHEATSHEET.md with usage examples
  - Add description and usage examples to the appropriate section

## Code Style

- Shell scripts: Follow POSIX sh compatibility
- Use 2-space indentation
- Add comments for non-obvious code sections only
- Prefer parameter substitution for variable handling: `${var:-default}`
- Error handling: Set `set -eu` in shell scripts
- Naming: Use snake_case for variables and functions
- Prefer simple solutions over complex scripts

## Best Practices

- Keep scripts idempotent
- Validate commands exist before using them
- Document environment assumptions
- Quote all variables: `"${var}"`
- Avoid hardcoded paths when possible
- Always run pre-commit hooks to verify changes

## Development Workflow

### Git and GitHub Workflow
- **Issue Creation**: Refer to `dot_claude/commands/create-issue.md` for detailed instructions.
- **Branch Management**: Refer to `dot_claude/commands/fix-issue.md` for branch naming conventions, protection rules, and creation.
- **Commit Guidelines**: Refer to `dot_claude/commands/commit.md` for detailed instructions on creating atomic commits and conventional commit format.
- **Pull Request Workflow**: Refer to `dot_claude/commands/create-pr.md` for pushing, PR creation, requirements, history management, and code review process.

### Changelog Management

#### Conventional Commits

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>: <description>

[optional body]

[optional footer(s)]
```

Where `<type>` is one of:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting, indentation)
- `refactor`: Code changes that neither fix bugs nor add features
- `test`: Adding or updating tests
- `chore`: Changes to the build process, tools, etc.
- `ci`: Changes to CI configuration files

#### Automatic Changelog Generation

The repository uses [git-cliff](https://github.com/orhun/git-cliff) to automatically generate the CHANGELOG.md file based on commit messages.

1. **Pre-push hook**:
   - A pre-push hook automatically updates CHANGELOG.md when you push to the repository
   - Configuration is defined in `cliff.toml`
   - This ensures the changelog is always up-to-date with the latest changes
   - The updated CHANGELOG.md will be included in your pull request automatically

2. **Pull Request Workflow**:
   - When you create a branch and make commits, ensure they follow the conventional format
   - Before creating a pull request, push your changes which triggers the changelog generation
   - The pre-push hook will:
     - Run git-cliff to update the CHANGELOG.md with your new commits
     - Add the modified CHANGELOG.md to your changes
   - Create your pull request, which will now include the updated changelog

3. **Troubleshooting**:
   - If the pre-push hook fails, ensure git-cliff is installed
   - On macOS: `brew install git-cliff`
   - On Linux: use the installation script in `.chezmoiscripts/`
   - You can manually update the changelog with: `git-cliff --output CHANGELOG.md`

## Template Customization

- Chezmoi template delimiters can be customized in each file
- Add a comment at the beginning of the file to define custom delimiters
- Use language-appropriate comment syntax for better readability and syntax highlighting
- Format: `<comment char> chezmoi:template:left-delimiter="<comment char> [[" right-delimiter="]] <comment char>"`
- Examples for different languages:

  ```sh
  # Shell scripts (.sh, .profile, .zprofile)
  # chezmoi:template:left-delimiter="# [[" right-delimiter="]] #"
  ```

  ```lua
  -- Lua files (.lua)
  -- chezmoi:template:left-delimiter="-- [[" right-delimiter="]] --"
  ```

  ```toml
  # TOML files (.toml)
  # chezmoi:template:left-delimiter="# [[" right-delimiter="]] #"
  ```

- This replaces the default `{{` and `}}` with more language-appropriate delimiters
- Custom delimiters improve syntax highlighting and make templates easier to read
- The custom delimiters are then used throughout the file for template logic and variable insertion

## AI Agent Specific Directives

- **File System Interaction**:
    - **NEVER** attempt to add or commit `.git` or `.venv` directories.
    - For manual tools (lint, typecheck, test runners), **ALWAYS** ask the user to run them rather than executing automatically.
    - When proposing changes, always provide a clear explanation of *what* will be changed and *why*.
    - When using `replace`, ensure `old_string` includes sufficient context (at least 3 lines before/after) to guarantee a unique match.
    - When creating new files, ensure they adhere to existing project conventions (naming, structure, content).
- **Commit Messages**: When asked to commit, always propose a draft commit message following the Conventional Commits format.
- **Clarification**: If a request is ambiguous or requires significant deviation from established patterns, **ALWAYS** ask for clarification before proceeding.
- **Self-Correction**: If a tool call fails or produces unexpected results, analyze the error and attempt to self-correct or ask the user for guidance.

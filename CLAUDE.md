# CLAUDE.md - Coding Agent Guidelines

## Repository Overview
This is a dotfiles template repository managed with [chezmoi](https://chezmoi.io/).

## Environment Assumptions
- macOS: Local machine with GUI applications support
- Linux: Almost always a remote server without GUI environment
  - Do not install GUI applications on Linux
  - Focus on CLI tools and terminal utilities only
  - Avoid root/sudo requirements when possible

## Commands
- Install/initialize: `./install.sh`
- Apply changes: `chezmoi apply`
- Add file: `chezmoi add ~/.file`
- Edit file: `chezmoi edit ~/.file`
- Update repository: `chezmoi update`

## Code Style
- Shell scripts: Follow POSIX sh compatibility
- Use 2-space indentation
- Add comments for non-obvious code sections
- Prefer parameter substitution for variable handling: `${var:-default}`
- Error handling: Set `set -eu` in shell scripts
- Naming: Use snake_case for variables and functions

## Best Practices
- Keep scripts idempotent
- Validate commands exist before using them
- Document environment assumptions
- Quote all variables: `"${var}"`
- Avoid hardcoded paths when possible
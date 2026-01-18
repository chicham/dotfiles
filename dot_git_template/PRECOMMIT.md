# Prek Setup

This repository comes with an automatic prek configuration that helps maintain code quality across all your Git repositories.

## What is prek?

[prek](https://github.com/j178/prek) is a fast, drop-in alternative to pre-commit that runs the same hook configuration and manages hook environments. It automatically runs a set of checks on your code before each commit, ensuring that your code meets quality standards.

## How It Works

When you run `git init` to create a new repository:

1. The prek hooks are automatically installed in your new repository's `.git/hooks` directory
1. A sample pre-commit-compatible configuration file is available at `~/.git_template/pre-commit-config.yaml`

## Setting Up a New Repository

To use prek in a new repository:

1. Copy the sample configuration:

   ```bash
   cp ~/.git_template/pre-commit-config.yaml .pre-commit-config.yaml
   ```

1. Customize the hooks as needed for your project

1. Start committing! The hooks will run automatically.

## Included Hooks

The sample configuration includes the following hooks:

### Code Quality

- `trailing-whitespace`: Trims trailing whitespace
- `end-of-file-fixer`: Ensures files end with a newline
- `check-yaml`: Validates YAML files
- `check-added-large-files`: Prevents committing large files accidentally
- `check-merge-conflict`: Ensures merge conflicts aren't committed

### Python

- `ruff`: Fast Python linter and formatter
- `ruff-format`: Formats Python code

### Shell

- `shellcheck`: Finds bugs and suggestions for shell scripts

### Git

- `conventional-pre-commit`: Enforces conventional commit message format
  - Supported types: feat, fix, chore, test

## Customizing the Configuration

Edit your `.pre-commit-config.yaml` file to add or remove hooks as needed. Visit [pre-commit.com](https://pre-commit.com/) for more available hooks.

## Troubleshooting

If you ever need to bypass prek (not recommended for normal use):

```bash
git commit --no-verify
```

If prek is not installed, the global hooks will guide you to install it with:

```bash
uv tool install prek
```

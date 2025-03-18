# Artefiles

A cross-platform dotfiles template managed with [chezmoi](https://chezmoi.io/).

## Installation

Install in one command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply artefactory/artefiles
```

This command will:

1. Install chezmoi if it's not already installed
1. Clone this repository
1. Apply the dotfiles to your system

## Tools Included

This dotfiles template includes a carefully curated set of development tools, each chosen for their productivity benefits:

| Tool                                                | Description            | Why It's Useful                                                              |
| --------------------------------------------------- | ---------------------- | ---------------------------------------------------------------------------- |
| [fish](https://fishshell.com/)                      | Modern shell           | Intelligent autosuggestions, syntax highlighting, and user-friendly defaults |
| [starship](https://starship.rs/)                    | Customizable prompt    | Fast, informative prompt with Git integration and language support           |
| [wezterm](https://wezfurlong.org/wezterm/)          | Terminal emulator      | GPU-accelerated with excellent font handling and multiplexing                |
| [neovim](https://neovim.io/)                        | Text editor            | Modern Vim with better defaults and powerful extensions                      |
| [VSCode](https://code.visualstudio.com/)            | Code editor            | Feature-rich editor with excellent extension ecosystem                       |
| [Homebrew](https://brew.sh/)                        | Package manager        | Simple package installation for macOS (automatically installed)              |
| [git-cliff](https://github.com/orhun/git-cliff)     | Changelog generator    | Automatically generates changelogs from conventional commits                 |
| [Google Cloud SDK](https://cloud.google.com/sdk)    | Cloud tools            | Command-line tools for Google Cloud (gcloud, gsutil, bq)                     |
| [uv](https://github.com/astral-sh/uv)               | Python package manager | Ultra-fast Python package installation and management                        |
| [pre-commit](https://pre-commit.com/)               | Git hook manager       | Automates code quality checks before each commit                             |
| [bat](https://github.com/sharkdp/bat)               | Cat replacement        | Syntax highlighting and Git integration for file viewing                     |
| [eza](https://github.com/eza-community/eza)         | ls replacement         | Rich features for listing files with color and Git status                    |
| [difftastic](https://github.com/Wilfred/difftastic) | Diff tool              | Syntax-aware diff for better code comparison                                 |
| [atuin](https://github.com/atuinsh/atuin)           | Shell history          | Searchable, syncable shell history with context                              |
| [zoxide](https://github.com/ajeetdsouza/zoxide)     | Directory jumper       | Faster navigation between frequently-used directories                        |
| [direnv](https://direnv.net/)                       | Environment manager    | Directory-based environment variable loading                                 |

### Git Configuration

- **VSCode Integration**: Configured as both diff and merge tool with convenient aliases (`git vsdiff`, `git vsmerge`)
- **Automatic Changelog**: Pre-push hook generates CHANGELOG.md using git-cliff and conventional commits
- **Pre-commit Hooks**: All new Git repositories will automatically be configured with pre-commit hooks for code quality

## Platform Support

- **macOS**: Full GUI application support
- **Linux**: CLI-focused for remote server usage

## Management

```bash
# Edit a dotfile
chezmoi edit ~/.config/fish/config.fish

# Apply changes
chezmoi apply

# Update from repository
chezmoi update
```

## License

MIT

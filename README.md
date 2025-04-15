# Artefiles

A cross-platform dotfiles template managed with [chezmoi](https://chezmoi.io/). These dotfiles provide a consistent development environment across different platforms, including GitHub Codespaces.

## Quick Start 🚀

### One-Line Installation

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply artefactory/artefiles
```

### GitHub Codespaces Support

These dotfiles can automatically bootstrap your GitHub Codespace environment. To use them:

1. Add this repository as your dotfiles in your [GitHub Codespaces settings](https://github.com/settings/codespaces)
2. Create a new codespace - it will automatically apply these dotfiles

Learn more about Codespaces dotfiles in the [official documentation](https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles).

## What's Included 📦

### Core Features

- 🐟 [Fish Shell](https://fishshell.com/) with intelligent autosuggestions
- ⚡ [Starship](https://starship.rs/) prompt for fast, informative shell feedback
- 📝 [Neovim](https://neovim.io/) and VSCode configurations
- 🔍 Modern CLI tools (bat, eza, fd, fzf, etc.)
- 🌟 [Catppuccin](https://github.com/catppuccin/catppuccin) theme across all tools

### Development Tools

- 🐍 Python environment management with [uv](https://github.com/astral-sh/uv) and direnv
- 🔄 Git configuration with useful defaults and integrations
- 📊 Jupyter notebook support with nbdime
- 🖥️ SSH configuration optimized for remote development

## Prerequisites ✅

- A GitHub account (for git and GitHub-related features)
  - GitHub CLI authentication will be handled automatically during installation
  - For non-interactive environments, set `GH_TOKEN` environment variable before installation
- SSH keys added to your GitHub account ([instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent))

## Common Tasks 🛠️

| Task | Command |
|------|---------|
| Update dotfiles | `chezmoi update` |
| Edit config | `chezmoi edit ~/.config/file` |
| Health check | `dotfiles_doctor` |
| New Python project | `mkdir project && cd project && echo 'layout uv' > .envrc && direnv allow` |

## Configuration Structure 📁

```
~/.config/
  ├── fish/            # Shell configuration
  │   ├── config.fish  # Main shell configuration
  │   ├── aliases.fish # Shell aliases and functions
  │   └── functions/   # Custom fish functions
  ├── nvim/            # Editor configuration
  ├── direnv/          # Environment management
  ├── bat/             # Syntax highlighting
  └── starship.toml    # Prompt configuration

~/.ssh/config          # SSH configuration
~/.wezterm.lua        # Terminal configuration
~/.gitconfig          # Git configuration
```

## Post-Installation Steps 📝

1. Set up shell history sync:
   ```bash
   atuin register  # New account
   atuin login     # Existing account
   ```

2. Configure Git:
   ```bash
   chezmoi edit ~/.gitconfig  # Edit git config
   ```

3. Initialize cloud tools (if needed):
   ```bash
   gcloud init  # Set up Google Cloud SDK
   ```

## Need Help? 🤔

- Run `dotfiles_doctor` to check your installation
- See `chezmoi help` for dotfiles management
- Check the [CHEATSHEET.md](CHEATSHEET.md) for more commands
- Reset a file: `chezmoi apply --force ~/.path/to/file`

## Detailed Documentation 📚

- [CHEATSHEET.md](CHEATSHEET.md) - Common commands and shortcuts
- [CHANGELOG.md](CHANGELOG.md) - Version history and updates

## License 📄

MIT

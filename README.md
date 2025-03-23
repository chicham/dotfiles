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
1. Automatically install 1Password CLI if needed (via pre-read-source-state hook)
1. Apply the dotfiles to your system

## Tools Included

This dotfiles template includes a carefully curated set of development tools, each chosen for their productivity benefits. All tools are automatically installed and configured.

### Theme Configuration

The dotfiles come with [Catppuccin](https://github.com/catppuccin/catppuccin) as the default theme, specifically the Mocha variant. [Gruvbox Material](https://github.com/sainnhe/gruvbox-material) is also available as an alternative.

Themes are configured in the following files:

| Tool | Configuration File | Notes |
|------|-------------------|-------|
| WezTerm | `~/.wezterm.lua` | Terminal theme setup |
| Neovim | `~/.config/nvim/init.lua` | Editor theme (Catppuccin is default) |
| bat | `~/.config/bat/config` | Syntax highlighting theme |
| Starship | `~/.config/starship.toml` | Terminal prompt theme |
| Fish | `~/.config/fish/config.fish` | Shell configuration |

#### How to Customize Themes

To change themes for individual tools:

- **Neovim**:
  - Edit `~/.config/nvim/init.lua`
  - Change the colorscheme line to use a different theme
  - Example: `vim.cmd.colorscheme("gruvbox-material")`

- **WezTerm**:
  - Edit `~/.wezterm.lua`
  - Change the color_scheme setting

- **Starship**:
  - Edit `~/.config/starship.toml`
  - Modify the palette configuration

- **bat**:
  - Edit `~/.config/bat/config`
  - Change the `--theme` parameter

For a more advanced setup with environment variable-based theme switching, you can implement a custom solution or restore the original dynamic theme management.

### Shells & Terminal

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [fish](https://fishshell.com/) | Modern shell | Intelligent autosuggestions, syntax highlighting, and user-friendly defaults |
| [starship](https://starship.rs/) | Customizable prompt | Fast, informative prompt with Git integration and language support |
| [wezterm](https://wezfurlong.org/wezterm/) | Terminal emulator | GPU-accelerated with excellent font handling and multiplexing, includes Nerd Fonts |
| [direnv](https://direnv.net/) | Environment manager | Directory-based environment variable loading |

Fish shell configuration is organized into modular files:
- `config.fish.tmpl`: Main configuration file with environment setup
- `aliases.fish.tmpl`: All shell aliases and utility functions
- `conf.d/*.fish`: Auto-loaded configuration files for specific tools

### Editors & IDEs

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [neovim](https://neovim.io/) | Text editor | Modern Vim with better defaults and powerful extensions |
| [VSCode](https://code.visualstudio.com/) | Code editor | Feature-rich editor with excellent extension ecosystem |

### CLI Utilities

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [bat](https://github.com/sharkdp/bat) | Cat replacement | Syntax highlighting and Git integration for file viewing |
| [eza](https://github.com/eza-community/eza) | ls replacement | Rich features for listing files with color and Git status |
| [fd](https://github.com/sharkdp/fd) | Find replacement | User-friendly, fast alternative to the `find` command |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | Powerful interactive filtering for command line |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Directory jumper | Faster navigation between frequently-used directories |
| [atuin](https://github.com/atuinsh/atuin) | Shell history | Searchable, syncable shell history with context |

#### Custom Utility Functions

The dotfiles also include several custom utility functions to improve workflow:

| Function | Description |
|----------|-------------|
| `watch-file` | Continuously display file content with syntax highlighting using bat |
| `run-and-watch` | Run a command in the background and watch its output log file |
| `dotfiles_doctor` | Check the health of your dotfiles installation and tools |
| `set_theme` | Change theme across all configured applications |

### Git Tools

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [git](https://git-scm.com/) | Version control | Comprehensive version control with extensive configuration |
| [git-lfs](https://git-lfs.github.com/) | Large file storage | Efficiently manages large files in Git repositories |
| [GitHub CLI](https://cli.github.com/) | GitHub CLI | Command-line interface for GitHub operations |
| [difftastic](https://github.com/Wilfred/difftastic) | Diff tool | Syntax-aware diff for better code comparison |
| [git-cliff](https://github.com/orhun/git-cliff) | Changelog generator | Automatically generates changelogs from conventional commits |
| [pre-commit](https://pre-commit.com/) | Git hook manager | Automates code quality checks before each commit |

### Cloud & Package Management

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [Google Cloud SDK](https://cloud.google.com/sdk) | Cloud tools | Command-line tools for Google Cloud (gcloud, gsutil, bq) |
| [Homebrew](https://brew.sh/) | Package manager | Simple package installation for macOS (automatically installed) |
| [uv](https://github.com/astral-sh/uv) | Python package manager | Ultra-fast Python package installation and management |

### Fonts

| Font | Description | Why It's Useful |
|------|-------------|-----------------|
| [FiraCode Nerd Font](https://www.nerdfonts.com/) | Monospace font | Programming ligatures with icons for development |
| [Source Code Pro Nerd Font](https://www.nerdfonts.com/) | Monospace font | Clean, readable code font with added icons |
| [Monaspace Nerd Font](https://www.nerdfonts.com/) | Monospace font | Modern coding font with Nerd Font icons |

### Security & Authentication

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [1Password](https://1password.com/) | Password manager | Secure password storage and management with browser integration |
| [1Password CLI](https://1password.com/downloads/command-line/) | Password manager CLI | Access to secrets and passwords from the command line |

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

# Edit shell aliases
chezmoi edit ~/.config/fish/aliases.fish

# Apply changes
chezmoi apply

# Update from repository
chezmoi update
```

## Post-Installation Steps

After installation is complete, you should:

1. **Set up 1Password CLI**:
   ```bash
   op account add  # Add your 1Password account
   ```

2. **Configure Atuin** (shell history sync):
   ```bash
   atuin register  # New account
   atuin login     # Existing account
   ```

3. **Create and Set Up SSH Keys**:
   - Follow GitHub's guide to [generate SSH keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
   - Add the keys to your GitHub/GitLab account

4. **Initialize Google Cloud SDK**:
   ```bash
   gcloud init
   ```

5. **Set Up GitHub CLI** (if you use GitHub):
   ```bash
   gh auth login
   ```

6. **Configure Neovim**:
   - Launch it once to install plugins: `nvim`
   - Wait for the initial plugin installation to complete

7. **Personalize Git Config**:
   - Edit your personal git config if needed: `chezmoi edit ~/.gitconfig`

## License

MIT

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

### Theme Integration

The dotfiles come with multiple theme options pre-installed across various tools:

1. [Catppuccin](https://github.com/catppuccin/catppuccin) (Mocha variant by default) - A soothing pastel theme
2. [Gruvbox Material](https://github.com/sainnhe/gruvbox-material) - A modified version of Gruvbox with softer colors

These themes provide a consistent aesthetic across your development environment:

| Tool | Theme Support | How It's Implemented |
|------|--------------|---------------------|
| WezTerm | Catppuccin, Gruvbox Material | Custom color schemes and built-in themes |
| Neovim | Catppuccin, Gruvbox Material | Installed via Lazy.nvim plugin manager |
| bat | Various themes | Auto-installed via dotfiles script |
| Starship | Custom palettes | Dynamically updated via `update_starship_theme` function |
| fzf | Terminal colors | Uses terminal colors for consistent experience |
| Fish | Terminal colors | Inherits from WezTerm's terminal colors |

All these tools are configured to respect the `USER_THEME` environment variable, so changing it in one place updates the theme across your entire environment.

#### Changing Theme Variants

You can easily switch between theme variants using the included `set_theme` function:

```fish
# Catppuccin variants
set_theme "Catppuccin Mocha"    # Default dark theme
set_theme "Catppuccin Latte"    # Light theme
set_theme "Catppuccin Frappe"   # Medium-dark theme
set_theme "Catppuccin Macchiato" # Darker theme

# Gruvbox variants
set_theme "Gruvbox Material"    # Dark Gruvbox Material theme
```

The function updates all theme-aware tools at once. Some tools like WezTerm and Neovim require a restart to fully apply the theme changes.

Available theme variants:
- Catppuccin:
  - `Catppuccin Mocha` (default dark)
  - `Catppuccin Latte` (light)
  - `Catppuccin Frappe` (medium-dark)
  - `Catppuccin Macchiato` (darker)
- Gruvbox:
  - `Gruvbox Material` (dark)

For permanent changes, you can add the `set_theme` command to your `~/.config/fish/local.config.fish` file.

### Shells & Terminal

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [fish](https://fishshell.com/) | Modern shell | Intelligent autosuggestions, syntax highlighting, and user-friendly defaults |
| [starship](https://starship.rs/) | Customizable prompt | Fast, informative prompt with Git integration and language support |
| [wezterm](https://wezfurlong.org/wezterm/) | Terminal emulator | GPU-accelerated with excellent font handling and multiplexing, includes Nerd Fonts |
| [direnv](https://direnv.net/) | Environment manager | Directory-based environment variable loading |

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

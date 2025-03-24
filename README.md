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
  ```lua
  -- Switch to Gruvbox Material (already included)
  vim.cmd.colorscheme("gruvbox-material")

  -- Or customize Catppuccin with a different flavor
  require("catppuccin").setup({
      flavour = "macchiato"  -- Options: latte, frappe, macchiato, mocha
  })
  vim.cmd.colorscheme("catppuccin")
  ```

- **WezTerm**:
  - Edit `~/.wezterm.lua`
  - Change the color_scheme setting
  ```lua
  -- Change from Catppuccin Mocha to another theme
  config.color_scheme = "Catppuccin Frappe"  -- or "Catppuccin Latte" for light theme

  -- Or switch to Gruvbox Material
  -- config.color_scheme = "Gruvbox Material (Gogh)"
  ```

- **Starship**:
  - Edit `~/.config/starship.toml`
  - Change the palette setting to use a different Catppuccin flavor or another theme
  ```toml
  # Switch to Catppuccin Latte (light theme)
  palette = "catppuccin_latte"

  # Or switch to Catppuccin Frappe
  # palette = "catppuccin_frappe"

  # Or switch to Catppuccin Macchiato
  # palette = "catppuccin_macchiato"

  # Or switch to Catppuccin Mocha (default)
  # palette = "catppuccin_mocha"

  # Or switch to Gruvbox Material
  # palette = "gruvbox_material"
  ```

- **bat**:
  - Edit `~/.config/bat/config`
  - Change the `--theme` parameter
  ```
  # Set the theme to "Catppuccin Mocha" (default)
  --theme="Catppuccin Mocha"

  # Or change to another theme
  # --theme="Catppuccin Latte"
  # --theme="gruvbox-dark"

  # List all available themes with:
  # bat --list-themes
  ```

- **Fish**:
  - Catppuccin themes are built into Fish
  - Use the following commands to switch between flavors:
  ```fish
  # Switch to one of the Catppuccin flavors
  fish_config theme save "Catppuccin Latte"
  fish_config theme save "Catppuccin Frappe"
  fish_config theme save "Catppuccin Macchiato"
  fish_config theme save "Catppuccin Mocha"

  # To check available themes
  fish_config theme list
  ```

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
| `remote_exec` | Execute commands on remote servers with improved output handling |

### Git Tools

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [git](https://git-scm.com/) | Version control | Comprehensive version control with extensive configuration |
| [git-lfs](https://git-lfs.github.com/) | Large file storage | Efficiently manages large files in Git repositories |
| [GitHub CLI](https://cli.github.com/) | GitHub CLI | Command-line interface for GitHub operations |
| [difftastic](https://github.com/Wilfred/difftastic) | Diff tool | Syntax-aware diff for better code comparison |
| [git-cliff](https://github.com/orhun/git-cliff) | Changelog generator | Automatically generates changelogs from conventional commits |
| [git-extras](https://github.com/tj/git-extras) | Git utilities | Collection of useful Git commands that enhance workflow |
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

The security and authentication tools have been made optional and are not included by default in this template. You can add your preferred password manager and authentication tools separately.

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

1. **Configure Atuin** (shell history sync):
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

## Contributing

### Adding a New Tool

To add a new tool to the dotfiles, follow these steps:

1. **For macOS**:
   - Add the package name to `.chezmoidata/packages.yaml` under the `darwin.brews` section
   - For GUI applications, add to the `darwin.casks` section instead

2. **For Linux**:
   - Create an installation script in `.chezmoiscripts/linux/` directory
   - Name it `run_onchange_install-toolname.sh`
   - Use existing scripts as templates
   - Prefer installation methods that don't require root/sudo
   - Preferably install to `$HOME/.local/bin`

3. **Update Documentation**:
   - Add the tool to the README.md in the appropriate section
   - Include name, description, and why it's useful
   - Update the doctor function in `dot_config/fish/functions/dotfiles_doctor.fish`
   - Add the tool name to the `tools_to_check` array

4. **Test Your Changes**:
   - Test on both macOS and Linux if possible
   - For Linux-only testing, use the Docker test environment:
     ```bash
     ./docker-test.sh
     ```

### Code Style Guidelines

- Shell scripts should follow POSIX sh compatibility
- Use 2-space indentation for all files
- Keep scripts idempotent (can be run multiple times without issue)
- Add helpful comments for non-obvious code
- Quote all variables: `"${var}"`

## License

MIT

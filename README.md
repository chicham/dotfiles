# Artefiles

A cross-platform dotfiles template managed with [chezmoi](https://chezmoi.io/).

## Quick Start Guide

### Installation

Install in one command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply artefactory/artefiles
```

This command will install chezmoi, clone this repository, and apply the dotfiles to your system.

### Common Workflows

| I want to... | Command |
|--------------|---------|
| Update my dotfiles | `chezmoi update` |
| Edit a configuration file | `chezmoi edit ~/.config/file` |
| Check if everything is working | `dotfiles_doctor` |
| Start a new Python project | `mkdir project && cd project && echo 'layout uv' > .envrc && direnv allow` |
| Work with a remote server | `remote_exec server "command"` or use WezTerm's SSH features |
| Use Jupyter notebooks | Install with `uv pip install jupyterlab` and run with `jupyter lab` |

See the [CHEATSHEET.md](CHEATSHEET.md) for a complete reference of commands and shortcuts.

### Configuration Structure

```
~/.config/
  ├── fish/            # Shell configuration
  │   ├── config.fish  # Main shell config
  │   └── aliases.fish # Command aliases
  ├── nvim/            # Editor configuration
  ├── direnv/          # Environment management
  ├── bat/             # Syntax highlighting
  └── starship.toml    # Prompt configuration

~/.ssh/config          # SSH configuration
~/.wezterm.lua         # Terminal configuration
~/.gitconfig           # Git configuration
```

### Troubleshooting

- **Something's not working?** Run `dotfiles_doctor` to check your installation
- **Want to reset a file?** Use `chezmoi apply --force ~/.path/to/file`
- **Need help with chezmoi?** See `chezmoi help` or [chezmoi documentation](https://www.chezmoi.io/docs/how-to/)

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

#### How to Update Themes

Each tool has a fixed theme configuration that needs to be updated individually. Here's how to update themes for each tool:

- **Neovim**:
  - Edit the config file with: `chezmoi edit ~/.config/nvim/init.lua`
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
  - Edit the config file with: `chezmoi edit ~/.wezterm.lua`
  - Change the color_scheme setting
  ```lua
  -- Change from Catppuccin Mocha to another theme
  config.color_scheme = "Catppuccin Frappe"  -- or "Catppuccin Latte" for light theme

  -- Or switch to Gruvbox Material
  -- config.color_scheme = "Gruvbox Material (Gogh)"
  ```

- **Starship**:
  - Edit the config file with: `chezmoi edit ~/.config/starship.toml`
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
  - Edit the config file with: `chezmoi edit ~/.config/bat/config`
  - Change the `--theme` parameter
  ```
  # Set the theme to "Catppuccin Mocha" (default)
  --theme="Catppuccin Mocha"

  # Or change to another theme
  # --theme="Catppuccin Latte"
  # --theme="gruvbox-dark"
  ```
  - After changing the theme, rebuild the bat cache:
  ```
  bat cache --build
  ```
  - To see all available themes:
  ```
  bat --list-themes
  ```

- **Fish**:
  - Use fish_config to change the theme directly:
  ```fish
  # To see all available themes
  fish_config theme list

  # Set a specific Catppuccin theme
  fish_config theme choose "Catppuccin Mocha"
  fish_config theme choose "Catppuccin Latte"
  fish_config theme choose "Catppuccin Frappe"
  fish_config theme choose "Catppuccin Macchiato"
  ```

> **Note**: After updating themes, you may need to restart your terminal for all changes to take effect.

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
| [atuin](https://github.com/atuinsh/atuin) | Shell history | Searchable, syncable shell history with context. Can be used to share command history between machines. |

#### Custom Utility Functions

The dotfiles also include several custom utility functions to improve workflow:

| Function | Description |
|----------|-------------|
| `watch-file` | Continuously display file content with syntax highlighting using bat |
| `run-and-watch` | Run a command in the background and watch its output log file |
| `dotfiles_doctor` | Check the health of your dotfiles installation and tools |
| `set_theme` | Change fish theme and update all configured applications to match |
| `remote_exec` | Execute commands on remote servers with improved output handling |

#### Working with Remote Servers

The dotfiles include optimized configurations for working with remote servers:

##### SSH Configuration

The SSH configuration (`~/.ssh/config`) is optimized for stable connections:
- Persistent connections with `ServerAliveInterval` and `TCPKeepAlive` settings
- Prevents timeouts on long-running remote sessions

For researchers working with remote computing resources, consider adding these settings to your SSH config:

```
# Example settings for remote research servers (add to ~/.ssh/config)
Host research-server
  HostName research-server.example.com
  User yourname
  # Forward local port 8888 to remote port 8888 (for Jupyter)
  LocalForward 8888 localhost:8888
  # Enable connection sharing for faster subsequent connections
  ControlMaster auto
  ControlPath ~/.ssh/control/%r@%h:%p
  ControlPersist 4h
```

These settings help with:
- Port forwarding for accessing Jupyter notebooks remotely
- Connection persistence for long compute sessions
- Faster reconnections using control sockets

##### WezTerm SSH Integration

WezTerm automatically reads your SSH configuration from `~/.ssh/config`, making it easy to:
- Connect to your configured hosts directly from WezTerm
- Maintain persistent connections to remote servers
- Use multiple tabs/panes within the same SSH session

To use WezTerm's SSH capabilities:

1. Your SSH hosts defined in `~/.ssh/config` are automatically available
2. Access them via `Ctrl+Shift+P` → "Connect to SSH Host..."
3. Select the desired host from the list

##### File Transfers with Remote Servers

For researchers working with remote servers, efficient file transfer is important:

**Using rsync (recommended for large datasets)**:
```bash
# Upload: Local to remote
rsync -avz --progress /path/to/local/file username@remote:/path/to/destination

# Download: Remote to local
rsync -avz --progress username@remote:/path/to/remote/file /path/to/local/destination

# Synchronize directory with remote (useful for project folders)
rsync -avz --progress --delete /local/project/ username@remote:/remote/project/
```

**Using scp (simpler for occasional transfers)**:
```bash
# Upload
scp /path/to/local/file username@remote:/path/to/destination

# Download
scp username@remote:/path/to/remote/file /path/to/local/destination
```

> **Note**: For large data files, this dotfiles repository already configures `git-lfs` with appropriate settings in the global gitattributes file.

##### The `remote_exec` Function

For quick remote commands without establishing a full session, use the included `remote_exec` function:

```fish
# Basic usage
remote_exec username@server "command_to_run"

# Examples
remote_exec user@server.example.com "uptime"
remote_exec user@server.example.com "cd /path/to/project && python script.py"
```

This function provides:
- Interactive terminal connection with the `-t` flag
- Clean command execution and output handling
- Tab completion for both server names and commands

### Git Tools

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [git](https://git-scm.com/) | Version control | Comprehensive version control with extensive configuration |
| [git-lfs](https://git-lfs.github.com/) | Large file storage | Efficiently manages large files in Git repositories |
| [GitHub CLI](https://cli.github.com/) | GitHub CLI | Command-line interface for GitHub operations that allows you to manage issues, pull requests, and other GitHub workflows directly from your terminal. For configuration, see the [GitHub CLI Quickstart](https://docs.github.com/en/github-cli/github-cli/quickstart) |
| [difftastic](https://github.com/Wilfred/difftastic) | Diff tool | Syntax-aware diff for better code comparison |
| [git-cliff](https://github.com/orhun/git-cliff) | Changelog generator | Automatically generates changelogs from conventional commits |
| [git-extras](https://github.com/tj/git-extras) | Git utilities | Collection of useful Git commands that enhance workflow |
| [pre-commit](https://pre-commit.com/) | Git hook manager | Automates code quality checks before each commit |
| [nbdime](https://github.com/jupyter/nbdime) | Notebook diff | Special diff and merge for Jupyter notebooks, automatically configured if installed |

#### Jupyter Notebook Integration

##### Git Integration with nbdime

When working with Jupyter notebooks, this dotfiles template automatically configures [nbdime](https://github.com/jupyter/nbdime) for improved Git integration:

- **Automatic Configuration**: nbdime is configured as the Git diff and merge tool for `.ipynb` files
- **Visual Diffs**: See meaningful diffs of notebooks instead of raw JSON
- **Smart Merges**: Better conflict resolution that understands notebook structure

The configuration is applied automatically when nbdime is installed:

```bash
uv pip install nbdime
```

Usage is transparent - regular Git commands will use nbdime for notebooks:

```bash
# Show notebook diff
git diff notebook.ipynb

# Resolve merge conflicts
git mergetool notebook.ipynb
```

##### Remote Jupyter Workflow

For researchers working on remote servers with Jupyter notebooks:

1. **Install Jupyter on the remote server**:
   ```bash
   # On remote server, in your project directory
   echo 'layout uv' > .envrc
   direnv allow
   uv pip install jupyterlab
   ```

2. **Start Jupyter Lab on the remote server**:
   ```bash
   # On remote server
   jupyter lab --no-browser --port=8888
   ```

3. **Connect via SSH with port forwarding**:
   If you haven't set up port forwarding in your SSH config as shown earlier,
   use this command from your local machine:
   ```bash
   ssh -L 8888:localhost:8888 username@remote-server
   ```

4. **Access in your local browser**:
   Open http://localhost:8888 to access the remote Jupyter Lab instance

This workflow gives you:
- The computational power of the remote server
- The convenience of your local browser interface
- No need to transfer notebook files back and forth

### Cloud & Package Management

| Tool | Description | Why It's Useful |
|------|-------------|-----------------|
| [Google Cloud SDK](https://cloud.google.com/sdk) | Cloud tools | Command-line tools for Google Cloud (gcloud, gsutil, bq) |
| [Homebrew](https://brew.sh/) | Package manager | Simple package installation for macOS (automatically installed) |
| [uv](https://github.com/astral-sh/uv) | Python package manager | Ultra-fast Python package installation and management. Provides faster pip replacement, virtual environment management, and dependency resolution. See [uv features](https://github.com/astral-sh/uv/blob/main/README.md#-features) for more details. Run Python scripts in isolated environments with `uv run python script.py` |

#### Using uv with direnv for Python Development

This dotfiles template includes a custom `layout_uv` function in the direnv configuration that makes Python environment management seamless:

1. Create a `.envrc` file in your project directory:
   ```bash
   echo 'layout uv' > .envrc
   ```

2. Allow direnv to use this file:
   ```bash
   direnv allow
   ```

This automatically:
- Creates a new virtual environment (`.venv`) if one doesn't exist
- Activates the environment when you enter the directory
- Deactivates it when you leave

**Example Python project workflow**:

```bash
# Create a new project directory
mkdir -p ~/projects/python_project
cd ~/projects/python_project

# Set up automatic environment with direnv
echo 'layout uv' > .envrc
direnv allow

# Install Python packages
uv pip install requests pytest black

# Create a Python script
touch main.py

# The environment is automatically activated whenever you
# enter this directory in the future
```

### Fonts

| Font | Description | Why It's Useful |
|------|-------------|-----------------|
| [FiraCode Nerd Font](https://www.nerdfonts.com/) | Monospace font | Programming ligatures with icons for development |

The dotfiles include utilities for managing Nerd Fonts:

* **Automatic Installation**: FiraCode Nerd Font is automatically checked and installed at shell startup if not present
* **Fast Detection**: Uses a quick file check method instead of slower system font queries
* **Manual Installation**: Install any Nerd Font using the included fish function:

```fish
# Install any Nerd Font by name
install_nerd_font JetBrainsMono
install_nerd_font Hack
install_nerd_font SourceCodePro
```

The `is_nerd_font_installed` function lets you check if a font is installed:

```fish
if is_nerd_font_installed "JetBrainsMono"
    echo "JetBrainsMono is installed"
end
```

Browse available fonts at [Nerd Fonts website](https://www.nerdfonts.com/).

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

2. **Create and Set Up SSH Keys**:
   - Follow GitHub's guide to [generate SSH keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
   - Add the keys to your GitHub/GitLab account

3. **Initialize Google Cloud SDK**:
   ```bash
   gcloud init
   ```

4. **Set Up GitHub CLI** (if you use GitHub):
   ```bash
   gh auth login
   ```
   **Note**: A GitHub account is mandatory for proper functionality of git, gh, and other GitHub-dependent tools.

5. **Configure Neovim**:
   - Launch it once to install plugins: `nvim`
   - Wait for the initial plugin installation to complete

6. **Personalize Git Config**:
   - Edit your personal git config if needed: `chezmoi edit ~/.gitconfig`

7. **For Researchers/Developers**:
   - Install Jupyter for notebooks and interactive computing:
     ```bash
     # Create a directory for your Python work
     mkdir -p ~/projects/python
     cd ~/projects/python

     # Set up environment with direnv
     echo 'layout uv' > .envrc
     direnv allow

     # Install Jupyter and common packages
     uv pip install jupyterlab numpy pandas matplotlib

     # Launch Jupyter
     jupyter lab
     ```
   - Configure SSH for remote servers:
     ```bash
     # Edit SSH config
     chezmoi edit ~/.ssh/config
     ```

## Tips and Best Practices

### Customizing Your Configuration

The dotfiles are designed to be personalized. Here's how to make the most of them:

1. **User-Specific Configuration**:
   - Create a `~/.config/fish/local.config.fish` file for machine-specific settings
   - Add environment variables in `~/.profile` for system-wide settings
   - Use template variables in `.chezmoidata.toml` for personalization

2. **Theming Your Environment**:
   - Set your preferred theme with `set_theme` (options: `catppuccin_mocha`, `catppuccin_latte`, `catppuccin_frappe`, `catppuccin_macchiato`, `gruvbox_material`)
   - Or edit individual theme files as described in the [Theme Configuration](#theme-configuration) section

3. **Customizing for Researchers/Developers**:
   - Create a project template directory with pre-configured `.envrc` files
   - Set up SSH configs for your common remote servers
   - Configure port forwarding for Jupyter access

4. **Using chezmoi Effectively**:
   - Use `chezmoi cd` to navigate to your source directory
   - Preview changes with `chezmoi diff` before applying
   - Apply only specific files with `chezmoi apply ~/.config/specific_file`
   - Use `chezmoi edit` to make changes to dotfiles

5. **Troubleshooting**:
   - Run `dotfiles_doctor` to check for issues
   - View chezmoi logs with `chezmoi doctor`
   - Reset problematic files with `chezmoi apply --force <file>`

### Workflow Examples

#### Setting Up a New Machine

```bash
# Install dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply artefactory/artefiles

# Personalize Git config
chezmoi edit ~/.gitconfig

# Configure SSH keys
ssh-keygen -t ed25519 -C "your_email@example.com"

# Set preferred theme
fish -c "set_theme catppuccin_mocha"

# Check installation
dotfiles_doctor
```

#### Daily Development Workflow

```bash
# Update dotfiles
chezmoi update

# Create new Python project
mkdir -p ~/projects/new_project
cd ~/projects/new_project
echo 'layout uv' > .envrc
direnv allow

# Install dependencies
uv pip install requests pytest

# Work with remote server
remote_exec myserver "uptime"
```

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

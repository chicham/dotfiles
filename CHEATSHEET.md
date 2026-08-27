# Artefiles Cheatsheet

This cheatsheet provides quick reference for common commands and workflows. For detailed documentation, see the [README.md](README.md).

## Table of Contents

- [Environment Setup](#environment-setup)
- [Chezmoi](#chezmoi)
- [Core Tools](#core-tools)
- [Terminal & Shell](#terminal--shell)
- [Git & Version Control](#git--version-control)
- [Remote Server Operations](#remote-server-operations)
- [Python Development](#python-development)
- [System Health & Diagnostics](#system-health--diagnostics)
- [Ghostty Terminal](#ghostty-terminal)
- [Testing & Development](#testing--development)

## Environment Setup

### Configuration Structure

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
~/.config/ghostty/config # Terminal configuration
~/.gitconfig          # Git configuration
```

## Chezmoi

| Task | Command |
|------|---------|
| Status | `chezmoi status` |
| Diff | `chezmoi diff` |
| Edit a file | `chezmoi edit ~/.config/fish/config.fish` |
| Apply changes | `chezmoi apply` |
| Update from repo | `chezmoi update` |

### Remove All Chezmoi-Managed Files (Danger)

Review first:
```bash
chezmoi managed -p absolute
```

Remove all managed files, then remove chezmoi state/source:
```bash
chezmoi managed -p absolute -0 | xargs -0 chezmoi destroy --force
chezmoi purge --force
```

### Core Tools

| Tool | Description | Usage |
|------|-------------|-------|
| [Fish Shell](https://fishshell.com/) | Modern shell | Intelligent autosuggestions and syntax highlighting |
| [Starship](https://starship.rs/) | Shell prompt | Fast, informative prompt with Git integration |
| [Neovim](https://neovim.io/) | Text editor | Modern Vim with better defaults |
| [bat](https://github.com/sharkdp/bat) | Cat replacement | Syntax highlighting for file viewing |
| [eza](https://github.com/eza-community/eza) | ls replacement | Improved file listing with Git integration |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | cd replacement | Smart directory navigation |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | Interactive filtering for files and history |
| [uv](https://github.com/astral-sh/uv) | Python package manager | Fast package installation and environment management |
| [direnv](https://direnv.net/) | Environment manager | Per-directory environment variables |
| [atuin](https://github.com/atuinsh/atuin) | Shell history | Searchable, syncable shell history |

### Post-Installation Steps

1. Shell History Sync (atuin):
   ```bash
   atuin register     # Create new account
   atuin login        # Login to existing account
   atuin import auto  # Import existing shell history
   ```

2. Git Configuration:
   - Edit configuration: `chezmoi edit ~/.gitconfig`
   - Set commit signing: `git config --global commit.gpgsign true`
   - Configure user info: `git config --global user.name "Your Name"`

3. Cloud Tools:
   - Google Cloud SDK: `gcloud init` and `gcloud auth login`
   - Set default project: `gcloud config set project PROJECT_ID`
   - Install components: `gcloud components install kubectl`

## Terminal & Shell

| Task | Command |
|------|---------|
| List files with details | `ll` (alias for `eza -lh --group-directories-first`) |
| View file with syntax highlighting | `cat file.py` (uses `bat`) |
| Change directory with history | `cd` (uses `zoxide` for smart navigation) |
| Find files by name | `fd pattern` |
| Fuzzy find files | `fzf` |
| Tab completion picker | `Tab` opens an fzf picker over every fish completion (commands, flags, flag values); `Tab`/`Shift-Tab` cycle, typing re-filters live, `Esc` cancels, `Enter` inserts |
| Search shell history via fzf | `Ctrl-R` / `Alt-R` (this directory) / `Alt-F` (global) — requires `atuin` module |

### Claude Code × Zellij

Run inside a [zellij](https://zellij.dev/) session.

| Task | Command | Description |
|------|---------|-------------|
| Worktree as jj workspace + floating pane | `cc-wt <name>` | Runs `claude --worktree <name> --tmux=classic`; creates a [jj](https://jj-vcs.github.io/) workspace at `~/.claude/workspaces/<name>` and opens claude in a floating pane pinned to the current tab |
| Run a command in a visible floating pane | `zbash '<command>'` | Executes in a floating pane (watch it live) while returning stdout/stderr + the real exit code, like `bash -c` |
| | `zbash 'cargo test'` | Watch tests run live in a floating pane |
| | `zbash 'rg TODO src/ | head'` | Pipelines work; quote the whole command |
| Keep the pane open after exit | `ZBASH_KEEP=1 zbash '<cmd>'` | Default is close-on-exit |
| Cap how long zbash waits | `ZBASH_TIMEOUT=60 zbash '<cmd>'` | Seconds before giving up (default 600) |

> The `zellij` agent skill tells Claude Code to route shell commands through `zbash`
> automatically, so you can watch what an agent session is doing. `zbash` falls back to
> running the command normally when you are not inside zellij.

### Agent Skills

Managed with `gh skill` (GitHub CLI 2.93+). The `skills` alias is shorthand for `gh skill`.

| Task | Command | Description |
|------|---------|-------------|
| Search for a skill | `skills search terraform` | Search skills published across GitHub |
| Preview before installing | `skills preview chicham/skills jj` | Read a skill's contents without installing it |
| Install one skill | `skills install chicham/skills jj --agent claude-code --scope user` | Lands in `~/.claude/skills/jj/` |
| Pin to a release | `skills install chicham/skills jj --pin v2026.08.0` | Otherwise resolves the latest tagged release |
| Update everything | `skills update --all` | Refreshes every installed skill from its source |
| Reinstall from the manifest | `chezmoi apply` | Re-runs the install script when `.chezmoidata/skills.yaml` changes |

Authoring your own skills, in [`chicham/skills`](https://github.com/chicham/skills):

| Task | Command | Description |
|------|---------|-------------|
| Validate before publishing | `gh skill publish --dry-run` | Checks frontmatter, naming, and description limits |
| Bump the version | `bump-my-version bump patch` | CalVer `YYYY.0M.PATCH`; commits but does not tag |
| Cut a release | `gh skill publish --tag v2026.08.0` | Tags the commit and creates the GitHub release |

> Skills are **not** tracked by chezmoi — `gh skill` owns `~/.claude/skills/`. Chezmoi only
> carries the manifest (`.chezmoidata/skills.yaml`) and the script that installs from it, so a
> fresh machine ends up with the same set.

## Git & Version Control

| Task | Command |
|------|---------|
| Status | `gs` (alias for `git status`) |
| Add files | `ga` (alias for `git add`) |
| Commit | `gc` (alias for `git commit`) |
| Push | `gp` (alias for `git push`) |
| Pull | `gl` (alias for `git pull`) |
| Visual diff | `git diff` (uses `difft` or `nbdime` for notebooks) |
| Pretty log | `glog` |
| Create PR | `ghpr` (alias for `gh pr create`) |
| View PR | `ghprv` (alias for `gh pr view`) |
| List PRs | `ghprl` (alias for `gh pr list`) |
| GitHub Copilot suggest | `ghcs "natural language prompt"` | Get command suggestions |
| GitHub Copilot explain | `ghce "shell command"` | Explain what a command does |

### Neovim Git Integration

| Category | Shortcut | Description |
|----------|----------|-------------|
| **Status & Logs** | `<leader>gs` | Open Git status window |
| | `<leader>gl` | View Git log with commit graph |
| | `<leader>gla` | Log with all branches |
| | `<leader>glf` | Log for current file |
| | `<leader>gls` | Search commit messages |
| | `<leader>glr` | Show reflog |
| | `<leader>gbl` | Browse file commit history (FZF) |
| **Diff Viewing** | `<leader>gd` | Diff file history |
| | `<leader>gD` | Diff repository history |
| | `<leader>gdd` | Diff against index |
| | `<leader>gdD` | Diff against last commit |
| **Staging** | `<leader>ga` | Stage hunk under cursor |
| | `<leader>gA` | Stage all changes in buffer |
| | `<leader>gw` | Write and stage current file |
| **Unstaging & Reset** | `<leader>gu` | Undo stage hunk |
| | `<leader>gU` | Unstage file |
| | `<leader>gr` | Reset hunk under cursor |
| | `<leader>gR` | Reset entire file |
| **Navigation** | `<leader>gj` | Jump to next hunk |
| | `<leader>gk` | Jump to previous hunk |
| | `]c` | Jump to next git change |
| | `[c` | Jump to previous git change |
| **Branch & Commits** | `<leader>gb` | Browse branches |
| | `<leader>gc` | Commit changes |
| | `<leader>gC` | Amend commit |
| | `<leader>gcf` | Commit fixup |
| **Stash** | `<leader>gt` | Browse stashes |
| | `<leader>gts` | Stash changes |
| | `<leader>gtp` | Pop stash |
| **Rebase** | `<leader>gri` | Interactive rebase |
| | `<leader>grc` | Rebase continue |
| | `<leader>gra` | Rebase abort |
| | `<leader>grs` | Rebase skip |
| | `<leader>grf` | Rebase autosquash |
| **Remote Operations** | `<leader>gf` | Fetch changes |
| | `<leader>gp` | Push changes |
| | `<leader>gP` | Push force-with-lease |
| | `<leader>gpl` | Pull changes |
| **Blame & GitHub** | `<leader>gB` | Blame current line |
| | `<leader>go` | Open in GitHub browser |
| | `<leader>gO` | Open selection in GitHub (visual mode) |
| **Preview & Toggles** | `<leader>gh` | Preview hunk |
| | `<leader>gtb` | Toggle inline blame |
| | `<leader>gtd` | Toggle show deleted |

#### Flog Buffer Commands

When in a Flog window, you can use these built-in commands:

| Command | Action |
|---------|--------|
| `<CR>` or `o` | Open commit in side window |
| `)` / `(` | Jump to next/previous commit |
| `<C-N>` / `<C-P>` | Jump to next/previous commit and open |
| `dd` or `dv` | Open diff for commit under cursor |
| `cc` | Create a commit |
| `ca` | Amend current HEAD commit |
| `cf` | Create fixup commit |
| `co` | Checkout commit |
| `cob` | Checkout branch |
| `ri` | Interactive rebase |
| `g?` | Show help |
| `u` | Update/reload Flog window |
| `gq` | Quit Flog |

### Code Review (tuicr, `git_advanced` module)

`review <Tab>` opens the fzf picker over these subcommands with descriptions;
any unrecognized subcommand passes through to `tuicr` directly.

| Command | Reviews |
|---------|---------|
| `review` | Uncommitted working-tree changes |
| `review file <path>` | One file or directory |
| `review branch [base]` | This branch/chain against `main` (or `base`) |
| `review commit [rev]` | The last commit (or `rev`) |
| `review pr <n>` | A GitHub PR |
| `review list` | Persisted review sessions |
| `review comments` | Comments stored in a session |

### Agent Skills (`gh skill`, `agent_skills` module)

Every `chezmoi apply` runs `gh skill update --all`, then installs every custom skill
from the private `artefactory/skills` companion repo plus every skill listed in its
`recommended-skills.txt` (external pointers, never vendored), for each agent the team
uses (`claude-code`, `github-copilot`, `codex`, `gemini-cli`) — never `--force`, so a
name collision with a skill you authored yourself is left alone. Requires an
authenticated `gh` and read access to `artefactory/skills`.

| Task | Command |
|------|---------|
| Add/remove a skill (custom or recommended) | edit `artefactory/skills` (`skills/` or `recommended-skills.txt`), not this repo |
| Edit agent targets | `.chezmoidata/agent_skills.yaml` |
| Check for updates (read-only) | `gh skill update --dry-run` |
| Install one more, for one agent | `gh skill install <owner>/<repo> <skill> --agent codex --scope user` |
| Publish a new org skill | `gh skill publish --tag vX.Y.Z` from a clone of `artefactory/skills` |
| Force-refresh now | `chezmoi apply` (or re-run the script directly) |

### Git Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git shorthand |
| `gs` | `git status` | Repository status |
| `ga` | `git add` | Stage changes |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push commits |
| `gl` | `git pull` | Pull changes |
| `gd` | `git diff` | Show changes |
| `gco` | `git checkout` | Switch branches |
| `gb` | `git branch` | Manage branches |
| `glog` | Pretty git log | Colored graph log |

## Remote Server Operations

### Remote Command Execution

| Feature | Description | Example |
|---------|-------------|---------|
| Basic execution | Run command on remote server | `remote_exec server "ls -la"` |
| Tab completion | Complete from SSH config | `remote_exec set<TAB>` |
| Host aliases | Use SSH config aliases | `remote_exec dev` |
| Command completion | Complete from remote PATH | `remote_exec server pyth<TAB>` |
| Terminal handling | Proper TTY allocation | `remote_exec server "htop"` |
| Multi-word commands | Quote complex commands | `remote_exec server "ps aux | grep python"` |

Completion Features:
- SSH host completion from ~/.ssh/config
- Username and hostname completion
- Remote command completion from PATH
- Argument completion for common commands

### SSH Configuration

| Task | Config Location | Example |
|------|----------------|---------|
| Add server | `~/.ssh/config` | Use `chezmoi edit ~/.ssh/config` |
| Update known hosts | `~/.ssh/known_hosts` | Automatic during first connection |
| Test connection | Use remote_exec | `remote_exec server "echo test"` |

SSH Configuration Template:
```
Host myserver
    HostName myserver.example.com
    User myusername
    ForwardAgent yes
    ServerAliveInterval 60
```

### Common Remote Workflows

| Task | Command | Notes |
|------|---------|-------|
| Check server status | `remote_exec server "uptime"` | Shows load average |
| Monitor processes | `remote_exec server "htop"` | Interactive process viewer |
| Check disk space | `remote_exec server "df -h"` | Human-readable sizes |
| View logs | `remote_exec server "tail -f /var/log/syslog"` | Live log monitoring |
| Install package | `remote_exec server "uv pip install package"` | Uses uv on remote |
| Run background job | `remote_exec server "nohup command &"` | Continues after disconnect |

## Python Development

| Task | Command |
|------|---------|
| Create new virtual environment | `uv venv` |
| Create project with automatic env | `mkdir project && cd project && echo 'layout uv' > .envrc && direnv allow` |
| Install packages | `uv pip install package1 package2` |
| Install from requirements | `uv pip install -r requirements.txt` |
| Run script in isolated env | `uv run python script.py` |
| Launch Jupyter | `jupyter lab` |

## System Health & Diagnostics

### Health Check Commands

The `dotfiles_doctor` command performs comprehensive environment checks:

1. Tool Status Checks:
   | Category | Tools Checked |
   |----------|---------------|
   | Core | chezmoi, fish, starship, ghostty, direnv |
   | Editors | neovim, vscode |
   | CLI Tools | bat, eza, fd, fzf, zoxide, atuin |
   | Git Tools | git, git-lfs, github-cli, difftastic, git-cliff, jj, prek |
   | Development | gcloud, uv |
   | Platform | brew (macOS only) |

2. Font Status:
   | Check | Description |
   |-------|-------------|
   | Font Installation | Verifies Nerd Font presence |
   | Font Cache | Updates font cache (Linux) |
   | Directory Access | Checks font directories |

3. Environment Status:
   | Check | Success Criteria |
   |-------|-----------------|
| Terminal Integration | Ghostty detection |
   | Git Configuration | user.name and user.email set |
   | GitHub Auth | CLI authentication active |
   | Shell History | Atuin sync enabled |

4. Version Information:
   - Shows installed version for each tool
   - Handles different version formats
   - Indicates missing tools

Output Format:
```
RESULT     CHECK                      MESSAGE
ok         tool-name                  version-info
warning    missing-tool               not found
info       optional-feature           status
```

### Tool-Specific Health Checks

| Tool | Health Check | Fix Command |
|------|-------------|-------------|
| Fish Shell | `fish --version` | Re-run installer |
| Neovim | `nvim --version` | Re-run installer |
| Git | `git config --list` | Edit ~/.gitconfig |
| Python (uv) | `uv --version` | Re-run installer |
| Direnv | Test .envrc loading | Check direnv hook in config.fish |

### Font Management

| Task | Command | Description |
|------|---------|-------------|
| Install font | `install_nerd_font <font-name>` | Install Nerd Font automatically |
| Check installation | `is_nerd_font_installed <font-name>` | Test if font is installed |
| List available fonts | `install_nerd_font` (no arguments) | Show usage and font info |
| Show fonts | `fc-list` (Linux) or `system_profiler SPFontsDataType` (macOS) | List installed fonts |

Common Font Names:
- `FiraCode` - Default coding font
- `JetBrainsMono` - Clear, distinctive font
- `Hack` - Clean monospace font
- `SourceCodePro` - Adobe's coding font
- `Monaspace` - GitHub's new font family

Features:
- Automatic version detection
- OS-specific installation paths
- Fallback version support
- Progress indicators
- Font cache updating (Linux)

## Ghostty Terminal

### Configuration

| Task | Command | Description |
|------|---------|-------------|
| Edit config | `chezmoi edit ~/.config/ghostty/config` | Update Ghostty settings |
| Apply config | `chezmoi apply` | Apply the updated config |

Note: restart Ghostty after changes if the config does not reload automatically.

## Testing & Development

### Testing in a Temporary Environment

| Task | Command |
|------|---------|
| Create test directory | `mkdir -p /tmp/chezmoi-test` |
| Test with dry run | `CHEZMOI_CONFIG=/path/to/tmp-config.yaml XDG_CONFIG_HOME=/tmp/test-xdg chezmoi apply --dry-run --verbose` |
| Clean up test env | `rm -rf /tmp/chezmoi-test /tmp/test-xdg` |

Example test config:
```yaml
data:
  name: "test-user"
  email: "test@example.com"
sourceDir: /path/to/artefiles/repo
destDir: /tmp/chezmoi-test
```

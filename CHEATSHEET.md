# Artefiles Cheatsheet

This cheatsheet provides quick reference for common commands and workflows. For detailed documentation, see the [README.md](README.md).

## Table of Contents

- [General Management](#general-management)
- [Terminal & Shell](#terminal--shell)
- [Git & Version Control](#git--version-control)
- [Python Development](#python-development)
- [Remote Server Workflows](#remote-server-workflows)
- [Useful Aliases](#useful-aliases)
- [WezTerm Shortcuts](#wezterm-shortcuts)

## General Management

| Task | Command |
|------|---------|
| Update dotfiles | `chezmoi update` |
| Apply changes | `chezmoi apply` |
| Edit a dotfile | `chezmoi edit ~/.config/fish/config.fish` |
| Add a file to dotfiles | `chezmoi add ~/.config/some_file` |
| Check dotfiles status | `dotfiles_doctor` |
| Reset a file to repo version | `chezmoi apply --force ~/.config/fish/config.fish` |
| View differences | `chezmoi diff` |

## Terminal & Shell

| Task | Command |
|------|---------|
| List files with details | `ll` (alias for `eza -lh --group-directories-first`) |
| View file with syntax highlighting | `cat file.py` (uses `bat`) |
| Change directory with history | `cd` (uses `zoxide` for smart navigation) |
| Find files by name | `fd pattern` |
| Fuzzy find files | `fzf` |
| Watch file contents | `watch-file logfile.txt` |
| Run commands in background | `command args | run-and-watch output.log` |
| Search command history | `Ctrl+R` (uses `atuin`) |
| Activate Python environment | `direnv allow` (in directory with `.envrc`) |

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

## Python Development

| Task | Command |
|------|---------|
| Create new virtual environment | `uv venv` |
| Create project with automatic env | `mkdir project && cd project && echo 'layout uv' > .envrc && direnv allow` |
| Install packages | `uv pip install package1 package2` |
| Install from requirements | `uv pip install -r requirements.txt` |
| Run script in isolated env | `uv run python script.py` |
| Launch Jupyter | `jupyter lab` |

## Remote Server Workflows

| Task | Command |
|------|---------|
| Quick command on remote | `remote_exec server "command"` |
| Connect with WezTerm | `Ctrl+Shift+P` → "Connect to SSH Host..." |
| Upload to remote | `rsync -avz --progress local_file user@server:remote_path` |
| Download from remote | `rsync -avz --progress user@server:remote_file local_path` |
| Sync directory | `rsync -avz --progress --delete local_dir/ user@server:remote_dir/` |
| Forward port for Jupyter | `ssh -L 8888:localhost:8888 user@server` |

## Useful Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza --group-directories-first` | Improved file listing |
| `ll` | `eza -lh --group-directories-first` | Detailed file listing |
| `la` | `eza -lah --group-directories-first` | Show hidden files |
| `lt` | `eza -T --group-directories-first` | Tree view of directory |
| `cat` | `bat --style=plain` | File viewing with syntax highlighting |
| `find` | `fd` | Faster file finding |
| `vim` | `nvim` | Neovim editor |
| `v` | `nvim` | Quick access to Neovim |

## WezTerm Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+N` | New window |
| `Ctrl+Shift+LeftArrow/RightArrow` | Switch tabs |
| `Ctrl+Shift+]` | Next tab |
| `Ctrl+Shift+[` | Previous tab |
| `Ctrl+Shift+L` | SSH Launcher |
| `Alt+LeftArrow/RightArrow` | Navigate word by word |
| `Ctrl+Shift+-` | Split pane horizontally |
| `Ctrl+Shift+\` | Split pane vertically |
| `Alt+Arrow` | Navigate between panes |

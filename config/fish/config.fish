#### TMUX ####
# Adapted from https://github.com/fish-shell/fish-shell/issues/4434#issuecomment-332626369
# only run in interactive (not automated SSH for example)
if status is-interactive
# don't nest inside another tmux
and not set -q TMUX
  # Adapted from https://unix.stackexchange.com/a/176885/347104
  # Create session 'main' or attach to 'main' if already exists.
  tmux new-session -A -s main
end

if test -d $HOME/.miniconda/
  set CONDA_HOME $HOME/.miniconda/
else
  set CONDA_HOME /opt/conda/
end
#### CONDA ####
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval $CONDA_HOME/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

#### FZF ####
if command -sq fd
  set -x  FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git --type d"
end

set -x FZF_DEFAULT_OPTS "--layout=reverse --inline-info --height '80%' --select-1"

function fish_user_key_bindings
  fzf_key_bindings
end

#### DIRENV ####
eval (direnv hook fish)

#### GPG-AGENT ####
set -x GPG_TTY (tty)
set -u SSH_AGENT_PID
# gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

set -x VISUAL nvim
set -x FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git --type f"
set -x FZF_DEFAULT_OPTS "--layout=reverse --inline-info --height '80%' --select-1 --exit-0"
set FZF_PREVIEW_FILE '--ansi --preview-window "right:60%" --preview "bat --color=always --style=header,grid "'
set -U __done_exclude '(fg)'  # default: all git commands, except push and pull. accepts a regex.
set -x PATH "$HOME/.local/bin:$PATH"

set alias_file $HOME/.config/fish/aliases.fish
if test -e $alias_file
  . $alias_file
end

set local_file $HOME/.config.local.fish
if test -e $local_file
  . $local_file
end

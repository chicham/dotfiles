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

#### CONDA ####
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /home/hicham/.miniconda/bin/conda "shell.fish" "hook" $argv | source
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
set -x -U GPG_TTY (tty)
# gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
set -U -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

gpgconf --launch gpg-agent

#### ALIASES ####
alias ls="exa --icons"
alias ll="exa -al"
alias diff="delta"


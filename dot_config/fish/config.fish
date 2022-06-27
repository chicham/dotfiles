#### TMUX ####
# Adapted from https://github.com/fish-shell/fish-shell/issues/4434#issuecomment-332626369
# only run in interactive (not automated SSH for example)
if status is-interactive

  if not set -q TMUX # don't nest inside another tmux
  # Adapted from https://unix.stackexchange.com/a/176885/347104
  # Create session 'main' or attach to 'main' if already exists.
    if not set -q TMUX_SESSION_NAME
      tmux new-session -A -s main
    end
  end
end


set -x PATH "$HOME/go/bin/:$PATH"


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
set -gx GPG_TTY (tty)
set -u SSH_AGENT_PID
# gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

set -gx VISUAL nvim
set -gx EDITOR nvim
set -gx FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git --type f"
set -gx FZF_DEFAULT_OPTS "--layout=reverse --inline-info --height '80%' --select-1 --exit-0"
set FZF_PREVIEW_FILE '--ansi --preview-window "right:60%" --preview "bat --color=always --style=header,grid "'
set -U __done_exclude '(fg)'  # default: all git commands, except push and pull. accepts a regex.

set alias_file $HOME/.config/fish/aliases.fish
if test -e $alias_file
  source $alias_file
end

set local_file $HOME/.config.local.fish
if test -e $local_file
  . $local_file
end

source (pack completion --shell fish)
kubectl completion fish | source
gh completion -s fish | source
glab completion -s fish | source
chezmoi completion fish | source

function bwu
  set -gx BW_SESSION (bw unlock --raw $argv[1])
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<
#

function autotmux --on-variable TMUX_SESSION_NAME
        if test -n "$TMUX_SESSION_NAME" #only if set
    if test -z $TMUX #not if in TMUX
      if tmux has-session -t $TMUX_SESSION_NAME
        exec tmux new-session -t "$TMUX_SESSION_NAME"
      else
        exec tmux new-session -s "$TMUX_SESSION_NAME"
      end
    end
  end
end

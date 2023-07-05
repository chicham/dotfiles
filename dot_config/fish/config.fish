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


  set -U __done_exclude '(fg)'  # default: all git commands, except push and pull. accepts a regex.


function fish_user_key_bindings
  fzf_key_bindings
end

#### DIRENV ####
if command -v direnv &> /dev/null
  direnv hook fish | source
end

if command -v zoxide &> /dev/null
  zoxide init --cmd cd fish | source
end

#### GPG-AGENT ####

if command -v 1password &> /dev/null
  set -x SSH_AUTH_SOCK ~/.1password/agent.sock
end

if command -v nvim &> /dev/null
  set -gx VISUAL nvim
  set -gx EDITOR nvim
end

set alias_file $HOME/.config/fish/aliases.fish
if test -e $alias_file
  source $alias_file
end

set local_file $HOME/.config.local.fish
if test -e $local_file
  . $local_file
end

set local_bin $HOME/.local/bin

if test -d $local_bin
  set -gx PATH "$local_bin:$PATH"
end


if command -v gh &> /dev/null
  gh completion -s fish | source
end
if command -v glab &> /dev/null
  glab completion -s fish | source
end
if command -v chezmoi &> /dev/null
  chezmoi completion fish | source
end

if command -v starship &> /dev/null
  starship init fish | source
end

if command -v micromamba &> /dev/null
  micromamba shell hook --shell=fish | source
end
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

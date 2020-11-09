[[ ! -f $HOME/.config.zsh ]] && curl -fLo $HOME/.config.zsh https://raw.githubusercontent.com/Chrysostomus/manjaro-zsh-config/master/rootzshrc
source $HOME/.config.zsh

zstyle ':completion:*' menu select
zmodload zsh/complist
autoload -U zmv

[[ ! -d "$HOME/.antigen" ]] && git clone --depth 1 https://github.com/zsh-users/antigen.git "$HOME/.antigen"

source $HOME/.antigen/antigen.zsh

antigen init $HOME/.antigenrc

[ -f $HOME/.aliases ] && source $HOME/.aliases
[ -f $HOME/.git-extras-completion.zsh ] && source $HOME/.git-extras-completion.zsh
[ -f $HOME/.github.zsh ] && source $HOME/.github.zsh

FZF_ROOT=/usr/share/fzf
[ -f $FZF_ROOT/completion.zsh ] && source $FZF_ROOT/completion.zsh
[ -f $FZF_ROOT/key-bindings.zsh ] && source $FZF_ROOT/key-bindings.zsh


# Mandatory for login with the yubikey
# GPG Conf
#

if command -v gpgconf &> /dev/null
then

  export GPG_TTY="$(tty)"

  # Set SSH to use gpg-agent if it's enabled
  GNUPGCONFIG="${GNUPGHOME:-"$HOME/.gnupg"}/gpg-agent.conf"
  unset SSH_AGENT_PID
  if [[ -r $GNUPGCONFIG ]] && command grep -q enable-ssh-support "$GNUPGCONFIG"; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi

  # gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
  gpgconf --launch gpg-agent

fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
#


RG_PREFIX="rg --files-with-matches --column --no-messages"
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git --type f"
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info --height '80%' --select-1"
export FZF_PREVIEW_FILE='--ansi --preview-window "right:60%" --preview "bat --color=always --style=header,grid --line-range :300 {}"'

# Default file search commands
_fzf_compgen_path() { fd --hidden --follow --type=f  --exclude .git "$1"}

# Default directory search commands
_fzf_compgen_dir() { fd --hidden --follow --type=d --exclude .git "$1" }


fcd () {
  local selected=$(_fzf_cd $1 ${2:-$HOME})
    [ -n "$selected" ] && cd "$selected"
}

fif () {
  local INITIAL_QUERY=""
  local EXTRA_ARGS=""
  if (( $# == 1 )); then
    INITIAL_QUERY=$1
    shift
  else
    return 128
  fi
  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" fzf --ansi --ansi --preview-window "right:60%" --preview "cat {1} | rg $INITIAL_QUERY --context 3 --color=always --line-number --ignore-case"
}

peep() {
  local selected=$(fif $@)
  [ -n "$selected" ] && ${EDITOR:-vim} "$selected"
}



is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}


gconflict(){
  git diff --name-only --diff-filter=U
}

alias gcm='git commit -m'

eval "$(direnv hook zsh)"

[ -f $HOME/.zshenv ] && source $HOME/.zshenv

export RCRC="/home/$USERNAME/.dotfiles/rcrc rcup"

bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

export VISUAL="/usr/bin/nvim"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

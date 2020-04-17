#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...


source ~/.git-extras-completion.zsh
export FZF_ROOT=/usr/share/fzf
[ -f $FZF_ROOT/completion.zsh ] && source $FZF_ROOT/completion.zsh
[ -f $FZF_ROOT/key-bindings.zsh ] && source $FZF_ROOT/key-bindings.zsh



# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


alias ls='exa --icons'

export EDITOR=nvim
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpg-connect-agent updatestartuptty /bye > /dev/null
export PATH="/home/hicham/.texlive/2019/bin/x86_64-linux/:$PATH"
# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --ignore-case --glob --full-path'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --ignore-case --full-path'
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"



[[ -f ~/.Xresources ]] && xrdb ~/.Xresources

alias f='fzf'

# Will return non-zero status if the current directory is not managed by git
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

# Options to fzf command
export FZF_COMPLETION_OPTS='+c -x'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Use fd and fzf to get the args to a command.
# Works only with zsh
# Examples:
# ff mv # To move files. You can write the destination after selecting the files.
# ff 'echo Selected:'
# ff 'echo Selected music:' --extention mp3
# fm rm # To rm files in current directory
ff() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}" $HOME | fzf)}" )
    test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
}


fm() ff "$@" --max-depth 1

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
 fe() {
   local files
   IFS=$'\n' files=($(fd "$1" | fzf --multi --select-1 --exit-0))
   [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
 }

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  file=$(rg --files-with-matches --no-messages "$1" | fzf --ansi --preview-window "right:60%" --preview "bat --color=always --style=header,grid --line-range :300 {}" --layout=reverse --inline-info)
  [[ -n "$file" ]] && ${EDITOR:-vim} "${file}"
}


# Fuzzy change dir
fcd() {
  local dir
  dir=$(fd ${1:-.} -t d $HOME 2> /dev/null | fzf +m --select-1) && cd "$dir"
}


# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  is_in_git_repo || return
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fcb - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fcb() {
  is_in_git_repo || return
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s%d '..{2}'" ) || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# fco - checkout git commit
fco() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

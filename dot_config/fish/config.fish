# #### TMUX ####
# # Adapted from https://github.com/fish-shell/fish-shell/issues/4434#issuecomment-332626369
# # only run in interactive (not automated SSH for example)
# if command -v tmux &> /dev/null
#   if status is-interactive
#     if not set -q TMUX # don't nest inside another tmux
#     # Adapted from https://unix.stackexchange.com/a/176885/347104
#     # Create session 'main' or attach to 'main' if already exists.
#       if not set -q TMUX_SESSION_NAME
#         tmux new-session -A -s main
#       end
#     end
#   end
# end

# set -U __done_exclude '(fg)'  # default: all git commands, except push and pull. accepts a regex.

function zz
    set ZJ_SESSION (sk --ansi --interactive --exit-0 --select-1 -c \
  "zellij list-sessions -n -s")

    if test -z "$ZJ_SESSION"
        zellij attach -c
    else
        zellij attach $ZJ_SESSION
    end
end

if status is-interactive
    if command -v zellij &>/dev/null
        # Configure auto-attach/exit to your likings (default is off).
        # set ZELLIJ_AUTO_ATTACH true
        # set ZELLIJ_AUTO_EXIT true
        # zellij setup --generate-auto-start fish | source
        if not set -q ZELLIJ
            zz
        end
        zellij setup --generate-completion fish | source
    end
end

#### DIRENV ####
if command -v direnv &>/dev/null
    direnv hook fish | source
end

if command -v sk &>/dev/null
    source $HOME/.config/fish/functions/skim.fish
    skim_key_bindings
end

if command -v zoxide &>/dev/null
    zoxide init fish --cmd cd | source
    function __zoxide_z
        set -l argc (count $argv)
        if test $argc -eq 0
            __zoxide_cd $HOME
        else if test "$argv" = -
            __zoxide_cd -
        else if test $argc -eq 1 -a -d $argv[1]
            __zoxide_cd $argv[1]
        else if set -l result (string replace --regex $__zoxide_z_prefix_regex '' $argv[-1]); and test -n $result
            __zoxide_cd $result
        else
            set --local result (command zoxide query --exclude (__zoxide_pwd) --list -- "$argv" \
          | sk \
                      --no-sort \
                      --keep-right \
                      --height='40%' \
                      --layout='reverse' \
                      --exit-0 \
                      --select-1 \
                      --bind='ctrl-z:ignore' )
            and __zoxide_cd $result
        end
    end
end

#### GPG-AGENT ####

if command -v 1password &>/dev/null
    set -x SSH_AUTH_SOCK ~/.1password/agent.sock
end

if command -v nvim &>/dev/null
    set -gx VISUAL nvim
    set -gx EDITOR nvim
end

set alias_file $HOME/.config/fish/aliases.fish
if test -e $alias_file
    source $alias_file
end

set local_file $HOME/.config.local.fish
if test -e $local_file
    source $local_file
end

set local_bin $HOME/.local/bin

if test -d $local_bin
    set -gx PATH "$local_bin:$PATH"
end

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end


if command -v gh &>/dev/null
    gh completion -s fish | source
end

if command -v glab &>/dev/null
    glab completion -s fish | source
end

if command -v chezmoi &>/dev/null
    chezmoi completion fish | source
end

if command -v starship &>/dev/null
    starship init fish | source
end

function nfd -w fd -d 'fuzzy open one or multiple files in nvim'
    set result (sk --ansi --exit-0 --select-1 --print0 \
     --cmd="fd --type file --follow --unrestricted --color=always $argv"\
     --preview 'bat --color=always {}')
    if test -n "$result"
        nvim $result
    else
        return 1
    end
end


function nrg -w rg -d 'fuzzy find pattern in one or multiple files in nvim'
    set result (sk --ansi --exit-0 --select-1 --print0 \
  --delimiter : \
  --preview 'bat --color=always --highlight-line {2} {1}'\
  --preview-window '+{2}-/2' \
  --cmd="rg --color=always --line-number --no-heading --smart-case $argv" )

    if test -n "$result"
        echo $result | awk -v var="$result" -F: '{ printf "%s +%d", $1, $2;}' | xargs nvim
    else
        return 1
    end
end

# If .env missing; restore from .env.sample and validate
# See https://github.com/direnv/direnv/wiki/.envrc-Boilerplate
#if test -f .env.sample
#    if not command -v createnv >/dev/null
#        echo 'WARN|Createnv missing; try: pyenv local 3.x && pip install createnv'
#    else if not test -f .env
#        uvx createnv --use-default --overwrite || echo 'ERROR|https://github.com/cuducos/createnv'
#        if command dotenv-linter --version >/dev/null
#            dotenv-linter .env || echo 'ERROR|https://dotenv-linter.github.io'
#        end
#    end
#end

# The following functions are assumed to be defined elsewhere in your config
# You'll need to implement them according to your needs
#dotenv_if_exists || direnv status # https://direnv.net/man/direnv-stdlib.1.html

if test -e $HOME/.config/op/plugins.sh
    source $HOME/.config/op/plugins.sh
end

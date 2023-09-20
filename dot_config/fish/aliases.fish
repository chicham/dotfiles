alias ls="eza"
alias cat="bat"
alias ll="ls -al --icons"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e="$EDITOR"
alias g="git"
# alias gs='git stash'
alias gl="glab"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

function rsync-copy -w rsync -d 'rsync wrapper for comfort copy'
    command rsync -avhP $argv
end

function rsync-move -w rsync -d 'rsync wrapper for comfort move files'
    command rsync -avhP --remove-source-files $argv
end

function rsync-synchronize -w rsync -d 'rsync wrapper for directory synchronization'
    command rsync -avhP --update --delete $argv
end

function rsync-update -w rsync -d 'rsync wrapper for update (do not replace newer files on destination)'
    command rsync -avhP --update $argv
end

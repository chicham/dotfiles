function chezmoi_fugdiff
    set target $argv
    if test -z "$target"
        echo "Usage: chezmoi_fugdiff <file>"
        return 1
    end

    # Get the target path in the source state
    set source_path (chezmoi source-path $target)

    # Open nvim with fugitive diff
    nvim -c "Gvdiffsplit $target" $source_path
end

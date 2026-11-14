function _fuzzy_complete_preview_file --description 'Preview a file by MIME type: text, image, PDF or binary'
    # Usage: _fuzzy_complete_preview_file <path>
    # Text and JSON through bat (else cat), images through chafa as
    # character art (else the `file` summary), PDFs as text of their first
    # pages, anything else as a hex dump of the first KiB (hexyl, else xxd).
    set -l path $argv[1]
    set -l cols $FZF_PREVIEW_COLUMNS
    set -q cols[1]; or set cols 80
    set -l lines $FZF_PREVIEW_LINES
    set -q lines[1]; or set lines 40

    # A universal binary reports one MIME type per architecture.
    set -l mime (file --brief --mime-type -- $path)
    switch $mime[1]
        case 'text/*' application/json 'application/*script*' 'application/*xml' inode/x-empty
            if command -q bat
                bat --color=always --style=numbers --line-range=:500 -- $path
            else
                head -n 500 -- $path
            end
        case 'image/*'
            if command -q chafa
                # Character art: whether the terminal (and fzf's preview pane
                # inside it) passes sixel or kitty graphics is unknown.
                chafa --format=symbols --polite=on --size={$cols}x{$lines} -- $path
            else
                file --brief -- $path
            end
        case application/pdf
            if command -q pdftotext
                pdftotext -l 2 -layout -- $path - 2>/dev/null | head -n 200
            else
                file --brief -- $path
            end
        case '*'
            file --brief -- $path
            echo
            if command -q hexyl
                hexyl --length 1024 --border none -- $path
            else
                xxd -l 1024 -- $path
            end
    end
end

# view FILE - show a file with the viewer that suits it.
#
#   The viewer is picked from FILE's name, case-insensitively; FILE reaches it
#   unchanged, as its last argument unless stated below. A name starting with a
#   dash is handed over as ./NAME. Every other call (no argument, several
#   arguments, a flag, a directory, a missing file, or stdin that is a pipe or a
#   file) hands all arguments to the pager: bat, else batcat, else cat.
#   A viewer that is not installed falls back to the pager.
#   A lone .gz, .zst, .bz2 or .xz (neither .tar.* nor .log.*) goes to the pager.
#   When the extension is not all lowercase, ouch is told the format, and
#   Markdown reaches mcat on stdin.
#   Tables, structured data and compressed logs print and return: the pager
#   shows the formatter's output without wrapping, paging only when longer than
#   the screen:
#     json yaml yml toml      fx --no-tui
#     log.{gz,zst,bz2,xz}     lnav -n, without colour
#   duckdb formats tables to the terminal width (COLUMNS, else the controlling
#   terminal's, else 80):
#     csv tsv parquet xlsx    the first 40 rows
#     sqlite db               read-only, 40 rows of the first table
#   A database with several tables, or a workbook with several sheets, lists
#   them all first. Tables and structured data are in colour only when stdout is
#   a terminal and NO_COLOR is empty.
#   duckdb never downloads an extension here: xlsx needs `excel` and SQLite
#   needs `sqlite` installed beforehand. arrow and xls go to the pager.
#   Programs see BAT_CONFIG_DIR, ~/.config/bat unless already set; no variable
#   of the calling shell changes.
#   The status is the one of the program that was started. For what prints and
#   returns it is the formatter's, or the pager's when the pager fails;
#   quitting the pager early counts as success.
#   Tools are run with `command`, so aliases and functions of the same name are
#   ignored.
function view --description 'Show a file with the viewer matching its extension'
    set -l config_dir "$BAT_CONFIG_DIR"
    test -n "$config_dir"; or set config_dir $HOME/.config/bat
    set -lx BAT_CONFIG_DIR $config_dir

    # The external test sees this function's stdin; the builtin does not.
    # /dev/null or a closed stdin carries no data to show.
    if command test -p /dev/stdin
        or command test -f /dev/stdin
        or test (count $argv) -ne 1
        or not test -f "$argv[1]"
        __view_pager $argv
        return
    end

    set -l file $argv[1]
    if string match -q -- '-*' $file
        set file ./$file
    end
    set -l name (string replace -r -- '(?s)^.*/' '' $file | string lower | string collect)

    # These print through the pager instead of opening a viewer.
    set -l sink cat
    for cmd in bat batcat
        if command -q $cmd
            # The language stops bat from highlighting over the formatter's colours.
            set sink $cmd --language=txt --style=plain --paging=auto --wrap=never
            break
        end
    end

    switch "$name"
        case '*.csv' '*.tsv' '*.parquet' '*.xlsx' '*.sqlite' '*.db'
            if not command -q duckdb
                __view_pager $file
                return
            end
            set -l cols (__view_columns)
            set -l highlight
            if command test -t 1; and test -z "$NO_COLOR"
                set highlight -cmd '.highlight_results on'
            end
            # duckdb treats [ * ? in a file to read as a pattern, which can
            # select a different file.
            set -lx V_FILE (__view_path $file | string replace -a '[' '[[]' \
                | string replace -a '*' '[*]' | string replace -a '?' '[?]' | string collect)
            set -l read __view_duckdb $cols -cmd '.maxrows 40' $highlight -c
            switch "$name"
                case '*.csv'
                    $read "from read_csv(getenv('V_FILE'), hive_partitioning=false)" | command $sink
                case '*.tsv'
                    $read "from read_csv(getenv('V_FILE'), delim=chr(9), header=true, hive_partitioning=false)" | command $sink
                case '*.parquet'
                    $read "from read_parquet(getenv('V_FILE'), hive_partitioning=false)" | command $sink
                case '*.xlsx'
                    begin
                        __view_sheets $file
                        $read "from read_xlsx(getenv('V_FILE'))"
                    end | command $sink
                case '*'
                    __view_database $file $cols $highlight | command $sink
            end
            __view_status $pipestatus
            return
        case '*.json' '*.yaml' '*.yml' '*.toml'
            if not command -q fx
                __view_pager $file
                return
            end
            # fx writes to the pager's pipe, so it has to be forced to colour.
            # The unexported local hides any CLICOLOR_FORCE of the caller.
            set -l CLICOLOR_FORCE
            if command test -t 1; and test -z "$NO_COLOR"
                set -x CLICOLOR_FORCE 1
            end
            command fx --no-tui $file | command $sink
            __view_status $pipestatus
            return
        case '*.log.gz' '*.log.zst' '*.log.bz2' '*.log.xz'
            if not command -q lnav
                __view_pager $file
                return
            end
            command lnav -n $file | command $sink
            __view_status $pipestatus
            return
    end

    # The first match wins, so compound extensions precede their last suffix.
    set -l viewer
    switch "$name"
        case '*.tar.gz' '*.tar.xz' '*.tar.zst' '*.tar.bz2'
            set viewer ouch list --tree
        case '*.md' '*.markdown' '*.pdf' '*.docx' '*.pptx' '*.html' '*.htm'
            set viewer mcat
        case '*.png' '*.jpg' '*.jpeg' '*.gif' '*.webp' '*.svg'
            set viewer mcat
        case '*.mp4' '*.mov' '*.mkv' '*.webm'
            set viewer mcat
        case '*.jsonl' '*.ndjson'
            set viewer hl
        case '*.tgz' '*.txz' '*.tzst' '*.tbz2' '*.tbz' '*.tar'
            set viewer ouch list --tree
        case '*.zip' '*.7z' '*.rar'
            set viewer ouch list --tree
        case '*.bin' '*.exe' '*.elf' '*.so' '*.dylib' '*.o' '*.a' '*.wasm' '*.pcap' '*.pcapng'
            set viewer hexyl
        case '*'
            __view_pager $file
            return
    end

    if not command -q $viewer[1]
        __view_pager $file
        return
    end

    # The extension that decides the format, keeping the two parts of a tar suffix.
    set -l ext (string match -r -- '(?:tar\.(?:gz|xz|zst|bz2)|[^.]*)$' "$name")

    # ouch and mcat recognise some or all of their formats in lowercase only.
    if not string match -q -- "*.$ext" $file
        switch "$viewer[1]:$ext"
            case 'ouch:*'
                set -a viewer --format $ext
            case mcat:md mcat:markdown
                command mcat -e md <$file
                return
        end
    end

    command $viewer $file
end

function __view_pager --description 'view: hand the arguments to bat, batcat or cat'
    for cmd in bat batcat
        if command -q $cmd
            command $cmd $argv
            return
        end
    end
    command cat $argv
end

# __view_status FORMATTER PAGER - the status of that pipeline.
function __view_status --description 'view: status of a formatter piped into the pager'
    set -l result $argv[2]
    test $result -ne 0; or set result $argv[1]
    # 141 is SIGPIPE: the pager was quit before the formatter finished.
    test $result -ne 141; or set result 0
    return $result
end

function __view_columns --description 'view: width available to a table'
    set -l cols "$COLUMNS"
    if not string match -qr -- '^[1-9][0-9]*$' "$cols"
        # stdout is captured, so only the controlling terminal knows.
        set -l size (begin
            command stty size </dev/tty
        end 2>/dev/null)
        set cols (string split -- ' ' "$size")[-1]
    end
    string match -r -- '^[1-9][0-9]*$' "$cols"; or echo 80
end

# A relative path that cannot be taken for an option or a URL.
function __view_path --description 'view: anchor a relative path'
    if string match -qr -- '^(/|\./)' $argv[1]
        printf '%s\n' $argv[1]
    else
        printf '%s\n' ./$argv[1]
    end
end

# __view_duckdb COLUMNS ARG...
function __view_duckdb --description 'view: duckdb with the settings of a preview'
    command duckdb -no-init -dark-mode -cmd 'SET autoinstall_known_extensions=false' \
        -cmd ".maxwidth $argv[1]" $argv[2..]
end

# Prints the sheet list of a workbook that has several; nothing otherwise, or
# when the names cannot be extracted.
function __view_sheets --description 'view: list the sheets of a workbook'
    set -l file $argv[1]
    set -l xml
    if command -q bsdtar
        # From stdin, so the file name is never taken as a pattern.
        set xml (command bsdtar -xOf - xl/workbook.xml <$file 2>/dev/null | string collect)
    else if command -q unzip; and not string match -qr -- '[\[*?]' $file
        set xml (command unzip -p $file xl/workbook.xml 2>/dev/null | string collect)
    end
    set -l names (string match -arg -- '<(?:[A-Za-z0-9]+:)?sheet [^>]*name="([^"]*)"' "$xml")
    test (count $names) -gt 1; or return 0
    set names (string replace -a -- '&lt;' '<' $names)
    set names (string replace -a -- '&gt;' '>' $names)
    set names (string replace -a -- '&quot;' '"' $names)
    set names (string replace -a -- '&apos;' "'" $names)
    set names (string replace -a -- '&amp;' '&' $names)
    echo Sheets:
    printf '  %s\n' $names
    printf '\nPreview of %s:\n' $names[1]
end

# __view_database FILE COLUMNS [HIGHLIGHT_FLAG...]
function __view_database --description 'view: preview a SQLite or DuckDB database'
    set -l cols $argv[2]
    set -l highlight $argv[3..]
    set -l path (__view_path $argv[1] | string replace -a "'" "''" | string collect)
    # ATTACH, after the settings, rather than a database argument: opening an
    # argument precedes them and may download an extension.
    set -l attach "attach '$path' as v (read_only);"
    set -l tables "(select 0 as kind, schema_name as s, table_name as t
      from duckdb_tables() where database_name = 'v' and not internal
    union all select 1, schema_name, view_name
      from duckdb_views() where database_name = 'v' and not internal)"
    # SQLite columns may hold any type, which only reads reliably as text.
    set -l text -cmd 'SET sqlite_all_varchar=true'
    # One quoted, qualified name per line, ready to be used in a query.
    set -l names (__view_duckdb $cols $text -list -noheader -c "$attach
    select concat_ws('.', '\"v\"', '\"' || replace(s, '\"', '\"\"') || '\"',
      '\"' || replace(t, '\"', '\"\"') || '\"')
    from $tables order by kind, s, t")
    or return
    if test (count $names) -eq 0
        echo 'No tables.'
        return 0
    end
    if test (count $names) -gt 1
        __view_duckdb $cols $text -cmd '.maxrows -1' -c "$attach
      select s as schema, t as name,
        case kind when 0 then 'table' else 'view' end as type
      from $tables order by kind, s, t"
        or return
        printf '\nPreview of %s:\n' (string replace -r -- '^"v"\.' '' $names[1])
    end
    __view_duckdb $cols -cmd '.maxrows 40' $highlight $text -c "$attach from $names[1]"
end

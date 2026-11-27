#!/usr/bin/env bats
# run sets status, output and lines in the calling shell.
# shellcheck disable=SC2030,SC2031
# The fish function `view` against fake viewers that print their name and
# arguments. PATH holds only the fakes plus env, stty and test, so no installed
# tool can stand in for a missing one.

bats_require_minimum_version 1.5.0

PAGED="bat --language=txt --style=plain --paging=auto --wrap=never"

setup() {
  load 'helpers/setup'
  command -v fish > /dev/null 2>&1 || skip "fish not available"
  FISH=$(command -v fish)
  SRC="$REPO_ROOT/dot_config/fish/functions/view.fish"
  BIN="$BATS_TEST_TMPDIR/bin"
  SYS="$BATS_TEST_TMPDIR/sys"
  WORK="$BATS_TEST_TMPDIR/work"
  export XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/xdg/config"
  export XDG_DATA_HOME="$BATS_TEST_TMPDIR/xdg/data"
  mkdir -p "$BIN" "$SYS" "$WORK" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
  local tool
  for tool in env stty test; do
    ln -s "$(type -P "$tool")" "$SYS/$tool"
  done
  # `view ARG...` in a fresh fish, as a program so env and python can start it.
  {
    echo '#!/bin/sh'
    echo "exec '$FISH' --no-config -c 'source \$argv[1]; view \$argv[2..]' -- '$SRC' \"\$@\""
  } > "$SYS/view"
  chmod +x "$SYS/view"
  for tool in bat batcat cat mcat fx hl lnav ouch hexyl; do
    cat > "$BIN/$tool" << 'FAKE'
#!/bin/sh
printf '%s' "${0##*/}"
for a in "$@"; do printf ' [%s]' "$a"; done
echo
FAKE
    chmod +x "$BIN/$tool"
  done
  # The table pager echoes its flags, then what duckdb piped into it.
  cat > "$BIN/duckdb" << 'FAKE'
#!/bin/sh
printf 'duckdb V_FILE=%s' "${V_FILE-}"
for a in "$@"; do printf ' [%s]' "$a"; done
echo
FAKE
  chmod +x "$BIN/duckdb"
  cd "$WORK" || return 1
}

# Run view with stdin on /dev/null, as when no data is fed to it.
view() {
  PATH="$BIN:$SYS" "$SYS/view" "$@" < /dev/null
}

fake_bat_prints_config_dir() {
  # shellcheck disable=SC2016  # the fake expands the variable, not this shell
  printf '#!/bin/sh\necho "$BAT_CONFIG_DIR"\n' > "$BIN/bat"
}

# routes VIEWER FILE... — each FILE is created, then must reach VIEWER alone.
routes() {
  local viewer="$1" f
  shift
  for f in "$@"; do
    : > "$f"
    run view "$f"
    if [ "$status" -ne 0 ] || [ "$output" != "$viewer [$f]" ]; then
      echo "$f: expected '$viewer [$f]', got status $status '$output'" >&2
      return 1
    fi
  done
}

@test "documents, images and videos go to mcat" {
  routes mcat a.md a.markdown a.pdf a.docx a.pptx a.html a.htm a.png a.jpg \
    a.jpeg a.gif a.webp a.svg a.mp4 a.mov a.mkv a.webm
}

# printed VIEWER FILE... — each FILE is created; the output of VIEWER, a command
# with its flag, must be paged without wrapping.
printed() {
  local viewer="$1" f
  shift
  table_pager
  for f in "$@"; do
    : > "$f"
    run view "$f"
    if [ "$status" -ne 0 ] \
      || [ "$output" != "$PAGED"$'\n'"$viewer [$f]" ]; then
      echo "$f: expected paged '$viewer [$f]', got status $status '$output'" >&2
      return 1
    fi
  done
}

@test "structured config is printed by fx and paged" {
  printed 'fx [--no-tui]' a.json a.yaml a.yml a.toml B.JSON 'my file.Yml'
}

@test "JSON lines go to hl" {
  routes hl a.jsonl a.ndjson
}

@test "compressed logs are printed by lnav and paged" {
  printed 'lnav [-n]' a.log.gz a.log.zst a.log.bz2 a.log.xz APP.LOG.GZ
}

@test "a formatter failure is the exit status and its message is shown" {
  table_pager
  local pair tool f
  for pair in fx:a.json lnav:a.log.gz; do
    tool=${pair%%:*}
    f=${pair#*:}
    : > "$f"
    printf '#!/bin/sh\necho broken >&2\nexit 3\n' > "$BIN/$tool"
    run view "$f"
    [ "$status" -eq 3 ] || return 1
    [[ $output == *broken* ]] || return 1
  done
}

# An fx that reports whether it was asked to force colour.
colour_fx() {
  table_pager
  # shellcheck disable=SC2016  # the fake expands this, not this shell
  printf '#!/bin/sh\necho "force=${CLICOLOR_FORCE-unset}"\n' > "$BIN/fx"
  : > a.json
}

@test "fx is not forced to colour without a terminal" {
  colour_fx
  CLICOLOR_FORCE=1 run view a.json
  [ "${lines[1]}" = "force=unset" ]
}

@test "fx is forced to colour on a terminal unless NO_COLOR is set" {
  colour_fx
  pty() {
    python3 "$REPO_ROOT/tests/helpers/in_pty.py" 100 env "$@" PATH="$BIN:$SYS" \
      "$SYS/view" a.json
  }
  run pty -u NO_COLOR -u CLICOLOR_FORCE
  [[ $output == *force=1* ]] || return 1
  run pty NO_COLOR=1 CLICOLOR_FORCE=1
  [[ $output == *force=unset* ]]
}

@test "archives are listed by ouch" {
  routes 'ouch [list] [--tree]' a.tar.gz a.tgz a.tar.xz a.txz a.tar.zst a.tzst \
    a.tar.bz2 a.tbz2 a.tbz a.zip a.tar a.7z a.rar
}

@test "lone compressed files go to bat" {
  routes bat a.gz a.zst a.bz2 a.xz a.json.gz A.CSV.XZ
}

@test "binaries go to hexyl" {
  routes hexyl a.bin a.exe a.elf a.so a.dylib a.o a.a a.wasm a.pcap a.pcapng
}

@test "plain logs, unknown and missing extensions go to bat" {
  routes bat a.log a.txt a.py Makefile .bashrc md json
}

@test ".log.gz, .gz and .tar.gz take different routes" {
  routes bat app.gz
  routes 'ouch [list] [--tree]' app.log.tar.gz
  printed 'lnav [-n]' app.log.gz
}

@test "extensions match in any case and the path is passed unchanged" {
  routes mcat Photo.JpEg SCAN.PDF Slides.PPTX Report.Docx PAGE.HTML
}

@test "ouch is told the format when the extension is not lowercase" {
  local pair f
  for pair in zip:A.ZIP 7z:a.7Z rar:a.Rar tar:A.TAR tgz:A.TGZ txz:a.Txz \
    tzst:a.TZST tbz2:a.TBZ2 tbz:a.TBZ tar.gz:B.TAR.GZ tar.gz:c.TAR.gz \
    tar.xz:d.tar.XZ tar.zst:e.Tar.Zst tar.bz2:f.TAR.BZ2; do
    f=${pair#*:}
    routes "ouch [list] [--tree] [--format] [${pair%%:*}]" "$f" || return 1
  done
}

@test "ouch detects the format itself when only the stem has capitals" {
  routes 'ouch [list] [--tree]' DATA.tar.gz Backup.zip
}

@test "Markdown with a non-lowercase extension reaches mcat on stdin" {
  # shellcheck disable=SC2016  # the fake expands these, not this shell
  printf '#!/bin/sh\nprintf "mcat"; printf " [%%s]" "$@"; read -r line; echo " <$line"\n' \
    > "$BIN/mcat"
  local f
  for f in A.MD b.Markdown 'c d.mD'; do
    echo "text of $f" > "$f"
    run view "$f"
    [ "$status" -eq 0 ] || return 1
    [ "$output" = "mcat [-e] [md] <text of $f" ] || return 1
  done
}

@test "a missing mcat still pages an uppercase Markdown file by name" {
  rm "$BIN/mcat"
  routes bat A.MD
}

@test "only the basename selects the viewer" {
  mkdir dir.json
  routes bat dir.json/notes
}

@test "a path with spaces stays one argument" {
  printed 'fx [--no-tui]' 'my file.json'
}

@test "a symlink to a regular file is routed by its own name" {
  table_pager
  : > target
  ln -s target link.json
  run view link.json
  [ "$output" = "$PAGED"$'\n'"fx [--no-tui] [link.json]" ]
}

@test "no argument goes to bat" {
  run view
  [ "$status" -eq 0 ]
  [ "$output" = "bat" ]
}

@test "two arguments go to bat" {
  : > a.json
  : > b.png
  run view a.json b.png
  [ "$output" = "bat [a.json] [b.png]" ]
}

@test "a lone flag goes to bat" {
  run view --list-themes
  [ "$output" = "bat [--list-themes]" ]
}

@test "a flag with a file goes to bat" {
  : > a.json
  run view -p a.json
  [ "$output" = "bat [-p] [a.json]" ]
}

@test "a directory goes to bat" {
  mkdir d.zip
  run view d.zip
  [ "$output" = "bat [d.zip]" ]
}

@test "a missing file goes to bat" {
  run view gone.json
  [ "$output" = "bat [gone.json]" ]
}

@test "a broken symlink goes to bat" {
  ln -s nowhere broken.json
  run view broken.json
  [ "$output" = "bat [broken.json]" ]
}

@test "piped stdin goes to bat" {
  : > a.json
  piped() { echo data | PATH="$BIN:$SYS" "$SYS/view" "$@"; }
  run piped a.json
  [ "$output" = "bat [a.json]" ]
}

@test "stdin redirected from a file goes to bat" {
  : > a.json
  echo data > input
  redirected() { PATH="$BIN:$SYS" "$SYS/view" "$@" < input; }
  run redirected a.json
  [ "$output" = "bat [a.json]" ]
}

@test "each missing viewer falls back to bat" {
  local pair tool f
  for pair in mcat:a.md fx:a.json duckdb:a.csv hl:a.jsonl lnav:a.log.gz ouch:a.zip hexyl:a.bin; do
    tool=${pair%%:*}
    f=${pair#*:}
    : > "$f"
    mv "$BIN/$tool" "$BIN/$tool.off"
    run view "$f"
    mv "$BIN/$tool.off" "$BIN/$tool"
    if [ "$status" -ne 0 ] || [ "$output" != "bat [$f]" ]; then
      echo "without $tool: status $status '$output'" >&2
      return 1
    fi
  done
}

@test "batcat replaces a missing bat" {
  rm "$BIN/bat"
  : > a.json
  rm "$BIN/fx"
  run view a.json
  [ "$output" = "batcat [a.json]" ]
  run view
  [ "$output" = "batcat" ]
}

@test "cat is the last resort" {
  rm "$BIN/bat" "$BIN/batcat" "$BIN/hexyl"
  : > a.bin
  run view a.bin
  [ "$status" -eq 0 ]
  [ "$output" = "cat [a.bin]" ]
  run view a.bin a.bin
  [ "$output" = "cat [a.bin] [a.bin]" ]
}

@test "BAT_CONFIG_DIR defaults to ~/.config/bat" {
  fake_bat_prints_config_dir
  unset BAT_CONFIG_DIR
  HOME="$WORK/home" run view
  [ "$output" = "$WORK/home/.config/bat" ]
}

@test "a preset BAT_CONFIG_DIR is kept" {
  fake_bat_prints_config_dir
  BAT_CONFIG_DIR=/elsewhere run view
  [ "$output" = "/elsewhere" ]
}

# A bat that shows its flags and copies stdin, as the table pager does.
table_pager() {
  # shellcheck disable=SC2016  # the fake expands these, not this shell
  printf '#!/bin/sh\necho "bat $*"\nwhile IFS= read -r l; do echo "$l"; done\n' \
    > "$BIN/bat"
}

# table FILE CALL — FILE is created; duckdb must read it with CALL and page it.
table() {
  : > "$1"
  COLUMNS=123 run view "$1"
  [ "$status" -eq 0 ] \
    && [ "${lines[0]}" = "$PAGED" ] \
    && [[ ${lines[1]} == "duckdb V_FILE=./$1 [-no-init] "* ]] \
    && [[ $output == *"[SET autoinstall_known_extensions=false] [-cmd] [.maxwidth 123] [-cmd] [.maxrows 40] [-c] [$2]" ]] \
    || {
      echo "$1: status $status '$output'" >&2
      return 1
    }
}

@test "tables are read by duckdb and paged without wrapping" {
  table_pager
  local f
  for f in a.csv B.CSV; do
    table "$f" "from read_csv(getenv('V_FILE'), hive_partitioning=false)"
  done
  table a.Tsv "from read_csv(getenv('V_FILE'), delim=chr(9), header=true, hive_partitioning=false)"
  table a.parquet "from read_parquet(getenv('V_FILE'), hive_partitioning=false)"
  table a.xlsx "from read_xlsx(getenv('V_FILE'))"
}

@test "pattern characters in a table name are escaped for duckdb" {
  table_pager
  : > 'a[1]*?.csv'
  run view 'a[1]*?.csv'
  [[ $output == *"V_FILE=./a[[]1][*][?].csv ["* ]]
}

@test "arrow and xls go to bat" {
  routes bat a.arrow a.xls
}

@test "an unusable COLUMNS without a terminal means 80 columns" {
  table_pager
  : > a.csv
  # setsid: no controlling terminal to ask
  COLUMNS=0 run python3 -c 'import subprocess, sys
sys.exit(subprocess.run(sys.argv[1:], start_new_session=True,
                        stdin=subprocess.DEVNULL).returncode)' \
    env PATH="$BIN:$SYS" "$SYS/view" a.csv
  [ "$status" -eq 0 ]
  [[ $output == *"[.maxwidth 80]"* ]]
  [[ $output != *highlight* ]]
}

@test "on a terminal the width is the terminal's and colour is on" {
  table_pager
  : > a.csv
  run env -u COLUMNS -u NO_COLOR python3 "$REPO_ROOT/tests/helpers/in_pty.py" \
    101 env PATH="$BIN:$SYS" "$SYS/view" a.csv
  [ "$status" -eq 0 ]
  [[ $output == *"[.maxwidth 101]"*"[.highlight_results on]"* ]]
  NO_COLOR=1 run python3 "$REPO_ROOT/tests/helpers/in_pty.py" \
    101 env PATH="$BIN:$SYS" "$SYS/view" a.csv
  [[ $output != *highlight* ]]
}

# A database whose table list is the lines of $WORK/tables.
fake_database() {
  table_pager
  # shellcheck disable=SC2016  # the fake expands these, not this shell
  printf '#!/bin/sh\ncase "$*" in\n*-noheader*) while read -r l; do echo "$l"; done < tables ;;\n*"as type"*) echo LISTING ;;\n*) for a; do last=$a; done; echo "$last" ;;\nesac\n' \
    > "$BIN/duckdb"
  : > "$1"
}

@test "a database with one table is attached read-only and previewed" {
  fake_database a.db
  echo '"v"."main"."t"' > tables
  run view a.db
  [ "$status" -eq 0 ]
  [[ $output == *"attach './a.db' as v (read_only); from \"v\".\"main\".\"t\"" ]]
  [[ $output != *LISTING* ]]
}

@test "a database with several tables lists them before the first" {
  fake_database "it's.SQLite"
  printf '"v"."main"."a"\n"v"."main"."b"\n' > tables
  run view "it's.SQLite"
  [ "$status" -eq 0 ]
  [[ $output == *LISTING*'Preview of "main"."a":'* ]]
  [[ $output == *"attach './it''s.SQLite' as v (read_only); from \"v\".\"main\".\"a\"" ]]
}

@test "an empty database says so" {
  fake_database a.sqlite
  : > tables
  run view a.sqlite
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "No tables." ]
}

@test "a workbook with several sheets lists them first" {
  table_pager
  printf '#!/bin/sh\necho %s\n' \
    "'<sheet name=\"One\" r=\"1\"/><sheet name=\"A &amp; B\"/>'" > "$BIN/bsdtar"
  chmod +x "$BIN/bsdtar"
  : > a.xlsx
  run view a.xlsx
  [ "$status" -eq 0 ]
  [[ $output == *"Sheets:"*"  One"*"  A & B"*"Preview of One:"*read_xlsx* ]]
}

@test "a duckdb failure is the exit status" {
  table_pager
  printf '#!/bin/sh\nexit 3\n' > "$BIN/duckdb"
  for f in a.parquet a.db; do
    : > "$f"
    run view "$f"
    [ "$status" -eq 3 ] || return 1
  done
}

@test "a pager failure is the exit status, quitting it early is not" {
  : > a.csv
  printf '#!/bin/sh\nexit 2\n' > "$BIN/bat"
  run view a.csv
  [ "$status" -eq 2 ]
  printf '#!/bin/sh\nexit 141\n' > "$BIN/bat"
  run view a.csv
  [ "$status" -eq 0 ]
}

@test "without bat a table is printed by cat" {
  rm "$BIN/bat" "$BIN/batcat" "$BIN/cat"
  ln -s /bin/cat "$BIN/cat"
  : > a.csv
  run view a.csv
  [ "$status" -eq 0 ]
  [[ $output == "duckdb V_FILE=./a.csv "* ]]
}

@test "view passes fish_indent" {
  run fish_indent --check "$SRC"
  [ "$status" -eq 0 ]
}

@test "a pattern in a subdirectory matches without a local file of that kind" {
  mkdir sub
  : > sub/a.md
  run view sub/a.md
  [ "$output" = "mcat [sub/a.md]" ]
}

@test "a name that is only an extension is routed" {
  routes mcat .md
}

@test "a leading dash reaches the viewer as ./NAME" {
  : > -a.md
  run view -a.md
  [ "$output" = "mcat [./-a.md]" ]
  table_pager
  : > -a.json
  run view -a.json
  [ "$output" = "$PAGED"$'\n'"fx [--no-tui] [./-a.json]" ]
  : > -a.csv
  run view -a.csv
  [[ $output == *"V_FILE=./-a.csv "* ]]
}

@test "quotes, dollars and parentheses stay in one argument" {
  routes mcat "it's \"q\" \$HOME (1);.md"
}

# in_shell CODE — CODE in one fish that has sourced view, stdin on /dev/null.
in_shell() {
  PATH="$BIN:$SYS" "$FISH" --no-config -c "source '$SRC'; $1" < /dev/null
}

@test "view returns to the calling shell on every kind of route" {
  table_pager
  : > a.csv
  : > a.json
  : > a.log.gz
  : > a.md
  : > B.MD
  : > a.txt
  local call
  for call in 'view a.csv' 'view a.json' 'view a.log.gz' 'view a.md' \
    'view B.MD' 'view a.txt' 'view' 'view gone'; do
    run in_shell "$call >/dev/null; echo alive \$status"
    [ "$output" = "alive 0" ] || {
      echo "$call: '$output'" >&2
      return 1
    }
  done
  printf '#!/bin/sh\nexit 4\n' > "$BIN/mcat"
  run in_shell 'view a.md; echo alive $status'
  [ "$output" = "alive 4" ]
}

@test "no variable of the calling shell changes" {
  table_pager
  : > a.csv
  : > a.json
  : > a.md
  # shellcheck disable=SC2016  # fish expands this
  local code='set -g CLICOLOR_FORCE keep
    set -l before (set --names)
    view a.csv >/dev/null; view a.json >/dev/null; view a.md >/dev/null
    set -l after (set --names)
    for n in $after; contains -- $n $before before; or echo new $n; end
    set -q BAT_CONFIG_DIR; and echo leaked BAT_CONFIG_DIR
    set -q V_FILE; and echo leaked V_FILE
    echo $CLICOLOR_FORCE; set -S CLICOLOR_FORCE | string match -q "*unexported*"; and echo unexported'
  unset BAT_CONFIG_DIR V_FILE CLICOLOR_FORCE
  run in_shell "$code"
  [ "$output" = $'keep\nunexported' ] || {
    echo "$output" >&2
    return 1
  }
}

@test "a caller's unexported BAT_CONFIG_DIR reaches the pager and stays unexported" {
  fake_bat_prints_config_dir
  unset BAT_CONFIG_DIR
  run in_shell 'set -g BAT_CONFIG_DIR /mine; view; env | string match "BAT_CONFIG_DIR=*"; echo end'
  [ "$output" = $'/mine\nend' ]
}

@test "piped stdin inside a shell pipeline reaches the pager" {
  : > a.json
  printf '#!/bin/sh\nread -r l; echo "bat $* <$l"\n' > "$BIN/bat"
  run in_shell 'echo data | view a.json'
  [ "$output" = "bat a.json <data" ]
}

@test "a formatter stopped by a quit pager is success" {
  printf '#!/bin/sh\nexit 141\n' > "$BIN/duckdb"
  : > a.csv
  run view a.csv
  [ "$status" -eq 0 ]
}

@test "the alias v runs view in an interactive shell" {
  command -v chezmoi > /dev/null 2>&1 || skip "chezmoi not available"
  local h
  h=$(mk_fake_home)
  seed_chezmoi_config "$h" '{"modules":[]}'
  chezmoi_render "$h" dot_config/fish/aliases.fish.tmpl > aliases.fish
  : > a.md
  run env PATH="$BIN:$SYS" "$FISH" --no-config -i -c \
    "source '$SRC'; source aliases.fish; v a.md" < /dev/null
  [ "$status" -eq 0 ]
  [[ $output == *"mcat [a.md]" ]]
}

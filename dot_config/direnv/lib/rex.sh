# direnv loads every ~/.config/direnv/lib/*.sh before an .envrc.
#
# use_rex — in an .envrc, move the Rex pane that enters this project into the
# project's Rex session. The rules live in the header of ~/.local/bin/rex-attach.
# A failure is reported and never blocks the rest of the .envrc.
use_rex() {
  command -v rex-attach >/dev/null 2>&1 || return 0
  rex-attach "$PWD" || log_error "use rex: rex-attach failed"
}

---
name: zellij
description: "Run shell commands inside a visible zellij floating pane while still capturing their stdout/stderr and exit code. This skill should be used when the user wants to watch commands execute live in zellij, asks to run bash/commands in a floating pane, or asks to route command execution through zellij so they can monitor what the agent is doing. Requires running inside a zellij session."
user-invocable: true
allowed-tools: Bash
---

# Run commands in a zellij floating pane

When this skill is active, run shell commands through the `zbash` helper instead
of executing them silently. Each command runs in a **floating zellij pane pinned
to the current Claude Code tab**, so the user watches it live, while `zbash`
still returns the command's stdout/stderr and real exit code to you.

## How to use it

For a command you would normally run with the Bash tool, wrap it:

```
zbash <command>
```

Examples:

```
zbash cargo test
zbash 'rg -n TODO src/ | head'
zbash './scripts/deploy.sh --dry-run'
```

Read `zbash`'s stdout and exit code exactly as you would a normal command —
they reflect the wrapped command, not the pane. A non-zero exit propagates.

## What it does (so you can reason about failures)

- Opens a floating pane via `zellij action new-pane --floating --tab-id <caller's tab>`.
  Resolving the caller's tab needs `jq`; if `jq` is missing or `ZELLIJ_PANE_ID`
  is unset, it falls back to `zellij run --floating`, which lands the pane on the
  **currently active** tab — not necessarily the one hosting Claude Code.
- The pane runs the command in your **current working directory**, `tee`s output
  to a temp file (so the user sees it live and you get it un-truncated), and
  records `$?` to a temp file.
- `zbash` blocks until that exit-code file appears, prints the captured output,
  and exits with the same code.

## Knobs

- `ZBASH_TIMEOUT=<seconds>` — max wait before giving up (default 600).
- `ZBASH_KEEP=1` — leave the pane open after the command exits (default: close).

## When NOT to use it

- **Long-lived / never-exiting processes** (dev servers, file watchers, `tail
  -f`, anything that stays up until you kill it): `zbash` blocks until the
  command records an exit code, so it will hang for the full `ZBASH_TIMEOUT`,
  then report a spurious timeout while the process keeps running orphaned in the
  pane. Start those directly in their own zellij pane (`zellij run --floating --
  <cmd>`) or background them — don't wrap them in `zbash`.
- **Interactive / TUI programs** (editors, `top`, REPLs, anything needing
  keystrokes): a one-shot capture pane is the wrong tool. Drive those with
  `zellij action write-chars` / `send-keys` + `dump-screen` instead, or the
  built-in `run`/`verify` skills.
- **Not inside a zellij session**: `zbash` detects this (`$ZELLIJ` unset) and
  just runs the command normally — no pane, no breakage.
- Trivial, instantaneous commands where a flashing pane adds nothing — use the
  plain Bash tool.

## Related

The `cc-wt` launcher (separate, not part of this skill) uses the same
tab-pinned-floating-pane mechanism to run `claude --worktree` as a jj workspace
in a floating pane. It's a fish function (`dot_config/fish/functions/cc-wt.fish`)
that prepends the `git`/`tmux` shims in `~/.local/share/cc-zellij/bin/` to `PATH`,
which is where the tmux→zellij-floating-pane translation lives.

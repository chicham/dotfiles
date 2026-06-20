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

- Opens a floating pane via `zellij action new-pane --floating --tab-id <caller's tab>`
  (falls back to `zellij run --floating` if the caller's pane id is unknown).
- The pane runs the command in your **current working directory**, `tee`s output
  to a temp file (so the user sees it live and you get it un-truncated), and
  records `$?` to a temp file.
- `zbash` blocks until that exit-code file appears, prints the captured output,
  and exits with the same code.

## Knobs

- `ZBASH_TIMEOUT=<seconds>` — max wait before giving up (default 600).
- `ZBASH_KEEP=1` — leave the pane open after the command exits (default: close).

## When NOT to use it

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
in a floating pane. See `~/.local/share/cc-zellij/bin/`.

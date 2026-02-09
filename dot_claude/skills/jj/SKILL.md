---
name: jj
description: "Jujutsu (jj) version control: megamerge workspace lifecycle, commits, absorb, sync, cleanup. Always jj, never git."
argument-hint: start|finalize|squash|commit|absorb|describe|new|sync|log|drop|land|forget [args...]
allowed-tools: Bash(jj *), Bash(cd *), Bash(ls *), Bash(pwd)
---

# Jujutsu Megamerge Workflow

Use `jj` only — never `git`. Remote ops: `jj git ...`. Route on `$ARGUMENTS`.

## ⚠ Permission Model — READ THIS FIRST

Claude is **terrible at jj graph operations**. Restrict accordingly.

### Claude MAY run directly (no confirmation needed):
- **Read-only:** `jj log`, `jj diff`, `jj show`, `jj evolog`, `jj status`, `jj workspace list`, `jj wip-show`, `jj pending`, `jj mine`, `jj stack`, `jj chain-diff`, `jj wip-tips`
- **Create workspace:** `jj workspace add ...`
- **Add a commit to my branch:** `jj tip-add -m "..."` (single-command, atomic with wip wiring)
- **Wire into wip:** `jj wip-add @` (only right after `workspace add`)
- **Describe:** `jj describe -m "..."`
- **Bookmarks:** `jj bookmark set/delete/...`
- **Push:** `jj git push` (only when user explicitly asks)
- **Navigate:** `cd ...`

### Claude must ASK FIRST — never run without permission:
Before running any of these, Claude must: (1) show the exact command, (2) **predict the expected result** (what the graph/log will look like after), (3) wait for user approval.

- **rebase** (`jj rebase`) — any form, including the `refresh` / `sync` / `reparent` / `linearize` / `wip-detach` aliases. **Exception:** `jj wip-add @` run immediately after `workspace add` is pre-approved (MAY-run) — it only wires the new branch into wip.
- **squash** (`jj squash`, `jj squash-chain`)
- **absorb** (`jj absorb`, `jj absorb-here`)
- **split** (`jj split`)
- **abandon** (`jj abandon`, `jj wip-drop`)
- **edit** (`jj edit`)
- **restore** (`jj restore`)
- **wip-detach / wip-clean**
- **land** (`jj land` / `jj bookmark move main`) — advances trunk, must be paired with `sync` (default) or `reparent`
- **drop / forget** workflows (multi-step)
- **op restore** (`jj op restore`)
- **workspace forget** (`jj workspace forget`)

## Model

```
        wip (megamerge — local only, always empty, query-only — no workspace)
       / | \
  ws-a@  ws-b@  ws-c@     ← workspace WCs, auto-synced via jj snapshots
    |      |      |
  feat-a feat-b feat-c    ← feature commits
       \ | /
        main  ← default workspace (stable, never rebased)
```

Each feature lives in its own workspace. Agents work concurrently.
`wip` is a read-only merge view — inspect with `jj wip-show` from any workspace.
The default workspace stays on `main` and never goes stale.

**Why `wip` exists:** jj has no built-in notion of "the set of feature branches I'm working on." `wip` is a synthetic, empty merge commit whose *parents* are exactly that set — adding a branch = adding a wip parent (`jj tip-add` / `jj wip-add`); landing or dropping = removing one (`jj wip-detach` / `jj wip-drop`). The revsets (`pending()`, `siblings()`, `my_tip()`) read wip's parents to scope each operation to the right branch. `wip` is local-only: never described, pushed, or landed.

## Lifecycle

```
start    → create workspace off main, wire into wip
iterate  → jj tip-add edits; refresh onto main at clean points (+ conflict gate)
finalize → tidy commits/messages IN PLACE (describe/squash/split); does NOT touch main or remove the workspace
land     → merge finished chain to main, rebase idle siblings, remove workspace (the ONLY step that advances trunk)
drop     → abandon the feature instead of landing, then remove workspace
```

## Revsets

| Revset | Meaning |
|--------|---------|
| `chain_base(x)` | Nearest base of branch `x`: wip if `x` descends from wip (workspace started from wip), else main |
| `chain_base()` | `chain_base(@)` |
| `chain(x)` | Commits on branch `x` above its base — never bleeds into sibling branches |
| `pending()` | All in-flight work: wip-tracked branches + untracked mutable above main |
| `my_tip()` | Tip of my branch as tracked by wip; falls back to `@` without wip |
| `my_root()` | First commit of my branch above its base |
| `siblings()` | Other tracked branch tips (wip parents excluding my branch) |

## Aliases

**Inspection**

| Alias | What | Run from |
|-------|------|----------|
| `jj mine` | Log of current branch commits only | workspace |
| `jj stack` | Same with patches — pre-landing review | workspace |
| `jj chain-diff` | Diff from branch base to tip (base = wip or main) | workspace |
| `jj pending` | Log of all pending work | anywhere |
| `jj wip-show` | Full megamerge graph (main + pending) | anywhere |
| `jj wip-tips` | One line per tracked branch tip — compact in-flight view | anywhere |

**Editing**

| Alias | What | Run from |
|-------|------|----------|
| `jj tip-add -m "..."` | New commit at branch tip, wired into wip (atomic) | workspace |
| `jj absorb-here` | Absorb hunks into my branch only — safe under parallel agents | workspace |
| `jj squash-chain -m "..."` | Flatten current chain into one commit — jj asks for a COMBINED description, so pass explicit `-m "<combined msg>"` or it opens an editor and hangs a non-interactive agent | workspace |

**Wip graph**

| Alias | What | Run from |
|-------|------|----------|
| `jj wip-add <rev>` | Wire `<rev>` into wip as a parent (once after `workspace add`) | workspace |
| `jj wip-detach` | Remove my branch from wip without abandoning (for landing) | workspace |
| `jj wip-clean` | Remove redundant parent edges from wip | anywhere |
| `jj wip-drop` | Abandon all commits on this branch | workspace |

**Branch lifecycle**

| Alias | What | Run from |
|-------|------|----------|
| `jj refresh` | Rebase my branch onto current main — may bury first-class conflicts in non-tip commits; run the `chain(@) & conflicts()` gate after every refresh, not only at land | workspace |
| `jj sync` | Rebase all *idle* wip-tracked branches onto current main (skips `working_copies()`) | anywhere |
| `jj land --to <rev>` | Move `main` bookmark to `<rev>` — always pass `--to` explicitly | workspace |
| `jj reparent` | Rebase **every** sibling root onto new main (stales peers; use `sync` when peers may be editing) | workspace |
| `jj linearize <tip>` | Fold a sibling branch onto my tip | workspace |

## Rules

1. **Use `jj tip-add -m "..."` to add commits to your branch.** It atomically creates the commit, replaces the tip→wip edge, and leaves wip correctly wired. Never use bare `jj new --before wip` or `jj commit -m` for branch commits — they do not keep wip in sync.
2. **`wip` is always empty and terminal.** No diff, no direct children from editing. Verify after mutations: `jj log -r wip` shows empty. Run `jj wip-clean` after graph mutations to remove redundant parent edges.
3. **One workspace per feature. Default workspace stays on `main`.** Feature workspaces are siblings off `main` — no ancestor-descendant chains between workspaces. `wip` has no workspace; query from any feature workspace.
4. **Workspaces are ephemeral. Land finished work promptly, then delete the workspace.** A finished feature MUST be merged into `trunk()` (`main`) and its workspace removed — see the **Land** section below. Long-lived workspaces accumulate divergence from a moving `main` and go stale; short-lived ones keep the sibling fan-out small and conflict-free. Don't sit on a completed branch.
5. **Never `jj edit` another workspace's change.** Use `jj new` / `jj tip-add` instead.
6. **Use `jj absorb-here`, not bare `jj absorb`.** Bare absorb can reach into sibling branches and rewrite another agent's commits, making their workspace stale. `absorb-here` scopes to `chain(@)`.
7. **Describe before yielding control.** After edits, run `jj describe -m "..."` so the change is committed. Never leave changes undescribed — `workspace-stale` rebuilds wip from committed parents and can cause divergent change IDs and bookmark conflicts.
8. **Confirm `pwd` before any `@`-relative op.** `tip-add`, `absorb-here`, `refresh`, `squash-chain`, `wip-drop`, `mine`, `stack` all act on the *current* workspace's `@`. Running one from the wrong `cd` edits or abandons the wrong feature — verify `jj status` shows the expected branch first.
9. **Fix divergence immediately.** After rebase/squash/absorb, check for `*` markers. `jj abandon` the stale copy. If `wip` shows `??` (bookmark conflict), resolve with `jj bookmark set wip -r <correct>` then abandon the stale copy.
10. **Never push unless asked.**

## Parallel-agent safety

These rules keep workspaces from going stale when multiple agents work at once:

- **`jj sync` replaces the old unconditional `main-sync`.** It skips branches with an active workspace (`working_copies()` excluded), so landing a feature in workspace A does not rebase the commits under workspace B's `@`.
- **Each workspace refreshes on its own schedule.** When an agent is at a clean yield point, run `jj refresh` to rebase the local branch onto the new main. Busy agents stay on the old main until they choose to refresh.
- **`jj refresh` is only peer-safe on a disjoint branch.** `refresh` (`rebase -b @ -d main`) rewrites the whole connected component above `main` reachable from `@` and, unlike `sync`, does **not** skip `working_copies()`. If you ran `jj linearize` (folding a sibling onto your tip) or added your workspace off a sibling commit (`workspace add -r <sibling>`), a peer's commit may sit inside `main..@`; `refresh` then rebases and stales that peer. In that case use `jj sync` instead, or refresh only after the peer has landed.
- **`jj absorb-here` never touches foreign branches.** Absorb scope is fixed to `(chain(@) ~ @) & mutable()`. Residue at `@` is a signal that the hunk belongs to another branch; do not force-route it across workspaces.
- **Don't run rewriting ops against another workspace's branch.** If you think a change belongs on feat-b, `cd` into feat-b's workspace first, then make the edit there.

## References: always structural, never hashes

Agents should never copy a commit hash from `jj log`. Reach for:

| Reference | Meaning |
|-----------|---------|
| `@` | my working copy |
| `@-`, `@--` | ancestors of `@` (when the leaf is trivially adjacent) |
| `my_tip()` | the tip of my branch as tracked by wip |
| `my_root()` | first commit of my branch above its base |
| `chain(@)` | all commits on my branch above its base |
| `chain_base()` | my branch's base commit (wip if descended from it, else main) |
| `siblings()` | other tracked branch tips |
| `<ws>@` | another workspace's working copy (e.g. `feat-b@`) |
| `main` | the stable LOCAL trunk — what `land` / `refresh` / `sync` / `chain_base` operate on |
| `trunk()` | the remote-tracking trunk (`main@origin`); lags local `main` after a land-without-push — use local `main` for base/land reasoning, not `trunk()` |

## One-time migration (if the default workspace isn't parked on `main`)

Symptom: `jj mine` from the default workspace shows many commits you didn't author, or `jj workspace list` shows `default:` on a commit other than `main`.

```bash
cd <repo-root>   # default workspace
jj edit main     # park default on main — never goes stale again
```

## Start (`/jj start <name>`)

```bash
jj workspace add .workspaces/<name> -r main
cd .workspaces/<name>
jj wip-add @
```

No `-m` at start. No bookmark unless user asks to push.

## Iterate

Every `jj` command snapshots the working copy, so intermediate states are recoverable via `jj evolog`.

| Situation | Command |
|-----------|---------|
| Add a new commit at the branch tip | `jj tip-add -m "type(scope): desc"` |
| Review current change | `jj show --summary` or `jj diff --stat` |
| Review whole branch (compact) | `jj mine` |
| Review whole branch (with patches) | `jj stack` |
| See diff introduced by this branch | `jj chain-diff` |
| See other branches' tips | `jj wip-tips` or `jj log -r 'siblings()'` |
| See other agents' full work | `jj log -r 'pending() ~ chain(@)'` |
| Scoped fixup across my ancestors | `jj absorb-here` |
| After any `jj refresh` (rebasing onto moved main) | `jj log -r 'chain(@) & conflicts()'` — must be EMPTY; if not, `jj resolve` the conflicted commit(s) before continuing |
| Undo last edit | `jj evolog -r @` → note the change_id + snapshot index → `jj restore --from <change_id>/<n>` (the `@/<n>` shorthand does NOT parse) |

## Finalize (`/jj finalize`)

From the feature workspace:

| Situation | Command |
|-----------|---------|
| Self-contained in `@` | `jj describe -m "type(scope): desc"` |
| Fold into parent | `jj squash` (then describe parent if needed) |
| Multiple logical units | `jj split -- 'paths...'` then describe each. **Never use `jj split -i`** — it requires interactive input. Always pass explicit file paths. |

After finalize, do NOT forget the workspace or abandon the change. Finalize never advances `main` or deletes the workspace — that is `/jj land`.

## Drop (`/jj drop <name>`)

Abandon a feature and remove it from wip. Run from inside the workspace:

> Every step below is an ASK-FIRST op (see Permission Model): show the command, predict the result, get approval. Do NOT paste the whole block as one batch.

```bash
cd .workspaces/<name>
jj wip-drop                    # abandons all commits on my branch; wip auto-reparents
cd <repo-root>
jj workspace forget <name>
rm -rf .workspaces/<name>
jj wip-clean                   # remove any now-redundant main parent edge
```

## Land (`/jj land <name>`)

Land a feature onto main. **Order matters:** refresh first, **verify no conflicts**,
then move the `main` bookmark, then rebase siblings, then detach.

> Every step below is an ASK-FIRST op (see Permission Model): show the command, predict the result, get approval. Do NOT paste the whole block as one batch.

```bash
cd .workspaces/<name>
jj squash-chain -m "type(scope): combined desc"  # optional: flatten to one commit; MUST pass -m, else jj prompts for a combined description and hangs
jj refresh                          # rebase my branch onto current main (wip follows)
jj log -r 'chain(@) & conflicts()'  # GATE: must be EMPTY before landing — see below
jj land --to my_tip()               # advance main to my branch tip (unambiguous structural ref)
                                    #   (or `jj land --to <change-id>` for a specific commit)
                                    #   land only moves main FORWARD; after `jj refresh` the tip is a
                                    #   descendant of main. Never pass `-B`/`--allow-backwards`. Under
                                    #   concurrent landings, re-run refresh + the conflict gate first.
jj sync                             # rebase idle sibling chains onto new main (skips active peer working copies)
                                    #   — use `jj reparent` ONLY if certain no peer workspace is live
jj wip-detach                       # remove my branch from wip
cd <repo-root>
jj workspace forget <name>
rm -rf .workspaces/<name>
jj wip-clean                        # drop redundant parent edges (incl. stale old-main → wip)
```

### Mergeability gate (MUST pass before deleting the workspace)

jj **never refuses a rebase or merge on conflict** — it always succeeds and records
conflicts as first-class state inside the affected commits. There is no non-mutating
"merge preview": `jj refresh` *is* the rebase onto the current `main`, and inspecting
the result afterwards is the idiom (it's reversible via `jj op log` / `jj op restore`).

So "verify the chain is mergeable on top of `main` without conflicts" means:

1. `jj refresh` — rebase the whole chain onto the current `main`.
2. `jj log -r 'chain(@) & conflicts()'` — this revset MUST be **empty**.
   - Scope it to `chain(@)`. The bare `jj conflicts` alias (`log -r conflicts()`) reports
     conflicts from *every* branch and will mislead. Don't use `jj resolve --list` either —
     it only inspects `@`'s working copy and misses conflicts in non-tip commits of a
     multi-commit chain.

**If `chain(@) & conflicts()` is non-empty: do NOT land and do NOT delete the workspace.**
Deleting a workspace whose chain conflicts on `main` is exactly the failure this gate
prevents. Remediate first:
- `jj resolve` each conflicted commit (or `jj new --insert-after <conflicted> && jj resolve && jj squash`), then re-run the gate; **or**
- keep the workspace alive and hand back, if the conflict needs the author's judgement.

Only once the gate is empty do you advance `main` and remove the workspace.

**When to pick `sync` vs `reparent`:**
- `sync` (default) — rebases only chains with no `working_copies()`; safe while peers edit. Each busy peer then runs `jj refresh` on its own schedule.
- `reparent` — ONLY when no peer workspace is live. Rewrites every pending root, including peer-checked-out ones, staling them.

## Forget (`/jj forget <name>`)

Only when user explicitly asks (does NOT remove from wip):

```bash
cd <repo-root>
jj workspace forget <name>
rm -rf .workspaces/<name>
```

## Linearize (fold a sibling into mine)

Rebase a sibling branch onto the tip of my branch.

> Both steps below are ASK-FIRST ops (see Permission Model): show the command, predict the result, get approval before running.

```bash
jj linearize feat-b@   # rebase feat-b's branch onto my_tip()
jj wip-clean           # remove now-redundant parent edge
```

`linearize` uses `my_tip()` as the destination, so it works regardless of where `@` is in the current branch.

## Snapshots & Evolution Log

Every `jj` command auto-snapshots the working copy before executing. Every intermediate state of your code is recorded — even without explicit commits.

- **View evolution:** `jj evolog -r <rev> -p` shows every snapshot of a change, with diffs between them.
- **Recover any state:** `jj restore --from <change_id>/<n>` restores the working copy to a previous snapshot (`<n>` is the snapshot index from `jj evolog`). The operand separator is a slash — `<change_id>@<n>` and `@/<n>` both fail to parse.
- **Review what changed:** `jj show --summary` shows the current change's affected files. `jj show -r <rev>` for any revision.
- **Diff between snapshots:** `jj interdiff --from <change_id>/<m> --to <change_id>/<n>`.

Use `jj evolog` as an undo: if an edit or refactor goes wrong, find the last good snapshot and restore — no need for `jj op restore` unless the graph itself is broken.

## Recovery

- **Divergence** (`*`): `jj abandon <stale-copy>`. Use `jj log -r "change_id(xxx)"` to list all copies, keep the one with the right parents.
- **Bookmark conflict** (`??`): `jj bookmark set <name> -r <correct-commit>` then `jj abandon <stale-commit>`. Common after `workspace-stale` runs while edits are uncommitted.
- **Stale workspace** (jj errors `The working copy is stale` / `working-copy commit was rewritten`): a peer rebased or abandoned the commit your `@` sat on. From inside the workspace, run `jj workspace update-stale` to reattach `@` to the rewritten commit, then `jj status` to confirm your edits survived (they are snapshotted, so they do). If edits were lost in the rebase, recover via `jj evolog -r <change_id> -p` + `jj restore --from <change_id>/<n>`.
- **Conflicts**: `jj new --insert-after <conflicted> && jj resolve && jj squash`
- **Nuclear**: `jj op restore <op-id>` (rewinds entire repo to previous state)
- **Lost work**: `jj evolog -r <change_id> -p` to find the snapshot, `jj restore --from <change_id>/<n>` to recover

## Commit Messages

Format: `type(scope): description`
Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `ci`

For command details, see [references/commands.md](references/commands.md).
For remote push setup, see [references/remotes.md](references/remotes.md).

$ARGUMENTS

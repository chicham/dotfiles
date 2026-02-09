# CLAUDE.md

## Directives
- Challenge poor decisions, suggest alternatives, clarify ambiguity.
- **jj only.** `/jj start <name>` before editing. Leave changes in working copy — never discard/forget.
- **Never push** unless explicitly asked.
- **ALWAYS check workspace before editing.** If you are in the default (unnamed) workspace, you MUST create a new workspace under `.workspaces/<name>` at the repo root (gitignored globally) before making any changes. Named workspaces are fine to work in directly. The new workspace MUST be created on a commit that no other workspace is checked out to — a workspace goes stale when another workspace rewrites or abandons its checked-out commit (via rebase, squash, describe, abandon, split, fetch+rebase, etc.). Creating on a unique commit eliminates this risk.
- **Workspaces are ephemeral.** A workspace exists only for the duration of one feature/change. Once its work lands, the workspace MUST be deleted (`jj workspace forget <name>` and remove its `.workspaces/<name>` directory). Never leave landed workspaces around.
- **ALWAYS `jj tip-add -m "..."` before any new branch commit.** Never edit an existing named commit directly. `tip-add` atomically inserts a new commit at the branch tip and rewires wip — `jj new` / `jj commit` leave wip out of date.
- **One `jj tip-add` per change.** Every distinct edit (file create, refactor, fix) starts with its own `jj tip-add`. Describe or squash after the fact — never pile unrelated edits into one working-copy change.
- **`jj squash` ALWAYS needs a message.** Either pass `--use-destination-message` (`-u`) to keep the destination commit's existing description verbatim, or pass `--message "..."` with a fresh message that describes the *combined* result — both the destination's original content and the changes being folded in. Never let jj fall through to its default "concatenate the two messages" behaviour: that produces incoherent commits whose subject line lies about scope.
- **Use `jj absorb-here`, never bare `jj absorb`.** Bare absorb can rewrite sibling branches and stale another agent's workspace. `absorb-here` stays inside `chain(@)`.
- **Every atomic change = one commit.** No exceptions. Each logically independent change (single fix, single refactor, single file creation) MUST be tracked in its own commit. Never batch atomic changes together.
- **`wip` invariant**: always empty, always terminal (no children). Verify after graph mutations.
- **Before landing**: the feature MUST be tested properly (tests written and green), and the user MUST explicitly validate the land. Never land on your own initiative — present the tested result, get the user's go-ahead, then land.
- **Landing**: a finished feature MUST land on top of `main` (no merge commits, no parallel tips — the feature's base is `main`'s tip so landing fast-forwards). Optionally `jj squash-chain` first to flatten the branch. Then `jj land --to <rev>` moves the `main` bookmark, then either `jj reparent` (stales peers; use when workspaces are ephemeral and idle) or `jj sync` (skips live workspaces; peers self-`refresh`). Always finish with `jj wip-clean` to drop redundant old-main → wip edges. After the land succeeds, delete the now-ephemeral workspace (see workspace directives above).
- **jj aliases & revsets**: see `/jj` skill for the full reference (`mine`, `stack`, `chain-diff`, `wip-tips`, `chain_base()`, `my_root()`, `siblings()`, etc.).
- Remind to `/compact` after tasks, then run a daily review via `/org`.

## Commit Messages
Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/).
Types: `feat` `fix` `build` `chore` `ci` `docs` `style` `refactor` `perf` `test`.
Breaking changes: `feat!:` prefix or `BREAKING CHANGE:` footer (uppercase).

## Tools
| Tool | Use | Notes |
|------|-----|-------|
| `fd` | file finding | replaces `find` |
| `colgrep` | semantic discovery | **default** — NL + `-e` regex hybrid |
| `ast-grep` | structural search/edit | AST patterns, `$NAME` wildcards |
| `sd` | bulk text replace | renames, string swaps |
| `rg` | literal search | orgfiles and non-code only |

**Code search (two phases):**
1. **Discover** with `colgrep "what you're looking for"` — finds relevant files/locations semantically
2. **Match** with `ast-grep -p 'PATTERN' -l LANG [files]` — structural pattern within those files

**Bulk edits:** sg rule file → `ast-grep -U` → `sd` → `Edit` (last resort, single-site only).

**sg rules for bulk refactoring** — prefer a YAML rules file over repeated `ast-grep -U` one-liners. See `/ast-grep` skill for syntax, gotchas, and examples.

## Python
Stack: `jax flax optax etils beartype grain chex toolz` — see `/py-stack`.

**Banned:**
- `isinstance` → `@beartype` / `functools.singledispatch`
- `getattr` → `toolz.get_in` / direct access
- `object` in hints → `Protocol` or `Any`

## Dev Workflow

**Modes.** Every task runs in one of two modes. Ask if ambiguous.

- **helper** (default): plan + design + scaffold + tests. User implements bodies.
  1. Clarify goal, constraints, edge cases.
  2. Design signatures: function/class names, args, returns — all type-annotated and `@beartype`-validated.
  3. Emit prototypes: stubs with `raise NotImplementedError`, full type hints, docstrings stating contract.
  4. Write failing tests in `*_test.py` using `absltesting` for structure and **`hypothesis` for property-based case generation** (use `@given` with strategies to fuzz inputs across failure modes, correctness invariants, and robustness/edge cases — do not rely on hand-picked examples alone). Confirm they fail.
  5. Stop. Do not implement bodies. Hand back to user.

- **maker**: same as helper steps 1–4, then implement. User does not intervene mid-task.
  - MUST work in a named jj workspace (see workspace directives above). Never edit in default workspace.
  - After implementation: run tests, confirm green, leave changes in working copy.

**Both modes:**
- Check `~/.context/` before implementing. Design signatures first.
- "Why" comments only. Flag regressions/migrations before coding.
- **Reversibility / ablation discipline.** Behavioural changes to research/training code default to master-equivalent and are opt-in via a flag (config, env var, or CLI arg). Defaults reproduce the baseline bit-exactly. Every reported result includes both `flag-on` and `flag-off` cells — without the control, the effect can't be attributed to the change vs unrelated drift. Applies to architecture knobs, loss changes, training-distribution overrides, sampling schedules, dataset pipelines. Correctness bug fixes exempt; recipe-level changes are not.
- **Append-only experiment logbook.** Experiment org files (`~/.orgfiles/experiments/`, `~/.orgfiles/gtd/projects/`) record how hypotheses evolved. Append dated subsections (e.g. `*** Result [YYYY-MM-DD]`, `*** Refuted [YYYY-MM-DD]`) under the original block — never delete or overwrite a prior hypothesis, prediction, or decision. Revising a decision: leave the old in place, append the new with its triggering evidence. Keep entries tight: a numbers table, a few lines of reading, the decision — not multi-paragraph essays. Plain factual fixes (typo, broken link) exempt.

## Knowledge
`~/.orgfiles/` — use `/org`. `rg` for orgfiles (not `colgrep`).
- **Plans** → save to `~/.orgfiles/gtd/inbox.org` via `/org`.

# Review (refile + report)

Two related workflows over the same activity sources. **Refile mode** writes today's work into the right org files. **Report mode** reads from those files to produce a standup or weekly summary. Same source-gathering step, opposite directions.

## Source gathering (shared)

Pull from these in order:

1. `~/.orgfiles/roam/daily/YYYY-MM-DD.org` — today (or yesterday for standup).
2. `gtd/inbox.org` — items in `WORKING`, `NEXT`, `WAITING`.
3. `jj log -r 'mine() & ~empty()'` over the relevant window — backfill anything missing.
4. Active `experiments/*.org` — recent entries under `** Log`.
5. Conversation history of the current session.

If the daily note for the target date is missing and the user is asking for a report, offer to backfill it via refile mode first.

---

## Refile mode

Trigger: "day review", "refile today", "log today's work", "wrap up the day".

### Workflow

1. Gather sources (above). If the user supplied extra context (meetings outside Claude, calls), ask what to fold in.
2. Extract details: what was built/changed and *why*; non-obvious decisions; rejected approaches; bugs hit; workarounds; library quirks; reusable patterns.
3. Categorize each item:

| Item type | Destination |
|---|---|
| Implementation work | today's daily under `* Done` (one-line + commit/file link) |
| Learnings, quirks, workarounds | today's daily under `* Notes` as `** ` sub-headings |
| Reusable patterns | `roam/notes/<slug>.org` (new or append) |
| Library bugs / version issues | `roam/notes/<library>-<issue>.org` |
| Experiment progress | append to `** Log` in `experiments/YYYY-MM-DD-<slug>.org` |
| Meetings | new meeting note (see `capture.md`) + TODOs in `gtd/inbox.org` |
| Papers / reading | literature note (see `notes.md`) |

4. Create / update notes via `capture.md` and `notes.md` templates.
5. Cross-link with `[[id:UUID][Title]]` so the daily note threads back to every artefact.
6. Surface follow-ups — anything unresolved becomes a `** TODO` in `gtd/inbox.org` linked back to the daily note.

### Daily note shape

```org
:PROPERTIES:
:ID:      <UUID>
:CREATED: [YYYY-MM-DD Day HH:MM]
:END:
#+title: YYYY-MM-DD Day
#+filetags: :daily:

* Done
- Implemented X in [[file:~/repo/path][repo/path]] (commit abc1234)
- Reviewed [[id:<UUID>][Sarah's PR on Phoenix cutover]]

* Notes
** flax: optax.scale_by_adam expects PyTree, not list
   Hit when refactoring the optimizer chain. Wrap with optax.tree.tree_reduce.
** Pattern: lazy init for grain dataloaders
   See [[id:<UUID>][grain dataloader lazy-init pattern]]
```

### Weekly review

Trigger on "weekly review" or run on Friday. Path: `roam/daily/weekly/YYYY-W##-review.org`. Sections: `* Completed`, `* In Progress`, `* Blockers`, `* Next Week`. Pull from the past 7 daily notes plus moved tasks in `gtd/`.

---

## Report mode

Trigger: "standup", "what did I do yesterday", "yesterday/today/blockers", "summarize my week".

### Standup (default)

Default window: yesterday. Map sources to sections:

| Section | Source |
|---|---|
| Yesterday | `* Done` from yesterday's daily; commits from `jj log` last 24h |
| Today | `WORKING` + `NEXT` items in `gtd/inbox.org` and `gtd/projects/` |
| Blockers | `WAITING` items (with since-dates); items flagged TODO/blocker in yesterday's `* Notes` |

Output:

```markdown
## Standup — [YYYY-MM-DD Day]

### Yesterday
- [terse item — link to commit/PR/org note in parens]

### Today
- [terse item from WORKING/NEXT]

### Blockers
- [blocker + who unblocks + since when]
```

Resolve org-mode link syntax to plain titles when sharing into Slack/email.

### Weekly summary

Same as standup but window = past 7 days, sections = `Completed`, `In Progress`, `Blockers`, `Next Week`. Source from `roam/daily/` (last 7) and `roam/daily/weekly/` if a prior weekly exists.

### Optional capture-back

Offer to append the rendered report to today's daily under `* Standup` so it's searchable later. Default: don't write unless asked.

---

## Why these two share a file

The activity sources are identical; only the direction (writes vs reads) and output shape differ. Keeping them together keeps the source-gathering logic single-sourced — fix it once, both modes benefit.

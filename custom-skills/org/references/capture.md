# Capture

Create new entries in `~/.orgfiles/`. Always emit `:ID:` (uuidgen) + `:CREATED: [YYYY-MM-DD Day HH:MM]`.

## Type → Location

| Type | Path | Key sections |
|------|------|-------------|
| task | `gtd/inbox.org` (append `* Tasks`) | `** TODO %title` + properties |
| note | `roam/notes/note-<TS>.org` | `#+title:`, `* Notes` |
| meeting | `roam/notes/meeting-<TS>.org` | `#+title:`, `#+date:`, `* Attendees`, `* Agenda`, `* Notes` |
| literature | `roam/literature/<TS>-<Slug>.org` | see `literature.md` |
| experiment | `experiments/YYYY-MM-DD-<slug>.org` | `* TODO %title :experiment:`, properties (PROJECT/STARTED), sections: Question, Hypothesis, Background, Materials, Variables, Procedure, Log, Data, Results, Conclusions, Next Steps |
| daily | `roam/daily/YYYY-MM-DD.org` | `* Done`, `* Notes` |
| weekly | `roam/daily/weekly/YYYY-W##-review.org` | `* Completed`, `* In Progress`, `* Blockers`, `* Next Week` |
| reading | `gtd/inbox.org` (append `* Reading List`) | `** TODO %title :reading:` + link |
| person | `roam/people/<Slug>.org` | properties (ROLE/TOPIC/STARTED), `* Current Focus`, `* Milestones`, `* Results`, `* Meetings`, `* Notes` |
| quick | `roam/daily/YYYY-MM-DD.org` (append `* Notes`) | `** %title` + body |

`<TS>` = `YYYYMMDDHHMMSS`. Literature slugs use underscores; everything else uses hyphens.

## Rules

- **Meetings**: notes contain discussion only. Action items become separate TODOs in `gtd/inbox.org` linked back via `[[id:UUID][Meeting Title]]`.
- **Ask before guessing** missing essentials: attendees/date for meetings, author/title for literature, hypothesis for experiments.
- **Cross-link** with `[[id:UUID][Title]]`, bidirectional when both notes are about the same thing.
- **Search before creating**: `rg <query> ~/.orgfiles/` to avoid duplicates. Update existing notes when a match is clear.
- **Property drawers** must be either file-top (org-roam style) or attached directly under a heading. No floating drawers mid-body.
- **TODO states**: see SKILL.md invariants.

## Default behaviour

`/org-capture`-style invocations without a type → use **quick** (drop a `**` heading under today's daily `* Notes`).

## Example: meeting capture

```org
:PROPERTIES:
:ID:        <UUID>
:CREATED:   [2026-05-04 Mon 14:32]
:END:
#+title: Sync with Sarah on Phoenix migration
#+date: [2026-05-04 Mon]
#+filetags: :meeting:phoenix:

* Attendees
- Hicham
- Sarah Chen

* Agenda
- Migration cutover plan
- Rollback rehearsal

* Notes
- Sarah will own the cutover script; rehearsal scheduled for Friday.
- Open question: who runs the rollback drill?
```

Then in `gtd/inbox.org`:

```org
** TODO Confirm rollback drill owner :phoenix:
   :PROPERTIES:
   :ID: <UUID>
   :CREATED: [2026-05-04 Mon 14:35]
   :END:
   From [[id:<meeting-UUID>][Sync with Sarah on Phoenix migration]]
```

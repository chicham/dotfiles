# Multi-file projects

Layout, update workflow, and append-only invariants for projects whose
documentation outgrows a single file. Trigger on "split this project file",
"how do I update the project notes", "add a finding to the project",
"update execution status", or any project under `~/.orgfiles/gtd/projects/`
that has its own subdirectory.

## When to split

Keep the project as a single `gtd/projects/<name>.org` file by default.
Split into `gtd/projects/<name>/<file>.org` when the file passes ~800 lines
AND answers more than two distinct questions for distinct readers (a
collaborator wants the claim + status; future-you debugging wants
phenomena + failure mechanisms; the paper draft wants positioning +
limitations). Below 800 lines or single-purpose, splitting just adds friction.

## Standard layout

```
~/.orgfiles/gtd/projects/<name>/
├── README.org              # project node (keeps the original :ID:); claim, index, deadlines
├── claim.org               # context, hard constraints, hypothesis, scope
├── predictions.org         # pre-registered predictions, experiment designs
├── phenomena.org           # durable findings (run-summary table + interpretation per finding)
├── failure-mechanisms.org  # active diagnostic deep-dives
├── status.org              # active flags table, execution status, phased plan
├── positioning.org         # related-work comparison, limitations, risks
└── tasks.org               # GTD-style task list
```

Drop files you don't need — there's no requirement to materialise all of
these. A young project may only need `README.org` + `phenomena.org` +
`tasks.org`. Add files as the project accretes mass.

## Cross-linking

Every file has its own `:ID:` (one `uuidgen` each). The README keeps the
project's *original* ID — that's the node external notes already link to,
and breaking it invalidates inbound `[[id:UUID][...]]` references across
`roam/` and `experiments/`.

Within the project, link siblings via `[[id:UUID][file-purpose]]`. The
README has an *index table* with one row per sibling file pointing at it
by ID.

External chronological evidence (per-run logbook, daily notes) stays where
it lives — link to it from `phenomena.org` or `claim.org`, don't copy.

## File frontmatter

Each file:

```org
:PROPERTIES:
:ID:       <uuid>
:CREATED:  [YYYY-MM-DD Day]
:END:
#+title: <Project Name> — <file purpose>
#+filetags: :project:<project-slug>:<scope-tag>:
#+options: toc:nil num:nil
```

The README's `#+title` is just the project name (no suffix); siblings get
`— <purpose>` so org-roam pickers disambiguate.

## Update workflow

| Event | Where it lands | Append-only? |
|---|---|---|
| New training run / experiment trial | Logbook (chronological, outside the project dir) + one row in `phenomena.org`'s run-summary table | Yes (logbook entries) |
| Durable finding (confirmed/refuted hypothesis, mechanism insight) | New `** <phenomenon>` subsection in `phenomena.org` | Yes (`*** Result [date]` subsections) |
| New failure mechanism (training pathology) | New `** <mechanism>` subsection in `failure-mechanisms.org` | Yes |
| New / changed config flag | Row in `status.org` §"Active flags" table | Update status field; preserve history in a `*** [date] Update` subsection if material |
| Decision change / constraint override | Append `*Constraint override [YYYY-MM-DD].*` block in `claim.org` | Yes — never overwrite the original constraint |
| Task lifecycle | `tasks.org` (TODO → NEXT → WORKING → DONE) — append `*** Result [date]` with outcome | Yes (task body + dated result) |
| Execution-cell status change (run started/finished) | Update icon (`✓` / `▶` / `◌` / `⊘`) in `status.org` execution-status tables | Operational rows mutate in place; dated history blocks (bug-fix log, flag-change log) remain append-only |

Engineering pitfalls and library quirks belong in
`roam/notes/<TS>-<topic>.org`, not in any project file. The project file
links to the engineering note by ID.

## Append-only logbook policy

Every dated section is append-only. Revisions add a new
`*** Result [YYYY-MM-DD]` or `*** Refuted [YYYY-MM-DD]` subsection under
the original block. Never delete or overwrite a prior hypothesis,
prediction, or decision.

Reason: experiment hindsight is always crisper than experiment foresight;
preserving the original framing lets future-you (and reviewers) reconstruct
what was load-bearing at decision time. Plain factual fixes (typo, broken
link, dead URL update) are exempt.

If a result is invalidated, write `*** INVALIDATED [YYYY-MM-DD]` with the
falsifying evidence; keep the original `*** Result` block intact above it.

## Run-summary table conventions

In `phenomena.org`, maintain a *single* canonical metrics table near the
top of the file:

- One row per training run; columns: ts_job/run id, config, key
  hyperparameters that vary across rows, step count, headline metrics.
- Each `config` cell is a link to the corresponding logbook entry:
  `[[file:../path/to/logbook.org::*<heading>][config-name]]`.
- In-flight rows marked `▶`; current headline row bold. Trailing footnote
  defines symbols.
- When a column becomes mostly empty (e.g. a metric stops being emitted),
  drop it — don't pad rows with `—` past usefulness.

## Migrating an existing single-file project

1. Backup: `cp gtd/projects/<name>.org /tmp/<name>-backup-$(date +%s).org`.
2. `mkdir gtd/projects/<name>/`.
3. Allocate one new UUID per sibling file (`uuidgen`); keep the original
   project file's `:ID:` for the new `README.org`.
4. Move sections out of the single file into siblings, preserving heading
   structure. Cross-references that pointed inside the file (`[[* Heading]]`)
   become `[[id:UUID][...]]` to the new sibling.
5. Replace the original `gtd/projects/<name>.org` with a 5-line stub: title
   + a single `[[id:<README-UUID>][See <name>/README]]` link, so any path-
   based references degrade gracefully.
6. Search inbound references: `rg '<name>\.org' ~/.orgfiles/` and update
   any `file:` links to point at the directory README. ID-based links
   continue to work without edits.

## Anti-info-loss check

After a split or major restructure: count significant items (ts_jobs,
result tables, REFUTED/CONFIRMED labels, dated subsections) in the backup
vs. the new layout. Any unaccounted item is either lost or duplicated;
both are bugs.

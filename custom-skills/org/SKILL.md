---
name: org
description: Centralized org-mode and org-roam workflow over ~/.orgfiles/. Use whenever the user wants to capture, read, search, or refile notes (tasks, meetings, experiments, literature, daily logs, people, glossary terms); run a daily or weekly review; prep a standup; synthesize research from multiple sources; read an arXiv paper; manage the GTD inbox; or anything mentioning org-mode, org-roam, ~/.orgfiles, gtd/inbox.org, roam/daily, roam/literature, or experiments. Trigger even when the user does not explicitly say "org" — phrases like "remind me to", "capture this", "log today's work", "what did I do yesterday", "summarize these interviews", "save this paper", "what does PSR mean", or "add to my reading list" all map here. This skill owns every read and write under ~/.orgfiles/.
user-invocable: false
---

# Org

Single entry point for everything that touches `~/.orgfiles/`. Routes to one focused reference per workflow so only the relevant playbook gets loaded.

## Knowledge base layout

```
~/.orgfiles/
├── gtd/
│   ├── inbox.org          # tasks, reading list (capture lands here first)
│   ├── projects/          # active projects (refiled from inbox)
│   ├── reading.org        # promoted reading items
│   └── archive.org
├── roam/
│   ├── daily/YYYY-MM-DD.org      # daily log + weekly under daily/weekly/
│   ├── notes/                    # general notes, patterns, library quirks
│   ├── literature/<TS>-<Slug>.org # papers, articles
│   ├── people/<Slug>.org         # people profiles
│   ├── quick-reference.org       # glossary / acronyms / nicknames / codenames
│   └── workflow.org
├── experiments/YYYY-MM-DD-<slug>.org  # experiment logs
├── research/                          # synthesized research outputs
└── libraries/                         # per-library notes (jax, flax, …)
```

## Invariants (apply to every operation)

- Every entry needs `:ID:` (from `uuidgen`) and `:CREATED: [YYYY-MM-DD Day HH:MM]`.
- **Search before creating.** `rg <query> ~/.orgfiles/` to avoid duplicates. Update existing notes when a clear match exists.
- **Cross-link** related notes with `[[id:UUID][Title]]` (bidirectional when natural).
- **TODO state machine**: `TODO` → `WORKING` → `NEXT` → `WAITING` → `SOMEDAY` → `DONE` / `CANCELLED`.
- **Glossary lookup first.** Before acting on shorthand (acronyms, nicknames, project codenames), consult `roam/quick-reference.org` and `roam/people/`. If unknown, ask and then save to glossary. See `references/glossary.md`.
- **Pandoc-clean syntax.** Anything that may be exported follows `references/pandoc.md`.
- **Use `rg`, not colgrep**, for orgfiles — they are prose, not code.
- **Ask before guessing** when meeting attendees/date, paper author/title, or experiment hypothesis is missing.

## Routing — pick the reference for the task

| User intent | Reference |
|---|---|
| Capture a task / meeting / quick note / reading item / person profile | `references/capture.md` |
| Turn source(s) into a structured note — single paper deep-dive **or** multi-source synthesis | `references/notes.md` |
| Refile today's work into daily/notes/experiments **or** produce a standup / weekly summary | `references/review.md` |
| GTD lifecycle: triage inbox, promote to projects, weekly review | `references/tasks.md` |
| Multi-file project layout under `gtd/projects/<name>/`: split, update, append-only invariants | `references/projects.md` |
| Decode shorthand (acronym, nickname, codename) or save a new term | `references/glossary.md` |
| Anything that will be exported via pandoc | `references/pandoc.md` |

When a request spans multiple workflows (e.g. "review my day and prep tomorrow's standup"), load both references.

## Helpers

- `scripts/new_id.sh` — prints `UUID\nTIMESTAMP` for use in property drawers.

## Why this skill exists

Org notes are most useful when they accrete consistently — same property drawers, same TODO states, same cross-link conventions, same paths. Every prior org-touching skill (capture, day-review, read-arxiv-paper, standup, the two research-synthesis skills) lived independently and drifted. Centralizing them here keeps the conventions in one place. The references intentionally fuse workflows that share their core logic: `notes.md` covers both single-source (literature) and multi-source (synthesis) extraction because the extract→structure→cross-link→save pipeline is identical, only the output schema differs. `review.md` covers both refile (writes) and standup/weekly (reads) because the activity-gathering step is the same — fixing it once benefits both directions.

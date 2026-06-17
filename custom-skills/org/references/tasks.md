# Tasks (GTD)

Lifecycle for tasks living in `~/.orgfiles/gtd/`. Trigger on "what's on my plate", "add a task", "remind me to", "what am I waiting on", "triage inbox", or weekly review.

## State machine

```
TODO → WORKING → NEXT → WAITING → SOMEDAY → DONE / CANCELLED
```

| State | Meaning |
|---|---|
| `TODO` | Captured, not yet triaged |
| `WORKING` | Actively in progress |
| `NEXT` | Triaged, queued as the next concrete action on a project |
| `WAITING` | Blocked on someone/something (always note **who** and **since when**) |
| `SOMEDAY` | Deferred, no commitment to do soon |
| `DONE` / `CANCELLED` | Terminal |

## Files

- `gtd/inbox.org` — capture + triage queue. Everything new lands here.
- `gtd/projects/*.org` — one file per active project. Tasks promoted from inbox live here, organised under project headings.
- `gtd/reading.org` — promoted reading items (after triage from inbox `* Reading List`).
- `gtd/archive.org` — completed items older than ~1 month.

## Capture (new task)

Always under `* Tasks` in `gtd/inbox.org`:

```org
** TODO Title :tag:
   :PROPERTIES:
   :ID: <UUID>
   :CREATED: [YYYY-MM-DD Day HH:MM]
   :END:
   Optional context, due date, link back to source meeting/note.
```

## Triage (inbox → projects)

Trigger when user says "triage inbox" or during weekly review. For each `TODO` in `gtd/inbox.org`:

1. **Is it a real next action?** If vague ("think about X"), reframe as a concrete action ("draft 1-pager for X").
2. **Does it belong to an existing project?** If yes, move to `gtd/projects/<project>.org` under the right heading and bump state to `NEXT`.
3. **Is it 2-minute work?** Suggest just doing it.
4. **Waiting on someone?** Move to `WAITING` and add `:WAITING_ON:` property + since-date.
5. **Not now?** `SOMEDAY`.

## Status queries

| User asks | Action |
|---|---|
| "what's on my plate" | List `WORKING` + `NEXT` from `gtd/`, flag overdue |
| "what am I waiting on" | List `WAITING` from `gtd/`, with since-dates |
| "what's in my inbox" | List `TODO` items in `gtd/inbox.org` (untriaged) |
| "what did I finish this week" | List `DONE` items closed in the last 7 days |

## Completing a task

Change state to `DONE`, append `CLOSED: [YYYY-MM-DD Day HH:MM]`. Keep in place for at least a week so weekly review can reflect on it; archive to `gtd/archive.org` after.

## Extracting from meetings/conversations

When summarizing a meeting or chat, offer (don't auto-add) extracted tasks: commitments the user made, action items assigned to them, follow-ups mentioned. Each extracted task gets `[[id:UUID][source meeting]]` as link-back.

# Glossary

Decode workplace shorthand — acronyms, nicknames, project codenames, internal terms — before acting on a request that uses them. Lookup-first; ask-then-save when unknown.

## Storage

| Type | Path |
|---|---|
| Acronyms, terms, nicknames, codenames | `~/.orgfiles/roam/quick-reference.org` (single file, table-organised) |
| Person profiles | `~/.orgfiles/roam/people/<Slug>.org` (one file per person) |
| Project deep-context | `~/.orgfiles/gtd/projects/<project>.org` |

`quick-reference.org` is the hot cache — kept lean and lookup-friendly.

## Lookup flow

```
User says "ask todd about the PSR for phoenix"

1. rg "todd|PSR|phoenix" ~/.orgfiles/roam/quick-reference.org
   → todd? Todd Martinez (Finance lead) ✓
   → PSR? Pipeline Status Report ✓
   → phoenix? Project Phoenix (DB migration) ✓

2. If something missing → grep roam/people/, gtd/projects/
3. If still missing → ask the user, then save (see "Adding terms" below)
```

Always do step 1 silently before answering — never act on shorthand you couldn't decode.

## quick-reference.org shape

```org
:PROPERTIES:
:ID:      <UUID>
:CREATED: [YYYY-MM-DD Day HH:MM]
:END:
#+title: Quick Reference
#+filetags: :glossary:

* Acronyms
| Term | Meaning              | Context                    |
|------+----------------------+----------------------------|
| PSR  | Pipeline Status Rep. | Weekly sales doc           |
| OKR  | Objectives & KRs     | Quarterly planning         |
| P0   | Drop everything      | Severity                   |

* Internal terms
| Term         | Meaning                                       |
|--------------+-----------------------------------------------|
| standup      | Daily 9am sync                                |
| the migration| Project Phoenix DB work                       |
| ship it      | Deploy to production                          |

* Nicknames → people
| Nickname | Person                                        |
|----------+-----------------------------------------------|
| Todd     | [[id:<UUID>][Todd Martinez (Finance)]]        |
| T        | also Todd Martinez                            |

* Project codenames
| Codename | Project                                      |
|----------+----------------------------------------------|
| Phoenix  | [[id:<UUID>][DB migration to PostgreSQL]]    |
| Horizon  | [[id:<UUID>][Mobile app redesign]]           |
```

Cross-link nicknames/codenames to the deep file (`roam/people/` or `gtd/projects/`) so a lookup can drill down.

## Adding terms

When the user introduces a new term, or you ask and they answer:

1. Add a row to the appropriate table in `quick-reference.org`.
2. If it's a person → also create/update `roam/people/<slug>.org` with full profile (role, communication style, context, notes).
3. If it's a project → also create/update `gtd/projects/<project>.org`.
4. Capture **all** aliases at once — nicknames, abbreviations, codenames. The cost of missing one is failed decoding next time.

Phrasing: "I don't know what `<term>` means yet — what does it stand for? I'll save it." Then confirm the save.

## Stale terms

When the user mentions something is over (project completed, person no longer relevant), don't delete — annotate with `[archived YYYY-MM-DD]` in the row's context column. Lookup still works for old notes that reference the term.

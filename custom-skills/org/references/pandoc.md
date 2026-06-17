# Pandoc-clean org syntax

Notes that may be exported (literature, meetings, experiments, synthesised research) must round-trip through `pandoc -f org` (https://pandoc.org/org.html) to Markdown / LaTeX / HTML without loss. These rules are the canonical reference — every other reference file defers here.

## Directives

- **Lowercase**: `#+title:`, `#+author:`, `#+date:`, `#+filetags:`, `#+options:`. Pandoc accepts either case but lowercase is canonical.
- **Export metadata**: include `#+title:`, `#+author:`, `#+date:` on anything that may be exported. Pandoc reads these directives, not custom property-drawer keys (`:AUTHOR:`, `:YEAR:` are org-roam-only).

## Property drawers

Either file-top (before any heading, org-roam style) or attached immediately under a heading. **No floating drawers mid-body.** Pandoc preserves file-top drawers as metadata only when paired with the directives above.

## Code blocks

```
#+name: snippet-name
#+caption: Optional caption
#+begin_src LANG
…
#+end_src
```

`#+name:` enables cross-references; `#+caption:` exports cleanly.

## Figures and tables

Precede with `#+caption:` and `#+name:` for cross-refs:

```
#+caption: Loss curves for v1 vs v2.
#+name: fig:loss
[[file:./loss.png]]
```

## Links

| Use case | Form |
|---|---|
| Web | `[[https://…][text]]` |
| Cross-file (export-safe) | `[[file:PATH][Title]]` |
| In-Emacs navigation only | `[[id:UUID][Title]]` |

Pandoc does **not** resolve `id:` across files. For notes meant to be exported, duplicate the target as a `file:` link alongside the `id:` form.

## Math

`\(inline\)`, `\[display\]`, `$inline$`, `$$display$$` — all supported.

## Footnotes

```
Body text with a footnote.[fn:1]

[fn:1] Footnote body, at the bottom of the file.
```

## Tags

`#+filetags: :a:b:` and headline `:tag:` suffix both export cleanly.

## TODO + priority

`** TODO [#A] Title` exports correctly with the keyword and priority preserved.

## Avoid in exported notes

Pandoc drops or mishandles these:

- `:LOGBOOK:` drawers
- Radio targets `<<<…>>>`
- `#+CALL:` / babel evaluation
- `#+MACRO:`
- `#+INCLUDE:` with search options

Use them only in notes that are strictly Emacs-internal.

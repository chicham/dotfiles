# Notes (single-source & multi-source)

Turn source material into a structured org note. Same workflow at the core — extract → structure → cross-link → save — with two output shapes depending on how many sources you have.

| Scope | Trigger | Output path | Template |
|---|---|---|---|
| **Single source** (paper, article, book, long doc) | arXiv URL/ID, DOI, "read this paper", "save this paper", "take notes on" | `~/.orgfiles/roam/literature/<TS>-<Slug>.org` | Literature template (below) |
| **Multi-source** (interviews, surveys, support tickets, prior notes, mixed) | "synthesize", "themes from", "patterns in", "what are users saying about" | `~/.orgfiles/research/<YYYY-MM-DD>-<slug>.org` | Synthesis template (below) |

Meetings and quick notes go through `capture.md`, not here.

---

## Shared workflow

1. **Search first.** `rg <keywords-or-id> ~/.orgfiles/roam/literature/ ~/.orgfiles/research/`. If a matching note exists, ask whether to update or skip.
2. **Acquire** the material:
   - arXiv → fetch LaTeX source from `https://www.arxiv.org/src/{id}` (note `/src/`, not the PDF) into `~/.cache/arxiv/{id}.tar.gz`, unpack, find `main.tex` (or the file with `\documentclass`), recurse through `\input` / `\include`.
   - Other URLs → fetch HTML/PDF directly.
   - Pasted text or attached files → use as-is.
3. **Extract** — see "Single-source extraction" or "Multi-source extraction" below.
4. **Structure** into the right template.
5. **Cross-link** with `[[id:UUID][Title]]` to related existing notes (`rg :ID: ~/.orgfiles/`). Bidirectional when natural.
6. **Save** with `:ID:` (uuidgen) + `:CREATED:`. Pandoc-clean syntax — see `pandoc.md`.
7. **Trail back** — append a one-liner to today's `roam/daily/YYYY-MM-DD.org` under `* Notes`: `** Read [[id:<UUID>][<title>]]` (literature) or `** Synthesised [[id:<UUID>][<title>]]` (synthesis).

---

## Single-source extraction

For a paper or long doc, focus on **reproducibility**:

- Hypothesis / claim — what do the authors say is new?
- Methods — enough detail to re-run.
- Results — actual numbers, tables, equations. Don't paraphrase numerics.
- Evidence — what supports each claim.
- Implementation details — hyperparameters, hardware, training time, code links.
- Critical evaluation — strengths and limitations, honestly. This is mandatory.

### Literature template

```org
:PROPERTIES:
:ID:        <UUID>
:CREATED:   [YYYY-MM-DD Day HH:MM]
:URL:       https://arxiv.org/abs/{arxiv_id}
:DATE_READ: [YYYY-MM-DD Day]
:AUTHOR:    <comma-separated authors>
:JOURNAL:   arXiv (<venue if published, else preprint>)
:YEAR:      <year>
:DOI:       10.48550/arXiv.{arxiv_id}
:KEYWORDS:  <comma-separated lowercase keywords>
:END:
#+title: <Paper Title>
#+author: <comma-separated authors>
#+date: [YYYY-MM-DD Day]
#+filetags: :reading:research:
#+options: toc:nil num:nil

* Hypothesis/Claim
* Methods
* Results
* Evidence
* Summary of Key Points
# Quote exact wording when paraphrase risks distortion.
* Context & Relationships
# Cross-link to existing notes.
* Important Figures/Tables
* Implementation Details
* References to Follow Up
* Critical Evaluation
# Contribution clearly identified? Method appropriate? Results match claim?
# Evidence sufficient? Flaws / strengths?
```

Slug for path: paper title in `Underscore_Case`. `<TS>` = `YYYYMMDDHHMMSS`.

---

## Multi-source extraction

For a pile of inputs (interviews, surveys, support tickets, mixed feedback, prior org notes):

### Step 1 — Frame

Ask: type of research? how many sources? specific question/hypothesis? what decision will this inform?

### Step 2 — Process each source

Per source, extract: observations, verbatim quotes, behaviors (what they did vs said), pain points, positive signals, context (segment, use case). One observation per atomic unit — easier to recluster.

### Step 3 — Thematic analysis

1. **Familiarize** — read everything before coding.
2. **Initial coding** — generous, descriptive tags. Easier to merge than split.
3. **Theme development** — group codes into themes that answer the research question.
4. **Theme review** — does each theme have enough evidence? distinct? coherent?
5. **Refine and name** with a one-sentence description.

Alternatives: **affinity mapping** (one obs per note → cluster → label), **triangulation** (same finding across method/source/time strengthens it).

### Step 4 — Deduplicate

Same author + adjacent time + similar content → likely duplicate; merge and cite both. **Don't** merge when participants disagree, viewpoints diverge, or the topic evolved meaningfully — those splits are signal. When versions conflict: most complete > most authoritative > most recent.

### Step 5 — Score

| Axis | Question |
|---|---|
| Frequency | How many sources support it? |
| Impact | How much does it affect users / the business? |
| Confidence | High (multiple sources, behavioral) / Medium / Low |
| Evidence type | Behavioral > stated preference |

### Synthesis template

```org
:PROPERTIES:
:ID:      <UUID>
:CREATED: [YYYY-MM-DD Day HH:MM]
:END:
#+title: Research Synthesis: <Study Name>
#+date: [YYYY-MM-DD Day]
#+filetags: :research:synthesis:

* Overview
- Method: <interviews / survey / mixed>
- Participants / sources: <N>
- Timeframe: <range>
- Research question: <…>
- Decision this informs: <…>

* Executive Summary
3-4 sentences on the key findings.

* Key Themes
** Theme 1: <Name>
   - Prevalence: X of Y participants
   - Confidence: High / Medium / Low
   - Summary: <…>
   - Evidence:
     - "<quote>" — P<N> ([[id:<UUID>][source]])
   - Implication: <…>

* Insights → Opportunities
| Insight | Opportunity | Impact | Effort |
|---------|-------------|--------|--------|

* User Segments
| Segment | Characteristics | Needs | Size |

* Recommendations
1. *High* — <action>. Why: <findings>.
2. *Medium* — <action>. Why: <…>.

* Open Questions
- <what we still don't know>

* Methodology Notes
<how research was run, limitations, biases>

* Sources
- [[id:<UUID>][Source 1]] — <type, date>
```

---

## Principles (apply to both shapes)

- **Quotes are evidence, not findings** — the finding is the interpretation.
- **Attribute by participant type, not name** unless the research is about a named individual.
- **Behavior > stated preference.** When they conflict, lead with behavior and flag the gap.
- **Quantify** — "7 of 10" beats "most".
- **Be explicit about confidence.** A finding from 2 interviews is a hypothesis.
- **Contradictions are signal** — don't smooth them over.
- **Resist over-synthesis.** 5–8 strong findings beat 20 weak ones.
- **Recommendations must be actionable.** "Improve onboarding" is not. "Add a progress indicator to the setup flow" is.

## Lightweight asks

For a quick "top 3 themes" or "summarize this paper in 3 bullets", reply inline and ask before writing the full org artefact. Default: write only when the user wants a durable note.

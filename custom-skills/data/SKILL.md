---
name: data
description: Profile and analyze ML datasets and training metrics. Use whenever the user wants to inspect a HuggingFace dataset (load_dataset, splits, label balance, token-length distributions, sample inspection, dedup, contamination checks); read or compare TensorBoard event files (loss curves, eval metrics, learning-rate schedules, gradient norms, NaN/divergence detection, run-vs-run comparison); or apply statistical methods to either (distributions, percentiles, outliers, hypothesis tests, trend / seasonality, correlation). Trigger on "profile this dataset", "what's in this HF dataset", "compare these runs", "why did the loss spike", "is run A better than run B", "look at the eval metrics", "check for label imbalance", "find duplicates in this corpus", "is this difference significant", "plot the LR schedule". Owns dataset profiling and metric analysis end-to-end.
user-invocable: false
---

# Data

Two analysis surfaces — HuggingFace-style datasets and TensorBoard-style training metrics — sharing one statistical-methods reference. Load only the reference(s) the task needs.

## Routing

| Task | Reference |
|---|---|
| Inspect / profile a dataset (HF `load_dataset`, parquet, jsonl, arrow, webdataset) — splits, columns, label balance, token-length distributions, dedup, contamination, sample inspection | `references/hf-datasets.md` |
| Read TensorBoard event files, plot or compare loss / eval / LR / grad-norm curves, detect NaN / spikes / divergence, compare runs across seeds or configs | `references/tensorboard.md` |
| Apply a statistical method to either (distributions, percentiles, outlier detection, trend / seasonality, hypothesis test, correlation) | `references/stats.md` |

Typical chain: profile a dataset before training → during training, watch tensorboard → after training, compare runs and apply stats to determine whether the change actually helped.

## Boundary with `artitrack`

`artitrack` is the lifecycle tool — submit, query, fetch logs/event files, manage pipelines on obelix via the `at` CLI. **`data` is the analysis layer on top.** Once you have an event file or a dataset locally, `data` covers the reasoning.

If the user asks "is job 12345 done", that's `artitrack`. If they ask "did the loss converge faster than the baseline run", that's `data` (after `artitrack` fetches the events).

## Universal principles

1. **Validate before presenting.** Row counts, null rates, magnitude sanity, time-series continuity, aggregation logic. If something looks off, dig before showing.
2. **Lead with the finding, support with numbers.** Numbers are evidence; the finding is the interpretation.
3. **Quantify uncertainty.** Ranges over point estimates. Multiple seeds → mean ± std. "Run B is 0.3 ± 0.1 BLEU above baseline" beats "Run B is 0.3 BLEU above baseline".
4. **Statistical significance ≠ practical significance.** A reliably reproducible 0.1% accuracy bump rarely matters. Report effect size alongside any test.
5. **Correlation is not causation.** Especially for ablation studies — confounding hyperparameters are common. Flag explicitly when interpretation could mislead.
6. **Report what you excluded.** "Dropped runs 7 and 12 — diverged at step 5k" is a finding, not a footnote. Silent filtering loses signal.
7. **Compare against the baseline, every time.** Per CLAUDE.md ablation discipline: every reported result should include both `flag-on` and `flag-off` cells. Without the control, the effect can't be attributed to the change vs unrelated drift.
8. **Single-seed results are anecdotes.** Multi-seed (≥3) before claiming a real effect, especially for small deltas.

## Logging the work

When the analysis produces a real conclusion, capture it via the `org` skill:

- Dataset profile worth keeping → `roam/notes/<dataset>-profile.org`
- Run comparison conclusion → append to the relevant `experiments/YYYY-MM-DD-<slug>.org` under `** Log` or `** Results`
- Surprising finding → today's daily under `* Notes`

Don't write to org for one-shot lookups; do for anything you'll want to recall later.

## Tools

| Need | Default |
|---|---|
| Dataset loading | `datasets` (HF), `polars` (parquet/csv), `pyarrow` |
| TB event reading | `tbparse` (preferred — pandas-native) or `tensorboardX` |
| Plotting | `matplotlib` for static, `plotly` for interactive comparisons |
| Stats | `scipy.stats`, `numpy` |
| Tokenization | `transformers.AutoTokenizer` |

Keep dependencies light — avoid pulling in heavy frameworks for a quick profile.

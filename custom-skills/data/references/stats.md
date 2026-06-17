# Statistical methods

Reference for the methods called from `hf-datasets.md` and `tensorboard.md`. Lean toward simple, defensible methods; escalate to more sophisticated stats only when justified.

## Describing a distribution

Always report multiple statistics — single numbers lie.

| Use | When |
|---|---|
| **Mean** | Symmetric, bounded data without long tails |
| **Median** | Skewed data (token lengths, latencies, training-step times) — robust to outliers |
| **Mean + median together** | Default for ML metrics. The gap reveals skew. |
| **Mode** | Categorical / discrete (label distributions) |

Spread:

- **Std** — fine for roughly normal data.
- **IQR (p75 − p25)** — robust to outliers; default for skewed data.
- **CV (std / mean)** — comparing variability across metrics with different scales.

Percentiles to report by default: p1, p5, p25, p50, p75, p95, p99. For latency / token-length / loss-spike analysis, p99 and p99.9 carry most of the signal.

Shape: normal / right-skewed / left-skewed / bimodal / heavy-tailed / power-law. Eyeball a histogram first; statistical tests for normality are usually unnecessary.

## Outlier and anomaly detection

### Static (non-time-series)

- **IQR rule** — outlier if `< Q1 − 1.5·IQR` or `> Q3 + 1.5·IQR`. Default for skewed data.
- **Z-score** — `|z| > 3`. Only for roughly normal data — useless for token lengths.
- **Percentile cutoffs** — e.g. drop top/bottom 1%. Simple and transparent.

### Time series (training metrics)

- Compute expected value (rolling mean or same-step-prior-run).
- Flag deviations beyond `k · std(residuals)`, k ∈ [2, 4].
- Distinguish **point anomalies** (single bad step — usually a bad batch) from **change points** (sustained shift — usually optimizer / data / schedule change).

### Handling outliers

Never auto-drop. Always:

1. Investigate — bug, genuine extreme, or different population?
2. Bug → fix.
3. Genuine extreme → keep, switch to robust stats (median, IQR).
4. Different population → segment out and analyze separately.
5. Report what you did: "Dropped 47 rows (0.3%) with token length > 16k — likely scraping artefacts".

## Trend and seasonality

For time-series metrics (loss curves, throughput over time, wall-time per step):

### Smoothing

- **Rolling mean** — simple, transparent. Window = 5–20% of the series length.
- **EMA** — `value_ema[t] = α · value_ema[t-1] + (1-α) · value[t]`. TensorBoard's default α ≈ 0.6–0.9. Lighter smoothing reveals more structure.
- Always show raw alongside smoothed.

### Period-over-period

For longer-running training or batched experiment series:

- Step-over-step (small Δ for plateau detection).
- Hour-over-hour (cluster utilisation, throughput).
- Run-over-run (absolute deltas between configurations).

### Change-point detection

Visual inspection is fine for most cases. When you need to be programmatic, `ruptures` library:

```python
import ruptures as rpt
algo = rpt.Pelt(model="rbf").fit(values)
changepoints = algo.predict(pen=10)
```

But: a clear change-point in a single run is usually obvious from the plot. Use detection for batches of runs you can't eyeball.

## Hypothesis testing — when comparing runs

Use sparingly. The bar: "is the difference between condition A and condition B real, or could it be seed noise?"

### The framework

1. **H0** — no difference between conditions.
2. **H1** — A and B differ.
3. **α = 0.05** by default. For exploratory ablations, treat p-values as soft signal; for headline claims, demand more.
4. Test → p-value → interpret.

### Common tests

| Scenario | Test | Notes |
|---|---|---|
| A vs B, ≥3 seeds each, paired (same eval, same data) | **Paired t-test** on per-seed final metrics | Default for ablation comparisons |
| A vs B, ≥3 seeds, unpaired | **Welch's t-test** | When seeds aren't matched |
| A vs B, very few samples or non-normal | **Mann-Whitney U** | Doesn't assume normality |
| Three+ conditions | **One-way ANOVA**, then pairwise with correction | Bonferroni / Holm if you do many comparisons |
| Two binary outcomes (A converged / didn't) | **Fisher's exact** | Tiny samples |

```python
from scipy import stats
# Paired comparison on per-seed final eval loss
t, p = stats.ttest_rel(loss_A, loss_B)
```

### What to report

- **Effect size** — `mean(A) - mean(B)` with a confidence interval. Without effect size, p-value is meaningless.
- **The CI**, not the p-value alone. A 95% CI of `[-0.1, +0.4]` BLEU is "we can't tell".
- **n per condition** — small-n p-values are unstable; say so.
- **Whether the test was prespecified** or chosen after looking at the data (the latter inflates false positives).

### Practical vs statistical significance

A reliably reproducible 0.1% accuracy bump isn't worth a paragraph. Always frame the result in terms of whether the effect matters for the downstream goal.

## Correlation

Between numeric series (e.g. correlating gradient norm with loss spikes, or token length with eval accuracy):

- `scipy.stats.pearsonr` — linear correlation. Sensitive to outliers.
- `scipy.stats.spearmanr` — rank correlation. Robust, catches monotonic non-linear.
- Flag |r| > 0.7 for investigation; 0.3–0.7 is "interesting", < 0.3 is usually noise at typical sample sizes.
- **Correlation is not causation.** Especially for ablations where multiple things changed at once.

## Cautions to apply by default

- **Multiple comparisons** — testing 20 metrics at p=0.05 means ~1 will be falsely significant. If you ran many tests before finding one that's significant, say so.
- **Simpson's paradox** — overall trend can reverse per-segment. Check per-domain / per-task before concluding.
- **Survivorship bias** — analysing only runs that finished ignores the ones that diverged. The diverged ones are often the most informative.
- **Anchoring on false precision** — "Run B is 0.347% better" implies more precision than warranted. Round to the noise floor.
- **Single-seed deltas are noise.** If you have one seed per condition, you have a hypothesis, not a result.

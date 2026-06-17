# TensorBoard metric analysis

Read TensorBoard event files, plot and compare training/eval curves, spot training pathologies, decide whether a change actually helped. Use after `artitrack` (or local training) has produced event files.

## Loading event files

`tbparse` is the preferred reader — pandas-native, handles nested run dirs:

```python
from tbparse import SummaryReader

# Single run
df = SummaryReader("path/to/run", pivot=True).scalars

# Multiple runs (one row per (run, step, tag))
df = SummaryReader("path/to/runs_root", extra_columns={"dir_name"}).scalars
```

Schema: `step`, `tag`, `value`, plus `dir_name` for multi-run. Pivot if you want one column per tag.

For very large event files, set `extra_columns={"wall_time"}` only when you actually need wall-time analysis (it doubles memory).

## What to plot

### Loss curves (the first thing every time)

- **Train + eval loss on the same axis** — divergence between them is the single most informative signal.
- **Log-y by default** — loss spans orders of magnitude in the first hundred steps; linear-y hides early dynamics.
- **Smoothed and raw** — smoothed shows trend, raw shows noise/spikes. EMA with α≈0.9 is a reasonable default; never *only* show smoothed.

### Learning rate schedule

- Plot it. Scheduler bugs are common (off-by-one warmup, decay computed from wrong base, schedule frozen by a checkpoint resume).
- Cross-check that scheduled LR matches what's actually being applied (some optimizers report effective LR after weight decay).

### Gradient norms

- Pre-clip and post-clip if both logged. The gap shows how often clipping fires.
- Sustained grad norm trending up = instability brewing. Spikes followed by NaN = exploding gradients.

### Eval metrics

- Plot every eval metric, not just the headline one. The headline can move because of the wrong reason (e.g. accuracy up but only on the majority class).
- Multi-task / multi-domain eval: per-domain *and* macro-average. Aggregate hides regression in any one slice.

### Per-layer / per-parameter (when needed)

- Histograms of weights, gradients, activations per layer. Useful when debugging dead neurons, vanishing/exploding signal, init issues.
- Cost a lot of disk; only enable when you suspect something specific.

## Pathologies to actively look for

| Pattern | What it usually means |
|---|---|
| **Loss is exactly NaN at some step** | Bad input (e.g. empty sequence, all-zero attention mask), divide-by-zero in custom loss, mixed-precision overflow, bad init |
| **Loss spikes then recovers** | LR too high for a transient, optimizer state misaligned after resume, batch with extreme outliers |
| **Loss spikes then diverges** | Same causes, but gradient clipping wasn't enough or wasn't applied |
| **Train ↓ but eval ↑ early** | Overfitting on a small dataset, or eval split contamination flipped (eval is now harder than train) |
| **Train and eval both flat** | Dead model — bad init, frozen weights, LR too small, data pipeline returning constant batch |
| **Loss decreases stepwise** (plateau → drop → plateau) | Often LR schedule transitions; verify against the LR plot |
| **Eval metric oscillates wildly** | Eval batch too small, non-deterministic eval (dropout on, augmentations active), or stochastic decoding |
| **Grad norm sustained high** | Underfitting + high LR; consider lower LR or more steps |
| **Grad norm sustained near zero** | Vanishing gradients, frozen layers, or near-converged — disambiguate with eval metrics |
| **Wall-time per step trending up** | Memory leak, growing dataset shard, increasing seq length per batch (for packed/dynamic batching) |

## Comparing runs

The whole point of multi-run analysis. Patterns:

### Single-axis comparison (one variable changed)

Plot all runs on the same axes. Overlay rather than facet — facet hides crossing curves.

```python
import matplotlib.pyplot as plt
for name, sub in df.groupby("dir_name"):
    sub = sub[sub.tag == "eval/loss"].sort_values("step")
    plt.plot(sub.step, sub.value, label=name)
plt.yscale("log"); plt.legend(); plt.xlabel("step")
```

### Multi-seed (the only honest comparison)

Single-seed deltas are noise. With ≥3 seeds per condition:

- Plot mean ± std band per condition.
- Report the final-step metric as `mean ± std`, not bare mean.
- For "is A better than B", run a paired test on per-seed final metrics (see `stats.md`).
- If only one seed exists, say so — and report the result as preliminary.

### Aligning runs

Runs may have different step counts, log frequencies, or wall-clock budgets:

- **Compare at matched compute, not matched step.** A run with 2× batch size at the same step has used 2× compute. Either match step *and* batch, or match total tokens / total wall-time.
- **Drop incomplete runs** before averaging — partial runs pull means in misleading directions.

### Best-checkpoint vs last-checkpoint

If the task uses early stopping or best-checkpoint selection, compare the *selected* checkpoint, not the last step. Compare both if you're unsure which the downstream pipeline uses.

## Output

A run-comparison report should include:

1. **One sentence** stating the conclusion (A better than B / no difference / mixed).
2. **The plot** — overlay, log-y, smoothed + raw, multi-seed band if available.
3. **Final-step table** — `mean ± std` per condition, per metric.
4. **Significance** — paired test on per-seed finals, with effect size (`stats.md`).
5. **Caveats** — single seed, run aborted, hyperparameters not perfectly matched, eval set difference.
6. **Decision** — keep / revert / needs more seeds / needs different ablation.

Worth-keeping conclusions go to the relevant `experiments/YYYY-MM-DD-<slug>.org` under `** Results` via the `org` skill — never let a real ablation result live only in chat.

## When to escalate beyond plotting

- A pathology shows up but the cause is unclear → use the `debug` skill with the event file as evidence.
- Loss looks fine but downstream eval is broken → the metric you're tracking isn't the metric that matters; revisit eval design.
- Comparison shows a real effect but the mechanism is unclear → run a targeted ablation, not more analysis on the same runs.

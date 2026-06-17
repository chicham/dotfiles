# HuggingFace dataset profiling

Profile and inspect ML training/eval datasets — HF `datasets`, parquet, jsonl, arrow, webdataset. Goal: know what's in a corpus before training on it.

## Loading

```python
from datasets import load_dataset

# Public HF hub
ds = load_dataset("squad", split="train")

# Local parquet / arrow / json
ds = load_dataset("parquet", data_files="path/*.parquet", split="train")
ds = load_dataset("json", data_files="path/*.jsonl", split="train")

# Streaming (large corpora — never load full)
ds = load_dataset("c4", "en", split="train", streaming=True)
```

For large corpora always start with `streaming=True` and `.take(N)` for inspection — full loads can exhaust disk/RAM silently.

## What to profile

### Structural

- `len(ds)`, `ds.column_names`, `ds.features`
- Splits available (`load_dataset(name)` without split returns DatasetDict)
- Per-split row counts and any size imbalance
- File-level: parquet row groups, shard count, total bytes on disk
- Schema drift across shards (if any) — flag before assuming uniform structure

### Per-column

| Column type | Profile |
|---|---|
| **Label / class** | Class balance (`Counter(ds["label"])`), missing classes, long-tail vs uniform, class names from `features["label"].names` |
| **Text** | Token length distribution (with the *actual* tokenizer used downstream, not just whitespace); char length; language detection if mixed-corpus; empty / whitespace-only count |
| **Numeric** | min/max/mean/median/std, percentiles (p1/p25/p50/p75/p99), zero count, negative count if unexpected |
| **ID / hash** | Uniqueness ratio (`len(set(ids)) / len(ids)`); duplicate keys |
| **Image / audio / binary** | Sample dimensions, file sizes, format mix, decode-error count on a sample |
| **Nested / dict** | Recurse — flatten with `ds.flatten()` for tabular profiling |

### Token-length distribution (critical for training)

```python
from transformers import AutoTokenizer
tok = AutoTokenizer.from_pretrained("<your-model>")
lengths = [len(tok(x, add_special_tokens=False).input_ids) for x in ds.shuffle().select(range(10_000))["text"]]
```

Report: p50, p95, p99, max, fraction over your context length. The fraction over context determines truncation rate — surprises here become silent training-time data loss.

## Quality flags

Apply these on every dataset; loud-fail when any trip:

- **Duplicate rows** — exact match on the primary text field. >5% is usually wrong.
- **Near-duplicates** — n-gram or MinHash LSH overlap (see "Dedup" below). Important for eval contamination.
- **Contamination** — overlap between train and eval. n-gram intersection on (train, eval) pairs; report the overlap rate.
- **Label leakage** — feature columns that perfectly predict the label (e.g. label embedded in URL). Sample a few rows manually if a feature has suspiciously high mutual information with the label.
- **Encoding issues** — mojibake (`â€™`, `\xc3\xa9`), control chars, BOM, mixed line endings.
- **Truncation already in source** — strings ending mid-word with `...` or just cut. Often happens in scraped data.
- **Empty or whitespace-only** rows — common in jsonl exports.
- **Suspicious uniform values** — if a numeric column has 90% zeros, ask whether it's a real signal or a default.

## Dedup (when needed)

Exact:

```python
import hashlib
def h(s): return hashlib.md5(s.encode()).hexdigest()
seen = set(); keep = []
for row in ds:
    k = h(row["text"])
    if k not in seen:
        seen.add(k); keep.append(row)
```

Near-dup (large corpora) — MinHash LSH via `datasketch`:

```python
from datasketch import MinHash, MinHashLSH
lsh = MinHashLSH(threshold=0.8, num_perm=128)
# ... build MinHash per doc on shingled tokens, query LSH for clusters
```

For GenIR / retrieval datasets specifically: dedup on the *query* side AND check query-document leakage between train and eval splits.

## Sample inspection (do this first, every time)

Before computing anything, just look at 10 random rows:

```python
for row in ds.shuffle(seed=0).select(range(10)):
    print(row)
    print("---")
```

Five minutes of eyeballing catches things no automated profile will: weird formatting conventions, label noise, unexpected language mix, prompt-template artefacts, off-by-one in field names.

## Output

A profile report should answer, in this order:

1. **Shape** — splits, row counts, columns and types.
2. **Sample** — 3-5 representative rows verbatim.
3. **Per-column distributions** — table with the relevant stats from above.
4. **Token-length distribution** — histogram or percentile table; truncation rate.
5. **Quality flags** — what tripped, what didn't, severity.
6. **Recommendations** — what to filter, what to investigate, what's safe to train on as-is.

For datasets you'll reuse, save the profile to `~/.orgfiles/roam/notes/<dataset>-profile.org` via the `org` skill.

## When to escalate beyond profiling

- The dataset doesn't match the task you think it does → re-read the dataset card / paper.
- Eval split has contamination with train → fix the split before any training run.
- Token-length p99 way above your context window → truncation will dominate; rethink chunking.
- Label imbalance > 10:1 → at minimum resampling or class weighting; report it.

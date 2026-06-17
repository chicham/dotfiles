# Artitrack CLI Reference

All commands run on obelix via SSH: `ssh obelix 'at <command>'`

Data directory on obelix: `~/.at` (override: `-d` flag or `ARTITRACK_DATA_DIR` env var)

## Global Options

| Flag | Description |
|------|-------------|
| `-d, --data-dir PATH` | Override data directory (default: `~/.at` or `$ARTITRACK_DATA_DIR`) |
| `-v, --verbose` | Debug logging to stderr |
| `--json-logs` | Structured JSON output (for CI) |
| `--version` | Version info |

---

## Querying Runs & Jobs

### `at runs` -- List pipeline runs

```bash
ssh obelix 'at runs'                          # All recent runs
ssh obelix 'at runs --failed'                 # Only failed
ssh obelix 'at runs -s running'               # By status
ssh obelix 'at runs -e probe'                 # By experiment name (substring)
ssh obelix 'at runs -n 20'                    # Limit results
ssh obelix 'at runs -c lr,batch_size'         # Show config columns
ssh obelix 'at runs --input "data/train.csv"' # By input artifact (lineage)
ssh obelix 'at runs --output "models/*.pt"'   # By output artifact
ssh obelix 'at runs --order-by finished --asc' # Sort ascending
ssh obelix 'at runs --format fzf'             # Tab-delimited for piping
```

Options: `-s/--status` (pending|running|completed|failed|killed|cancelled), `--failed`, `-e/--experiment`, `-n/--limit`, `-c/--config-keys`, `--input`, `--output`, `--order-by` (created|updated|started|finished|id), `--desc/--asc`, `--filter`, `--format` (plain|fzf)

### `at run <run-id>` -- Run details

Full details for a run -- jobs, artifacts, status. Accepts run ID or `last`.

```bash
ssh obelix 'at run <run-id>'
ssh obelix 'at run last'
```

### `at last` -- Most recent run

Shorthand for `at run last`.

### `at status` -- Active runs dashboard

Shows RUNNING and PENDING runs with job counts.

### `at job <ts-job-id>` -- Job details

Details for a specific job by task-spooler integer ID. Shows command, status, timing, artifacts, metrics.

```bash
ssh obelix 'at job 123'
```

### `at jobs` -- List job executions

```bash
ssh obelix 'at jobs'                 # All recent
ssh obelix 'at jobs -s running'      # By status
ssh obelix 'at jobs -n 50'           # Limit
```

Options: `-s/--status` (queued|running|finished|failed|skipped), `-n/--limit`, `--format`

### `at log <ts-job-id>` -- Job output/logs

```bash
ssh obelix 'at log 123'             # Full output
ssh obelix 'at log 123 --path'      # Print log file path only
ssh obelix 'at log 123 -n 40'       # Last 40 lines
```

Use `--path` to get the file path for further operations (grep, tail -f):

```bash
ssh obelix "grep 'train/loss' \$(at log 123 --path) | tail -20"
ssh obelix "grep 'eval/hit_at_1' \$(at log 123 --path) | tail -20"
ssh obelix "grep 'system/memory_used_gb' \$(at log 123 --path) | tail -10"
```

### `at metrics` -- Metrics artifacts

```bash
ssh obelix 'at metrics'                        # All metrics
ssh obelix 'at metrics -e dsi/t5_small'        # By experiment
ssh obelix 'at metrics -s completed'           # Only completed runs
ssh obelix 'at metrics -r <run-id>'            # Single run
```

Options: `-r/--run`, `-e/--experiment`, `-s/--status`, `-n/--limit`, `--format`

### `at tensorboard` -- Read scalar metrics from TB event files

Resolves a run/experiment selection to its TensorBoard logdir(s) (via the
Metrics artifacts `at metrics` lists) and reads the event files directly.
Selection is run-centric (runs, not q job ids). Two modes; tags are always
user-specified (no default tag set). Requires the `tensorboard` extra on the
host (`uv sync --extra tensorboard`; obelix has it).

```bash
# List available scalar tags (discovery)
ssh obelix 'at tensorboard -e dsi/t5_small --tags'         # across an experiment's runs
ssh obelix 'at tensorboard -r run_abc --tags'              # a specific run

# Extract per-step values for one or more tags
ssh obelix 'at tensorboard -r run_abc -t train/loss -t eval/ir/nn/mrr_at_10'  # step×tag table
ssh obelix 'at tensorboard -r run_abc -t train/loss --steps 1000'             # first 1000 steps
ssh obelix 'at tensorboard -r run_abc -r run_def -t train/loss --format csv'  # compare runs
ssh obelix 'at tensorboard -e dsi -t train/loss --steps 1000 --format csv' > loss.csv  # plotting
```

Modes: `--tags` (flag) lists tags; `-t/--tag NAME` (repeatable or comma-list)
extracts — multiple tags allowed. Exactly one of the two is required. `--steps N`
keeps the first N recorded steps. `--format table|csv|tsv` (CSV/TSV are
wide-pivoted: `step` + one column per tag, with a leading `run` column when
multiple runs are selected).

Selection: `-r/--run` (repeatable or comma-list, for multiple runs),
`-e/--experiment`, `-s/--status`, `-n/--limit`.

### `at info` -- Database statistics

Entity counts, types, general DB health.

---

## Advanced Query

### `at query` -- Low-level MLMD query

```bash
# Entity types: run, execution, artifact
ssh obelix 'at query --entity run'                            # List all
ssh obelix 'at query --entity run <run-id>'                   # By ID
ssh obelix 'at query --entity execution 123'                  # By ts_job_id
ssh obelix 'at query --entity run --status failed'
ssh obelix 'at query --entity run --name "ml_training*"'      # Wildcard
ssh obelix 'at query --entity run --input "data/train.csv"'   # By input artifact
ssh obelix 'at query --entity run --output "models/*.pt"'     # By output artifact
ssh obelix 'at query --entity run --order-by created --desc'
ssh obelix "at query --entity artifact --filter 'type = \"Model\"'"
```

All options: `--entity` (required), `--status`, `--name`, `--input`, `--output`, `--filter`, `--order-by` (created|updated|started|finished|id), `--desc/--asc`, `-n/--limit`, `--format`

---

## Management Commands

### `at sync` -- Sync from task-spooler

Syncs job statuses from task-spooler into MLMD. Normally automatic via monitor, but useful if the monitor daemon died.

### `at cancel <run-id>...` -- Cancel runs

Kills all running/queued jobs in the specified runs.

```bash
ssh obelix 'at cancel run1 run2 run3'
```

### `at delete` -- Remove runs

Permanently removes runs and metadata. **Always check per-job status before bulk deleting** -- a "failed" run may have partially succeeded jobs with useful artifacts.

```bash
ssh obelix 'at delete <run-id>'                             # Delete specific
ssh obelix 'at delete run1 run2'                            # Multiple
ssh obelix 'at delete -e ml_training'                       # All runs for experiment
ssh obelix 'at delete -e ml_training --failed'              # Only failed
ssh obelix 'at delete <run-id> --dry-run'                   # Preview
ssh obelix 'at delete <run-id> --metadata-only'             # Keep artifact files
ssh obelix 'at delete <run-id> --force'                     # Skip confirmation
ssh obelix 'at delete <run-id> --force-shared'              # Delete shared artifacts (dangerous)
```

Safety: INPUT artifacts never deleted. Shared OUTPUTs preserved by default.

### `at submit` -- Ad-hoc job submission

Submit a command with MLMD tracking without a full xmanager launch file.

```bash
ssh obelix 'at submit -n train -- python train.py --lr 0.001'
ssh obelix 'at submit -n eval -e my_experiment --gpu 1 -- python eval.py'
```

Options: `-n/--name` (required), `-e/--experiment`, `--gpu` (default: 0), `--allow-dirty`

### `at snapshot <run-id>` -- Reproducibility snapshots

Git worktree snapshots.

```bash
ssh obelix 'at snapshot <run-id>'                # Create
ssh obelix 'at snapshot <run-id> --force'        # Recreate
ssh obelix 'at snapshot <run-id> --path'         # Print path only
```

### `at update run <run-id>` -- Modify run metadata

```bash
ssh obelix 'at update run <id> --status cancelled'
ssh obelix 'at update run <id> --tag v2 --tag baseline'
ssh obelix 'at update run <id> --remove-tag old-tag'
```

### `at update execution <ts-job-id>` -- Add artifacts/metrics

```bash
ssh obelix 'at update execution 123 -a /path/to/model.pt'           # Artifact (default: model)
ssh obelix 'at update execution 123 -a /data/train.csv:dataset'     # With type
ssh obelix 'at update execution 123 -m accuracy=0.95 -m loss=0.05'  # Metrics
ssh obelix 'at update execution 123 -a model.pt -m f1=0.92'         # Both
```

Artifact types: model (default), dataset, statistics, metrics.

### `at clear` -- Bulk cleanup

```bash
ssh obelix 'at clear --all --dry-run'     # Preview
ssh obelix 'at clear --db'               # Remove database only
ssh obelix 'at clear --snapshots'        # Remove snapshots + git worktrees
ssh obelix 'at clear --pipelines'        # Remove resolved pipeline YAMLs
ssh obelix 'at clear --all --force'      # Everything, skip confirmation
```

---

## MCP Server & Tunnel

```bash
at-mcp                                   # Start FastMCP server (stdio)
at-mcp --transport sse --port 8000       # SSE mode
at mcp-tunnel obelix                     # Tunnel remote MCP over SSH
at mcp-tunnel obelix --port 9000         # Custom local port
```

**Read tools:** `list_runs`, `get_run`, `list_jobs`, `get_job`, `get_job_output`, `list_artifacts`, `get_artifact_lineage`, `list_projects`, `query_runs_by_artifacts`, `info`

**Write tools:** `sync_runs`, `cancel_run`, `add_metrics`, `create_project`

---

## Shell Completion

```bash
at completion                    # Auto-detect shell
at completion --shell fish       # Target shell
at completion fzf-aliases        # fzf integration aliases
```

---

## Status Reference

| Run Status | Meaning | Job Status | Meaning |
|-----------|---------|-----------|---------|
| PENDING | Created, not started | QUEUED | Waiting for deps |
| RUNNING | At least one active job | ALLOCATING | Waiting for GPUs |
| COMPLETED | All jobs succeeded | RUNNING | Executing |
| FAILED | At least one job failed | FINISHED | Exit code 0 |
| KILLED | Jobs killed by signal | FAILED | Non-zero exit |
| CANCELLED | User cancelled | SKIPPED | Dep failed |
| | | CACHED | Outputs reused |

---

## Remote Analysis

Beyond querying status, use `at` to investigate training progress, metrics, and failures.

### Reading Training Logs

```bash
# Last N lines of a job's output
ssh obelix 'at log <JOB_ID> -n 100'

# Full output
ssh obelix 'at log <JOB_ID>'

# Get log path for grep/tail operations
ssh obelix "grep 'train/loss\|eval/hit_at_1' \$(at log <JOB_ID> --path) | tail -20"
ssh obelix "grep 'system/memory_used_gb' \$(at log <JOB_ID> --path) | tail -10"
```

Training logs typically contain:
- **Progress bars**: `Training: X%|...| STEP/TOTAL [elapsed<ETA, speed]`
- **Metrics**: `[step] tag=value, tag=value` (train, eval, system, diag namespaces)
- **Warnings/errors**: shape mismatches, NaN, OOM, CUDA errors

When reporting, surface: current step + % progress, latest train/eval metrics with trend, GPU utilization and temperature, memory trend, and any errors.

### Locating Workdirs and Artifacts

From `at job <id>` or `at run <run-id>`, extract the `--workdir` argument from the command. This is where logs, checkpoints, and profiles live:

```
<workdir>/
  logs/
    events.out.tfevents.*           # metrics (TF2 tensor format)
    plugins/profile/<timestamp>/    # profile traces
  checkpoints/<step>/               # model checkpoints
```

### TensorBoard Event Files

CLU writes all metrics as TF2 tensors (not scalars). `tbparse`'s `reader.scalars` returns empty -- use `EventAccumulator` with tensors.

```bash
ssh obelix 'uv run --with tensorboard python3 -c "
from tensorboard.backend.event_processing.event_accumulator import EventAccumulator
import numpy as np

ea = EventAccumulator(\"<workdir>/logs\", size_guidance={\"tensors\": 0})
ea.Reload()
tags = sorted(t for t in ea.Tags()[\"tensors\"] if not t.startswith(\"_\"))
print(\"Tags:\", tags)

def val(tp):
    if tp.float_val: return float(tp.float_val[0])
    if tp.double_val: return float(tp.double_val[0])
    if tp.tensor_content:
        try: return float(np.frombuffer(tp.tensor_content, dtype=np.float32)[0])
        except: return float(np.frombuffer(tp.tensor_content, dtype=np.float64)[0])

for tag in tags:
    events = ea.Tensors(tag)
    if events:
        print(f\"\n{tag} ({len(events)} pts):\")
        for e in events[-10:]:
            print(f\"  step={e.step} value={val(e.tensor_proto):.6f}\")
"'
```

First list all tags, then read those relevant to the question. Common namespaces: `train/`, `eval/`, `diag/`, `system/`.

### Profile Trace Analysis

Traces live under `<workdir>/logs/plugins/profile/<timestamp>/` as `*.trace.json.gz`.

```bash
ssh obelix 'ls <workdir>/logs/plugins/profile/'

# Run analysis script on server
ssh obelix 'cd /home/hrandrianarivo/work/argimi && uv run scripts/xm/genir/analyze_profile.py <profile_dir>'

# Copy locally for inspection
scp -r obelix:<profile_dir> /tmp/profile_job<ID>/
```

What to look for:
- **GPU utilization**: below 80% suggests CPU bottlenecks or data starvation
- **Idle gaps**: long periods without GPU kernels
- **JIT spikes**: first-call latency >> steady-state (common with JAX)
- **Top CPU functions**: host-side bottlenecks

### Comparing Jobs

1. Extract the same metrics from both using the tensorboard snippet
2. Present side-by-side with deltas
3. For profiles: `analyze_profile.py` accepts two directories for before/after comparison

### Red Flags

- **Memory monotonically increasing**: likely a leak -- check `system/memory_used_gb`
- **GPU utilization at 0%**: stuck in JIT compilation, checkpointing, or eval
- **Step time increasing**: memory pressure, thermal throttling, or data pipeline degradation
- **All eval metrics identical**: model not learning -- check LR schedule, loss values

### Safety Reminders

- **Never run `git checkout` or `jj` on obelix** -- analysis and `at` commands only.
- **Never push to obelix** unless explicitly asked.
- Only look at jobs belonging to `hrandrianarivo`.
- Long SSH commands may timeout -- pipe through `tail -N` or `grep` to bound output.

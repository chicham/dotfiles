---
name: artitrack
description: "Artitrack: ML experiment tracking and remote job analysis on obelix. Use this skill whenever the user asks about experiment runs, job status, training progress, logs, metrics, tensorboard analysis, profile traces, pipeline management, or anything related to the `at` CLI. Also trigger when the user mentions obelix, a job ID, wants to check training, debug a failing job, query runs, cancel/delete experiments, write xmanager launch files, or says things like 'how's the training going', 'check job X', 'what's running on obelix', 'show me the metrics'. Covers the full lifecycle: submit, monitor, query, analyze, and clean up."
argument-hint: [cli command, job ID, or experiment description]
---

# Artitrack

Local-first ML experiment tracking with remote execution on obelix. Orchestrates pipelines via task-spooler, persists metadata in ML Metadata (MLMD/SQLite), and exposes everything through the `at` CLI. Provides an xmanager-compatible Python API for job submission.

**All `at` commands run on obelix via SSH.** The database and task-spooler live on the server.

## When to Read Which Reference

| User intent | Reference file |
|-------------|---------------|
| CLI commands, querying runs, job status, logs, remote analysis | [references/cli.md](references/cli.md) |
| Writing Python launch files, xmanager API, DAGs | [references/xmanager.md](references/xmanager.md) |
| Quick lookup | Keep reading below |

## Architecture

```
Python launch script (xmanager API)     <- written locally
        |
        v
  task-spooler on obelix                <- job scheduling & execution
        |
        v
  ML Metadata (SQLite) on obelix        <- persistent tracking
        |
        v
  at CLI via SSH / MCP server           <- query & manage
```

## MLMD Hierarchy

**Project -> Experiment -> PipelineRun -> JobExecution -> Artifacts**

## Most Common Commands

```bash
ssh obelix 'at status'              # Active runs dashboard
ssh obelix 'at last'                # Most recent run
ssh obelix 'at runs --failed'       # Failed runs
ssh obelix 'at runs -s running'     # Running runs
ssh obelix 'at run <run-id>'        # Run details + jobs
ssh obelix 'at job <job-id>'        # Single job details (by ts_job_id)
ssh obelix 'at log <job-id>'        # Job stdout/stderr
ssh obelix 'at log <job-id> -n 50'  # Last 50 lines
ssh obelix 'at log <job-id> --path' # Log file path (for grep/tail)
ssh obelix 'at sync'                # Force status sync from task-spooler
ssh obelix 'at cancel <run-id>'     # Cancel all jobs in a run
ssh obelix 'at metrics -e <name>'   # Metrics for an experiment
```

## Minimal Launch Script

```python
from xmanager import xm
from artitrack.launcher import xm_local

with xm_local.create_experiment(
    experiment_title="my_training",
    project="my-project",
) as exp:
    exp.add(xm.Job(
        name="train",
        executable=xm.Binary(path="python train.py"),
        executor=xm_local.TaskSpooler(),
        args={"learning_rate": 0.001},
    ))
```

## Entry Points

| Command | Description |
|---------|-------------|
| `at` / `uv run at` | Main CLI (on obelix) |
| `at-monitor` | Background status monitor daemon |
| `at-mcp` | MCP server for Claude integration |

## Safety Rules

- **Never run `git checkout` or `jj` on obelix** -- analysis and `at` commands only.
- **Never push to obelix** unless explicitly asked.
- Only look at jobs belonging to `hrandrianarivo`.
- Long SSH commands may timeout -- pipe through `tail -N` or `grep` to bound output.

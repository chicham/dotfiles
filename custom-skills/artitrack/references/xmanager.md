# Artitrack + XManager Launch Files

Artitrack extends Google's [xmanager](https://github.com/deepmind/xmanager) with a local task-spooler backend and ML Metadata tracking. Standard xmanager-style Python, but jobs run locally via `q` (task-spooler).

## Core Imports

```python
from xmanager import xm
from artitrack.launcher import xm_local
# For DAG pipelines:
from artitrack.launcher.flow import executable_graph
# For printing a summary after submission:
from artitrack.launcher.experiment import print_summary
```

## create_experiment()

Context manager that creates a PipelineRun in MLMD and yields an experiment object.

```python
with xm_local.create_experiment(
    experiment_title="Human-readable title",  # Optional
    project="project-name",                    # Optional, default: "default"
    experiment="experiment-name",              # Optional, default: title
    metadata_store=None,                       # Optional: custom MLMD store
    executor=None,                             # Optional: default TaskSpooler
    base_path=None,                            # Optional: override ~/.at
) as exp:
    ...
```

**Env var fallbacks:** `ARTITRACK_PROJECT`, `ARTITRACK_EXPERIMENT`, `ARTITRACK_DATA_DIR`

**Lifecycle:**
1. Enter → creates PipelineRun in MLMD (status: PENDING)
2. `exp.add()` → submits job to task-spooler, records JobExecution
3. Exit → submits monitor job, sets run to RUNNING, prints summary

Git metadata (commit, repo, dirty) is captured automatically for user scripts.

## xm.Job — Single Job

```python
job = xm.Job(
    name="train",
    executable=xm.Binary(path="python train.py"),
    executor=xm_local.TaskSpooler(),
    args={
        # Regular args → become --key value CLI flags
        "learning_rate": 0.001,
        "epochs": 100,
        "normalize": True,          # Boolean → --normalize (flag only)
        "cache": False,             # Boolean False → omitted

        # Artitrack-specific (extracted, not passed to command)
        "input_artifacts": {
            "dataset": {"path": "/data/train.csv", "type": "Dataset"},
        },
        "output_artifacts": {
            "model": {"path": "/output/model.pt", "type": "Model"},
        },
    },
)
handle = exp.add(job)
```

**Artifact types:** `Dataset`, `Model`, `Statistics`, `Metrics`

## xm.JobGroup — Parallel Jobs

Jobs within a JobGroup run **in parallel**. All share the same external dependencies.

```python
handles = exp.add(xm.JobGroup(
    train_a=xm.Job(
        name="train_a",
        executable=xm.Binary(path="python train.py"),
        executor=xm_local.TaskSpooler(),
        args={"model": "resnet50"},
    ),
    train_b=xm.Job(
        name="train_b",
        executable=xm.Binary(path="python train.py"),
        executor=xm_local.TaskSpooler(),
        args={"model": "vit_base"},
    ),
))
# handles: list[TaskSpoolerHandle]
```

## Dependencies

Use `depends_on` for sequential execution. Accepts single handle or list.

```python
preprocess = exp.add(xm.Job(...))

# Single dependency
train = exp.add(xm.Job(...), depends_on=preprocess)

# Multiple dependencies (waits for ALL)
evaluate = exp.add(xm.Job(...), depends_on=[train_a, train_b])

# JobGroup depending on previous step
parallel = exp.add(xm.JobGroup(...), depends_on=preprocess)

# Step depending on entire JobGroup (list of handles)
aggregate = exp.add(xm.Job(...), depends_on=parallel_handles)
```

Maps to task-spooler's `-W` (wait_success) flag.

## Pipeline — DAG of Jobs

For complex DAGs with named dependencies:

```python
from artitrack.launcher.flow import executable_graph

pipeline = executable_graph(
    jobs={
        "preprocess": xm.Job(
            executable=xm.Binary(path="python preprocess.py"),
            executor=xm_local.TaskSpooler(),
        ),
        "train": xm.Job(
            executable=xm.Binary(path="python train.py"),
            executor=xm_local.TaskSpooler(),
        ),
        "evaluate": xm.Job(
            executable=xm.Binary(path="python eval.py"),
            executor=xm_local.TaskSpooler(),
        ),
    },
    jobs_deps={
        "train": ["preprocess"],
        "evaluate": ["train"],
        # "preprocess" has no entry → no deps, runs immediately
    },
)
handles = exp.add(pipeline)
```

Validates DAG (no cycles, valid references), topological sort via Kahn's algorithm.

## Work-Unit Args — Runtime Overrides

```python
# Override args at submission time
exp.add(
    xm.Job(..., args={"lr": 0.01}),
    args={"args": {"lr": 0.001, "extra": True}},  # Overrides lr
)

# For JobGroup, keyed by job name
exp.add(
    xm.JobGroup(a=job_a, b=job_b),
    args={"a": {"args": {"batch": 64}}, "b": {"args": {"batch": 128}}},
)
```

## Patterns

### Hyperparameter Sweep

Each config gets its own PipelineRun, grouped under one Experiment:

```python
PROJECT = "ml_research"
EXPERIMENT = "lr_sweep"

for lr in [0.001, 0.01, 0.1]:
    with xm_local.create_experiment(
        project=PROJECT,
        experiment=EXPERIMENT,
        experiment_title=f"lr{lr}",
    ) as exp:
        exp.add(xm.Job(
            name="train",
            executable=xm.Binary(path="python train.py"),
            executor=xm_local.TaskSpooler(),
            args={"learning_rate": lr},
        ))
```

MLMD result:
```
Project("ml_research")
  └── Experiment("lr_sweep")
      ├── PipelineRun("lr0.001")
      ├── PipelineRun("lr0.01")
      └── PipelineRun("lr0.1")
```

### Fan-Out / Fan-In

Setup → parallel work → aggregate:

```python
with xm_local.create_experiment(experiment_title="fan_out_in") as exp:
    setup = exp.add(xm.Job(name="setup", executable=..., executor=executor))

    parallel = exp.add(
        xm.JobGroup(
            exp1=xm.Job(name="exp1", executable=..., executor=executor),
            exp2=xm.Job(name="exp2", executable=..., executor=executor),
        ),
        depends_on=setup,
    )

    exp.add(
        xm.Job(name="aggregate", executable=..., executor=executor),
        depends_on=parallel,
    )
```

### Server/Client with Cleanup

```python
with xm_local.create_experiment(experiment_title="server_client") as exp:
    server = exp.add(xm.Job(
        name="server",
        executable=xm.Binary(path="python serve.py --port 8080"),
        executor=xm_local.TaskSpooler(),
    ))
    client = exp.add(xm.Job(
        name="client",
        executable=xm.Binary(path="python client.py --port 8080"),
        executor=xm_local.TaskSpooler(),
    ))

    # Optional: wait and clean up
    import asyncio
    asyncio.run(client.wait())
    server.stop()
```

### Print Summary

```python
from artitrack.launcher.experiment import print_summary

with xm_local.create_experiment(...) as exp:
    exp.add(...)
    print_summary(exp)
```

Output: pipeline name, run_id, job count, per-job status table.

## YAML Pipeline Definitions

Pipelines can also be defined as YAML and loaded via `PipelineDefinition.from_raw_yaml()`:

```yaml
name: training_pipeline
project: ml_research
experiment: baseline
version: "2.0"

defaults:
  lr: 0.001
  data_dir: /data

steps:
  - name: preprocess
    command: python preprocess.py
    arguments:
      input_dir: ${data_dir}/raw
      output_dir: ${data_dir}/processed
    input_artifacts:
      - path: ${data_dir}/raw
        type: dataset
    output_artifacts:
      - path: ${data_dir}/processed
        type: dataset

  - name: train
    command: python train.py
    arguments:
      lr: ${lr}
      data_dir: ${data_dir}/processed
    depends_on: [preprocess]
    gpu_count: 1
    input_artifacts:
      - path: ${data_dir}/processed
        type: dataset
    output_artifacts:
      - path: ${data_dir}/model.pt
        type: model
    metrics:
      - name: accuracy
        pattern: "accuracy: ([0-9.]+)"
        type: float
        aggregate: last
    timeout: 3600

  - name: evaluate
    command: python evaluate.py
    depends_on: [train]
    input_artifacts:
      - path: ${data_dir}/model.pt
        type: model
    output_artifacts:
      - path: ${data_dir}/results.json
        type: metrics
```

**Template variables:** `${var}` resolved from `defaults` and `environment` sections.

**Step fields:** `command`, `arguments`, `input_artifacts`, `output_artifacts`, `depends_on`, `gpu_count`, `gpu_indices`, `slots`, `env`, `metrics`, `retry` (`max_attempts`, `delay`, `exponential_backoff`), `timeout`, `kill_after`, `execution_type` (TRAIN|TRANSFORM|PROCESS|EVALUATE|DEPLOY).

## Monitoring

On experiment exit, artitrack submits a **monitor job** to task-spooler:
- Polls every 60s for status changes
- Updates MLMD on transitions (queued → running → finished/failed)
- Derives run status from all jobs
- Exits when all jobs are terminal

Fire-and-forget — the launcher exits immediately. Check progress with:

```bash
at status              # Active runs
at run <run-id>        # Run details
at log <job-id>        # Job output
```

## TaskSpoolerHandle

Returned by `exp.add()`. Key properties:

```python
handle.ts_job_id       # int: task-spooler job ID
handle.step_name       # str: step name
handle.stop()          # Kill the job
await handle.wait()    # Wait for completion (async)
```

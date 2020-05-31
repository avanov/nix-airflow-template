====================
nix-airflow-template
====================

# Environment

```bash
nix-shell
make init
```

## What is inside?

* local non-containerized Postgres instance;
* Airflow instance with a Celery and a Kubernetes Executor;
* Python 3.7 runtime;
* Version-pinned with Poetry;
* Shortcut commands to control the instance;


# Instantiating Airflow
```bash
make airflow-start
airflow scheduler
```

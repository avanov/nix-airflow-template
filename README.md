nix-airflow-template
====================

Airflow local instance template, with a help from Nix and Poetry. Use it to get acquainted with the platform.

# Environment

To establish a local environment from this repository, you will need
[Nix installed](https://nixos.wiki/wiki/Nix_Installation_Guide#Single-user_install)

Once Nix is installed, simply run:

```bash
nix-shell
make init
```

## What is inside?

* local non-containerized Postgres instance;
* latest Airflow instance (as of writing this readme);
* Python 3.7 runtime;
* version-pinned with Poetry;
* shortcut commands to control the instance.


# Instantiating Airflow

```bash
make airflow-start
```

## How to test it

Navigate your browser to [localhost:3333](http://localhost:3333/), enable the example DAG,
refresh the page and observe that the DAG has been scheduled for execution. In a few seconds
you will see that it completes. On the rightmost column, click the "Tree View" icon.

Every green square represents a dag task, every circle is a complete DAG instance.
You can find the result of the operator by clicking on a square, and selecting View Log -> XCom.

## How to reset everything

The following command removes the current Airflow DB instance, and recreates it from scratch again

```bash
make reset
```

## How to stop the instance

To stop Airflow and Postgres instances run

```bash
make airflow-stop
```

# License

[0-clause BSD License](https://en.wikipedia.org/wiki/BSD_licenses#0-clause_license_("Zero_Clause_BSD"))

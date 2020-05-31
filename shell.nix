with (import (builtins.fetchTarball {
  name = "nix-airflow-template-nixpkgs";
  url = https://github.com/NixOS/nixpkgs-channels/archive/d6cf34ea5a3091b3ec18bf0879c29b5e7de2e390.tar.gz;
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "0rkbx1xp7yk3xhji9qjwfs5ab0bz9invii8snspdrdx84rqxaw6g";
}) {});

let
    macOsDeps = with pkgs; stdenv.lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.CoreServices
        darwin.apple_sdk.frameworks.ApplicationServices
    ];
    pythonEnv = pkgs.python37Full.withPackages (pkgs: with pkgs; [
        pre-commit
        poetry
        pip
        virtualenv
    ]);
in

# Make a new "derivation" that represents our shell
stdenv.mkDerivation {
    name = "nix-airflow-template";

    # The packages in the `buildInputs` list will be added to the PATH in our shell
    # Python-specific guide:
    # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md
    buildInputs = [
        # see https://nixos.org/nixos/packages.html
        # Python distribution
        pythonEnv
        ncurses
        libxml2
        libxslt
        libzip
        zlib
        libressl

        postgresql
        # root CA certificates
        cacert
        which
        gnumake
    ] ++ macOsDeps;
    shellHook = ''
        # Set SOURCE_DATE_EPOCH so that we can use python wheels.
        # This compromises immutability, but is what we need
        # to allow package installs from PyPI
        export SOURCE_DATE_EPOCH=$(date +%s)

        VENV_DIR=$PWD/.venv

        export PATH=$VENV_DIR/bin:$PATH
        export PYTHONPATH=""
        export LANG=en_US.UTF-8

        # https://python-poetry.org/docs/configuration/
        export POETRY_VIRTUALENVS_CREATE=true
        export POETRY_VIRTUALENVS_IN_PROJECT=true
        export POETRY_VIRTUALENVS_PATH=$VENV_DIR
        export PIP_CACHE_DIR=$PWD/.local/pip-cache

        # Setup virtualenv
        if [ ! -d $VENV_DIR ]; then
            python -m virtualenv $VENV_DIR
            python -m poetry install
        fi

        # Install git hooks
        if [ ! -f "$PWD/.git/hooks/pre-commit" ]; then
            pre-commit install;
        fi

        # Dirty fix for Linux systems
        # https://nixos.wiki/wiki/Packaging/Quirks_and_Caveats
        export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib/:$LD_LIBRARY_PATH

        export LOCAL_DATA=$PWD/.local
        export LOGS_DIR=$PWD/.local/logs
        export PROJECT_DIR=$PWD/nix-airflow-template

        export AIRFLOW_HOME=$PROJECT_DIR

        # The folder where your airflow pipelines live, most likely a
        # subfolder in a code repository. This path must be absolute.
        export AIRFLOW__CORE__DAGS_FOLDER=$PROJECT_DIR/dags

        # The executor class that airflow should use. Choices include
        # SequentialExecutor, LocalExecutor, CeleryExecutor, DaskExecutor, KubernetesExecutor
        export AIRFLOW__CORE__EXECUTOR=LocalExecutor

        # Where your Airflow plugins are stored
        export AIRFLOW__CORE__PLUGINS_FOLDER=$PROJECT_DIR/plugins
        # # The folder where airflow should store its log files
        # This path must be absolute

        export AIRFLOW__CORE__BASE_LOG_FOLDER=$LOGS_DIR
        export AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY=$LOGS_DIR/scheduler
        export AIRFLOW__CORE__DAG_PROCESSOR_MANAGER_LOG_LOCATION=$LOGS_DIR/dag_manager.log
        export AIRFLOW__WEBSERVER__ACCESS_LOGFILE=$LOGS_DIR/airflow-webserver-access.log
        export AIRFLOW__WEBSERVER__ERROR_LOGFILE=$LOGS_DIR/airflow-webserver-error.log
        export AIRFLOW__SCHEDULER__ACCESS_LOGFILE=$LOGS_DIR/airflow-scheduler-access.log
        export AIRFLOW__SCHEDULER__ERROR_LOGFILE=$LOGS_DIR/airflow-scheduler-error.log

        # The SqlAlchemy connection string to the metadata database.
        # SqlAlchemy supports many different database engine, more information
        # their website
        export AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://nix-airflow-template:@localhost:5454/nix-airflow-template"
        # Whether to load the DAG examples that ship with Airflow. It's good to
        # get started, but you probably want to set this to False in a production
        # environment

        export AIRFLOW__CORE__LOAD_EXAMPLES=False

        # Whether to load the default connections that ship with Airflow. It's good to
        # get started, but you probably want to set this to False in a production
        # environment
        export AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS=False
    '';
}

# https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
# https://ftp.gnu.org/old-gnu/Manuals/make-3.80/html_node/make_17.html
PG_MKFILE_PATH       := $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
PG_MKFILE_DIR        := $(shell cd $(shell dirname $(PG_MKFILE_PATH)); pwd)
PG_ROOT              := $(PG_MKFILE_DIR)
PG_LOCAL_UNTRACK_DIR := $(PG_ROOT)/../.local/postgres
PG_LOCAL_DB_PATH     := $(PG_LOCAL_UNTRACK_DIR)/pgdata
POSTGRES_PORT        := 5454
PG_PROJECT_NAME      := nix-airflow-template


postgres-local-cluster:
	pg_ctl initdb -D $(PG_LOCAL_DB_PATH)

postgres-local-setup:
	createuser --superuser $(PG_PROJECT_NAME) -p $(POSTGRES_PORT)
	createdb --owner $(PG_PROJECT_NAME) --encoding utf8 -p $(POSTGRES_PORT) $(PG_PROJECT_NAME)

postgres-init: postgres-local-cluster
	$(MAKE) postgres-start
	$(MAKE) postgres-local-setup

postgres-start:
	@if [ -z "$(shell lsof -nti:$(POSTGRES_PORT))" ]; then pg_ctl start -D $(PG_LOCAL_DB_PATH) -l $(PG_LOCAL_DB_PATH)/logs.log -o "-p $(POSTGRES_PORT)"; fi;

postgres-stop:
	@if ! [ -z "$(shell lsof -nti:$(POSTGRES_PORT))" ]; then pg_ctl stop -D $(PG_LOCAL_DB_PATH) -o "-p $(POSTGRES_PORT)"; fi;

postgres-purge:
	rm -rvf $(PG_LOCAL_UNTRACK_DIR)

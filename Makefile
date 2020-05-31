# https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
# https://ftp.gnu.org/old-gnu/Manuals/make-3.80/html_node/make_17.html
PROJECT_MKFILE_PATH := $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
PROJECT_MKFILE_DIR  := $(shell cd $(shell dirname $(PROJECT_MKFILE_PATH)); pwd)
PROJECT_LOCAL       := ${LOCAL_DATA}

include $(PROJECT_MKFILE_DIR)/postgres/Makefile

AIRFLOW_WEBSERVER_PORT=3333
AIRFLOW_SCHEDULER_PIDFILE=$(PROJECT_LOCAL)/airflow-scheduler.pid
AIRFLOW_WEBSERVER_PIDFILE=$(PROJECT_LOCAL)/airflow-webserver.pid

init:
	$(MAKE) postgres-init
	$(MAKE) airflow-init

airflow-init:
	airflow initdb

airflow-start:
	$(MAKE) postgres-start

	# https://stackoverflow.com/a/61633778
	airflow webserver -p $(AIRFLOW_WEBSERVER_PORT) \
		--daemon \
		--pid $(AIRFLOW_WEBSERVER_PIDFILE) \
		--access_logfile $(AIRFLOW__WEBSERVER__ACCESS_LOGFILE) \
		--stdout $(AIRFLOW__WEBSERVER__ACCESS_LOGFILE) \
		--log-file $(AIRFLOW__WEBSERVER__ACCESS_LOGFILE) \
		--error_logfile $(AIRFLOW__WEBSERVER__ERROR_LOGFILE) \
		--stderr $(AIRFLOW__WEBSERVER__ERROR_LOGFILE)

	airflow scheduler --daemon --pid $(AIRFLOW_SCHEDULER_PIDFILE) \
		--stdout $(AIRFLOW__SCHEDULER__ACCESS_LOGFILE) \
		--log-file $(AIRFLOW__SCHEDULER__ACCESS_LOGFILE) \
		--stderr $(AIRFLOW__SCHEDULER__ERROR_LOGFILE)

airflow-stop:
	@echo "Stopping Airflow gracefully..."
	cat $(AIRFLOW_SCHEDULER_PIDFILE) | xargs kill -s TERM
	@if ! [ -z "$(shell lsof -nti:$(AIRFLOW_WEBSERVER_PORT))" ]; then kill -s TERM $(shell lsof -nti:$(AIRFLOW_WEBSERVER_PORT)); fi;
	$(MAKE) postgres-stop
	@echo "Done."

typecheck:
	poetry run mypy -p nix-airflow-template

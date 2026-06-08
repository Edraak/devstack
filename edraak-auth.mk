edraak-auth.help:
	@echo ""
	@echo "make edraak-auth.COMMAND"
	@echo "======================================"
	@echo ""
	@echo "Commands:"
	@echo "build:                Build the docker image"
	@echo "migrate:              Run django migrations i.e. python manage.py migrate"
	@echo "makemigrations:       Create new django migrations"
	@echo "install_pip:          Install python dependencies in 'requirements.txt' file"
	@echo "shell:                Open bash shell inside docker container"
	@echo "provision:            Run provision script, prepare the env"
	@echo "restart:              Restart the container"
	@echo "manage <Command>:     Run any manage.py command"
	@echo "help:                 Print help and exit"
	@echo ""

edraak-auth.build:
	docker build -t edraak/edraak-auth -f ${DEVSTACK_WORKSPACE}/edraak-auth/Dockerfile ${DEVSTACK_WORKSPACE}/edraak-auth

edraak-auth.migrate:
	docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth python manage.py migrate --noinput

edraak-auth.makemigrations:
	docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth python manage.py makemigrations

edraak-auth.install_pip:
	docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth pip install -r requirements.txt

edraak-auth.shell:
	docker exec -it edraak.devstack.edraak_auth /bin/bash

edraak-auth.provision:
	./provision-edraak-auth.sh

edraak-auth.restart:
	docker exec -t edraak.devstack.edraak_auth bash -c 'kill $$(ps aux | grep "manage.py runserver" | egrep -v "while|grep" | awk "{print \$$2}")'

edraak-auth.manage:
	docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth python manage.py $(filter-out $@,$(MAKECMDGOALS))

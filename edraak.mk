edraak.provision:
	DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision-edraak.sh

edraak.sync.provision: | dev.sync.daemon.start
	DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-sync.yml" ./provision-edraak.sh

edraak.build.all:
	$(MAKE) edraak.build.programs
	$(MAKE) edraak.build.marketing

edraak.build.programs:
	docker build -t edraak-devstack-programs -f ../edraak-programs/Dockerfile ../edraak-programs

edraak.build.marketing:
	docker build -t edraak-devstack-marketing -f ../marketing-site/Dockerfile ../marketing-site

edraak.programs.help:
	echo ""
	echo "make edraak.programs.COMMAND"
	echo "======================================"
	echo ""
	echo "Commands:"
	echo ""
	echo "migrate:              Run django migrations i.e. python manage.py migrate"
	echo "compile_static:       Run python manage.py compilestatic --settings=edraakprograms.static"
	echo "install_pip:          Install python dependencies in 'requirements.txt' file"
	echo "install_npm:          Install npm dependencies in 'package.json' file"
	echo "gulp:                 Run gulp command"
	echo "install_all:          Runs install_pip, install_npm, migrate, compilestatic"
	echo "watch_js:             Run watcher to watch JavaScript changes"
	echo "watch_css:            Run watcher to watch and compile scss changes"
	echo "manage:               Run any manage.py command"
	echo "shell:                Open bash inside docker container"
	echo "copy_cache:           Copy node_modules, installed at build time, to the current app"
	echo "help:                 Print help and exit"
	echo ""

edraak.programs.migrate:
	docker-compose exec edraak_programs python manage.py migrate --settings=edraakprograms.dev

edraak.programs.compile_static:
	docker-compose exec edraak_programs python manage.py compilestatic --settings=edraakprograms.static

edraak.programs.install_pip:
	docker-compose exec edraak_programs pip install -r requirements.txt

edraak.programs.install_npm:
	docker-compose exec edraak_programs npm install

edraak.programs.copy_cache:
	docker-compose exec edraak_programs cp -Rnv /cache/node_modules /cache/.compiled /app

edraak.programs.gulp:
	docker-compose exec edraak_programs gulp

edraak.programs.install_all:
	$(MAKE) edraak.programs.copy_cache
	$(MAKE) edraak.programs.gulp
	$(MAKE) edraak.programs.migrate
	$(MAKE) edraak.programs.compilestatic

edraak.programs.watch_js:
	docker-compose exec edraak_programs gulp watch

edraak.programs.provision:
	DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision-edraak-programs.sh

edraak.programs.watch_css:
	docker-compose exec edraak_programs npm run watch-scss

edraak.programs.shell:
	docker-compose exec edraak_programs bash

edraak.marketing.shell:
	docker-compose exec edraak_marketing bash

edraak.marketing.provision:
	DOCKER_COMPOSE_FILES="-f docker-compose.yml -f docker-compose-host.yml" ./provision-edraak-marketing.sh

marketing-restart: ## Kill the Marketing Django development server. The watcher process will restart it.
	docker exec -t edraak.devstack.marketing bash -c 'kill $$(ps aux | grep "manage.py" | egrep -v "while|grep" | awk "{print \$$2}")'

programs-restart: ## Kill the Edraak Programs Django development server. The watcher process will restart it.
	docker exec -t edraak.devstack.programs bash -c 'kill $$(ps aux | grep "manage.py" | egrep -v "while|grep" | awk "{print \$$2}")'

edraak.restart:  ## Restart all of the lms, studio, marketing and progs
	make marketing-restart
	make programs-restart
	make lms-restart
	make studio-restart

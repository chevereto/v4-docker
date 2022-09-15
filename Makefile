# Default arguments
TARGET ?= dev
VERSION ?= 4.0
PHP ?= 8.1
DOCKER_USER ?= www-data
PROTOCOL ?= http
# NAMESPACE prefix in project's name
NAMESPACE ?= local
PROJECT_BASENAME = ${NAMESPACE}_chevereto-docker
CONTAINER_BASENAME ?= ${NAMESPACE}_chevereto-${VERSION}-php-${PHP}
TAG ?= ghcr.io/chevereto/v4-docker:${VERSION}-php${PHP}
# SERVICE php|database|http
SERVICE ?= php
# License ask
LICENSE ?= $(shell stty -echo; read -p "Chevereto V4 License key: " license; stty echo; echo $$license)
# Port flags
FLAG_PROD = 1
FLAG_DEMO = 2
FLAG_DEV_DB = 3
FLAG_DEV = 4
VERSION_DOTLESS = $(shell echo \${VERSION} | tr -d '.')
PHP_DOTLESS = $(shell echo \${PHP} | tr -d '.')
VERSION_PORT = ${VERSION_DOTLESS}${PHP_DOTLESS}
# Echo doing
FEEDBACK = $(shell echo 👉 V\${VERSION} \${NAMESPACE} [PHP \${PHP}] \(\${DOCKER_USER}\))
FEEDBACK_SHORT = $(shell echo 👉 V\${VERSION} [PHP \${PHP}] \(\${DOCKER_USER}\))

SOURCE ?= ~/git/chevereto/v4

arguments:
	@echo "${FEEDBACK}"

# Tools

build-httpd:
	@echo "👉 Downloading source httpd.conf"
	@docker run --rm httpd:2.4 cat /usr/local/apache2/conf/httpd.conf > httpd/httpd.conf
	@echo "👉 Adding httpd/chevereto.conf to httpd/httpd.conf"
	@cat httpd/chevereto.conf >> httpd/httpd.conf
	@echo "✅ httpd/httpd.conf updated"

# Docker

image:
	@echo "${FEEDBACK_SHORT}"
	@docker build . \
		-f chevereto/Dockerfile \
		--build-arg PHP=${PHP} \
		-t ${TAG}

pull:
	@echo "${FEEDBACK_SHORT}"
	@docker pull ${TAG}

bash: arguments
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-${TARGET}_${SERVICE} \
		bash

repl: arguments
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-${TARGET}_${SERVICE} \
		app/bin/repl

log-access: arguments
	@docker logs ${CONTAINER_BASENAME}-${TARGET}_${SERVICE} -f 2>/dev/null

log-error: arguments
	@docker logs ${CONTAINER_BASENAME}-${TARGET}_${SERVICE} -f 1>/dev/null

# Projects

dev: dev--down--volumes
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	FLAG_DEV=${FLAG_DEV} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	VERSION_PORT=${VERSION_PORT} \
	TAG=${TAG} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-dev \
		-f projects/dev.yml \
		up -d
	@docker exec -it \
		${CONTAINER_BASENAME}-dev_php \
		bash /var/scripts/sync.sh
	@docker exec --user ${DOCKER_USER} -it \
		${CONTAINER_BASENAME}-dev_php \
		composer dump-autoload \
			--working-dir app
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-dev_php \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--update: dev--down
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	FLAG_DEV=${FLAG_DEV} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	VERSION_PORT=${VERSION_PORT} \
	TAG=${TAG} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-dev \
		-f projects/dev.yml \
		up -d
	@docker exec -it \
		${CONTAINER_BASENAME}-dev_php \
		bash /var/scripts/sync.sh
	@docker exec --user ${DOCKER_USER} -it \
		${CONTAINER_BASENAME}-dev_php \
		composer dump-autoload \
			--working-dir app \
			--classmap-authoritative
	@echo "👉 http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--down:
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	docker compose \
		-p ${PROJECT_BASENAME}-dev \
		-f projects/dev.yml \
		down

dev--down--volumes:
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	docker compose \
		-p ${PROJECT_BASENAME}-dev \
		-f projects/dev.yml \
		down --volumes

dev--demo: arguments
	@docker exec -it \
    	${CONTAINER_BASENAME}-dev_php \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${DOCKER_USER} \
		-it ${CONTAINER_BASENAME}-dev_php \
		app/bin/legacy -C bulk-importer
	@echo "👉 http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--composer: arguments
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-dev_php \
		composer ${run} \
			--working-dir app \
			--ignore-platform-reqs

dev--test: arguments
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-dev_php \
		app/vendor/bin/phpunit -c app/phpunit.xml

dev--sh: arguments
	@docker exec -it \
		${CONTAINER_BASENAME}-dev_${SERVICE} \
		bash /var/scripts/${run}.sh

prod: prod--down--volumes
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	FLAG_PROD=${FLAG_PROD} \
	LICENSE=${LICENSE} \
	VERSION_PORT=${VERSION_PORT} \
	TAG=${TAG} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-prod \
		-f projects/prod.yml \
		up -d
	@echo "👉 http://localhost:${FLAG_PROD}${VERSION_PORT}"

prod--down:
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE="" \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-prod \
		-f projects/prod.yml \
		down

prod--down--volumes:
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE="" \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-prod \
		-f projects/prod.yml \
		down --volumes

demo: demo--down--volumes
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	FLAG_DEMO=$(FLAG_DEMO) \
	LICENSE=${LICENSE} \
	VERSION_PORT=${VERSION_PORT} \
	TAG=${TAG} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-demo \
		-f projects/demo.yml \
		up -d
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-demo_php \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@docker exec -it \
    	${CONTAINER_BASENAME}-demo_php \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${DOCKER_USER} \
		-it ${CONTAINER_BASENAME}-demo_php \
		app/bin/legacy -C bulk-importer
	@echo "👉 admin:password http://localhost:${FLAG_DEMO}${VERSION_PORT}"

demo--down:
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-demo \
		-f projects/demo.yml \
		down

demo--down--volumes:
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-demo \
		-f projects/demo.yml \
		down --volumes

# General purpose docker compose

compose-up: arguments
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	TAG=${TAG} \
	FLAG_DEV=${FLAG_DEV} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	FLAG_PROD=${FLAG_PROD} \
	FLAG_DEMO=${FLAG_DEMO} \
	VERSION=${VERSION} \
	VERSION_PORT=${VERSION_PORT} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		up

compose-up-d: arguments
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	TAG=${TAG} \
	FLAG_DEV=${FLAG_DEV} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	FLAG_PROD=${FLAG_PROD} \
	FLAG_DEMO=${FLAG_DEMO} \
	VERSION=${VERSION} \
	VERSION_PORT=${VERSION_PORT} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		up -d

compose-stop: arguments
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE='' \
	FLAG_DEV=${FLAG_DEV} \
	FLAG_DEV_DB=${FLAG_DEV_DB} \
	FLAG_PROD=${FLAG_PROD} \
	FLAG_DEMO=${FLAG_DEMO} \
	VERSION=${VERSION} \
	VERSION_PORT=${VERSION_PORT} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		stop

compose-down: arguments
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE='' \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		down

compose-down--volumes: arguments
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE='' \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		down --volumes

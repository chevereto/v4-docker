TARGET ?= dev
SOURCE ?= ~/git/chevereto/v4

VERSION ?= 4.0
PHP ?= 8.1
DOCKER_USER ?= www-data
HOSTNAME ?= localhost
HOSTNAME_PATH ?= /
PROTOCOL ?= http

NAMESPACE ?= local
PROJECT_BASENAME = ${NAMESPACE}_chevereto-docker
CONTAINER_BASENAME ?= ${NAMESPACE}_chevereto-${VERSION}-php-${PHP}
TAG ?= ghcr.io/chevereto/v4-docker:${VERSION}-php${PHP}

SERVICE ?= php
LICENSE ?= $(shell stty -echo; read -p "Chevereto V4 License key: 🔑" license; stty echo; echo $$license)

PORT_FLAG_PROD = 1
PORT_FLAG_DEMO = 2
PORT_FLAG_DBDEV = 3
PORT_FLAG_DEV = 4

VERSION_DOTLESS = $(shell echo \${VERSION} | tr -d '.')
PHP_DOTLESS = $(shell echo \${PHP} | tr -d '.')
VERSION_PORT = ${VERSION_DOTLESS}${PHP_DOTLESS}

FEEDBACK = $(shell echo 👉 V\${VERSION} \${NAMESPACE} [PHP \${PHP}] \(\${DOCKER_USER}\))
FEEDBACK_SHORT = $(shell echo 👉 V\${VERSION} [PHP \${PHP}] \(\${DOCKER_USER}\))

ENDPOINT = ${PROTOCOL}://${HOSTNAME}
ENDPOINT_CONTEXT = ${VERSION_PORT}${HOSTNAME_PATH}

URL_DEV = ${ENDPOINT}:${PORT_FLAG_DEV}${ENDPOINT_CONTEXT}
URL_DEMO = ${ENDPOINT}:${PORT_FLAG_DEMO}${ENDPOINT_CONTEXT}
URL_PROD = ${ENDPOINT}:${PORT_FLAG_PROD}${ENDPOINT_CONTEXT}

feedback:
	@./scripts/logo.sh
	@echo "${FEEDBACK}"

feedback--short:
	@echo "${FEEDBACK_SHORT}"

feedback--dev:
	@echo "${URL_DEV}"

feedback--demo:
	@echo "${URL_DEMO}"

feedback--prod:
	@echo "${URL_DEMO}"

# Tools

build-httpd:
	@echo "👉 Downloading source httpd.conf"
	@docker run --rm httpd:2.4 cat /usr/local/apache2/conf/httpd.conf > httpd/httpd.conf
	@echo "👉 Adding httpd/chevereto.conf to httpd/httpd.conf"
	@cat httpd/chevereto.conf >> httpd/httpd.conf
	@echo "✅ httpd/httpd.conf updated"

# Docker

image: feedback--short
	@docker build . \
		-f chevereto/Dockerfile \
		--build-arg PHP=${PHP} \
		-t ${TAG}

pull: feedback--short
	@docker pull ${TAG}

bash: feedback
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-${TARGET}_${SERVICE} \
		bash

repl: feedback
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-${TARGET}_${SERVICE} \
		app/bin/repl

log-access: feedback
	@docker logs ${CONTAINER_BASENAME}-${TARGET}_${SERVICE} -f 2>/dev/null

log-error: feedback
	@docker logs ${CONTAINER_BASENAME}-${TARGET}_${SERVICE} -f 1>/dev/null

# Projects

dev: feedback feedback--dev dev--down--volumes
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	PORT_FLAG_DEV=${PORT_FLAG_DEV} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_DEV=${URL_DEV} \
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
	@echo "👉 admin:password ${URL_DEV}"

dev--update: feedback dev--down
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	PORT_FLAG_DEV=${PORT_FLAG_DEV} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_DEV=${URL_DEV} \
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
	@echo "👉 ${URL_DEV}"

dev--down: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	docker compose \
		-p ${PROJECT_BASENAME}-dev \
		-f projects/dev.yml \
		down

dev--down--volumes: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	docker compose \
		-p ${PROJECT_BASENAME}-dev \
		-f projects/dev.yml \
		down --volumes

dev--demo: feedback
	@docker exec -it \
    	${CONTAINER_BASENAME}-dev_php \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${DOCKER_USER} \
		-it ${CONTAINER_BASENAME}-dev_php \
		app/bin/legacy -C bulk-importer
	@echo "👉 ${URL_DEV}"

dev--composer: feedback
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-dev_php \
		composer ${run} \
			--working-dir app \
			--ignore-platform-reqs

dev--test: feedback
	@docker exec -it --user ${DOCKER_USER} \
		${CONTAINER_BASENAME}-dev_php \
		app/vendor/bin/phpunit -c app/phpunit.xml

dev--sh: feedback
	@docker exec -it \
		${CONTAINER_BASENAME}-dev_${SERVICE} \
		bash /var/scripts/${run}.sh

prod: feedback feedback--prod prod--down--volumes
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	PORT_FLAG_PROD=${PORT_FLAG_PROD} \
	LICENSE=${LICENSE} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_PROD=${URL_PROD} \
	TAG=${TAG} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-prod \
		-f projects/prod.yml \
		up -d
	@echo "👉 ${URL_PROD}"

prod--down: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE="" \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-prod \
		-f projects/prod.yml \
		down

prod--down--volumes: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE="" \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-prod \
		-f projects/prod.yml \
		down --volumes

demo: feedback feedback--demo demo--down--volumes
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	PORT_FLAG_DEMO=$(PORT_FLAG_DEMO) \
	LICENSE=${LICENSE} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_DEMO=${URL_DEMO} \
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
	@echo "👉 admin:password ${URL_DEMO}"

demo--down: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-demo \
		-f projects/demo.yml \
		down

demo--down--volumes: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-demo \
		-f projects/demo.yml \
		down --volumes

# General purpose docker compose

compose-up: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	TAG=${TAG} \
	PORT_FLAG_DEV=${PORT_FLAG_DEV} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	PORT_FLAG_PROD=${PORT_FLAG_PROD} \
	PORT_FLAG_DEMO=${PORT_FLAG_DEMO} \
	VERSION=${VERSION} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_DEV=${URL_DEV} \
	URL_DEMO=${URL_DEMO} \
	URL_PROD=${URL_PROD} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		up

compose-up-d: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE=${SOURCE} \
	TAG=${TAG} \
	PORT_FLAG_DEV=${PORT_FLAG_DEV} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	PORT_FLAG_PROD=${PORT_FLAG_PROD} \
	PORT_FLAG_DEMO=${PORT_FLAG_DEMO} \
	VERSION=${VERSION} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_DEV=${URL_DEV} \
	URL_DEMO=${URL_DEMO} \
	URL_PROD=${URL_PROD} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		up -d

compose-stop: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE='' \
	PORT_FLAG_DEV=${PORT_FLAG_DEV} \
	PORT_FLAG_DBDEV=${PORT_FLAG_DBDEV} \
	PORT_FLAG_PROD=${PORT_FLAG_PROD} \
	PORT_FLAG_DEMO=${PORT_FLAG_DEMO} \
	VERSION=${VERSION} \
	VERSION_PORT=${VERSION_PORT} \
	HOSTNAME=${HOSTNAME} \
	HOSTNAME_PATH=${HOSTNAME_PATH} \
	URL_DEV=${URL_DEV} \
	URL_DEMO=${URL_DEMO} \
	URL_PROD=${URL_PROD} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		stop

compose-down: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE='' \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		down

compose-down--volumes: feedback
	@CONTAINER_BASENAME=${CONTAINER_BASENAME} \
	SOURCE='' \
	VERSION=${VERSION} \
	docker compose \
		-p ${PROJECT_BASENAME}-${TARGET} \
		-f projects/${TARGET}.yml \
		down --volumes

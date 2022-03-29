# Default arguments
PROJECT ?= dev
VERSION ?= 4.0
DOCKER_USER ?= www-data
PHP ?= 8.1
SOURCE ?= ~/git/chevereto/v4
# Port
FLAG_PROD = 1
FLAG_DEMO = 2
FLAG_DEV_DB = 3
FLAG_DEV = 4
VERSION_DOTLESS = $(shell echo \${VERSION} | tr -d '.')
PHP_DOTLESS = $(shell echo \${PHP} | tr -d '.')
VERSION_PORT = ${VERSION_DOTLESS}${PHP_DOTLESS}
# License ask
LICENSE ?= $(shell stty -echo; read -p "License key: " license; stty echo; echo $$license)
# Echo doing
FEEDBACK = $(shell echo 👉 V\${VERSION} \${PROJECT} [PHP \${PHP}] \(\${DOCKER_USER}\))
FEEDBACK_SHORT = $(shell echo 👉 V\${VERSION} [PHP \${PHP}] \(\${DOCKER_USER}\))

build:
	@echo "${FEEDBACK_SHORT}"
	@docker build . \
		-f chevereto/${VERSION}/Dockerfile \
		--build-arg PHP=${PHP} \
		-t ghcr.io/chevereto/docker:${VERSION}-php${PHP}

pull:
	@echo "${FEEDBACK_SHORT}"
	@docker pull ghcr.io/chevereto/docker:${VERSION}-php${PHP}

bash: arguments
	@docker exec -it --user ${DOCKER_USER} \
		chevereto${VERSION}-${PROJECT}-php${PHP} \
		bash

prod: down--volumes
	@SOURCE=$(SOURCE) \
	FLAG_PROD=$(FLAG_PROD) \
	LICENSE=$(LICENSE) \
	PHP_DOTLESS=$(PHP_DOTLESS) \
	PHP=$(PHP) \
	PROJECT=prod \
	VERSION_DOTLESS=$(VERSION_DOTLESS) \
	VERSION=$(VERSION) \
		docker-compose \
			-p chevereto${VERSION_DOTLESS}-prod-php${PHP_DOTLESS} \
			-f projects/prod.yml \
			up -d
	@./wait.sh chevereto${VERSION}-prod-php${PHP}
	@echo "👉 http://localhost:${FLAG_PROD}${VERSION_PORT}"

demo: down--volumes
	@FLAG_DEMO=$(FLAG_DEMO) \
	LICENSE=$(LICENSE) \
	PHP_DOTLESS=$(PHP_DOTLESS) \
	PHP=$(PHP) \
	PROJECT=demo \
	VERSION_DOTLESS=$(VERSION_DOTLESS) \
	VERSION=$(VERSION) \
		docker-compose \
			-p chevereto${VERSION_DOTLESS}-demo-php${PHP_DOTLESS} \
			-f projects/demo.yml \
			up -d
	@./wait.sh chevereto${VERSION}-demo-php${PHP}
	@docker exec -it --user ${DOCKER_USER} \
		chevereto${VERSION}-demo-php${PHP} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@docker exec -it \
    	chevereto${VERSION}-demo-php${PHP} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${DOCKER_USER} \
		-it chevereto${VERSION}-demo-php${PHP} \
		app/bin/legacy -C importing
	@echo "👉 admin:password http://localhost:${FLAG_DEMO}${VERSION_PORT}"

dev: down--volumes
	@SOURCE=$(SOURCE) \
	FLAG_DEV_DB=$(FLAG_DEV_DB) \
	FLAG_DEV=$(FLAG_DEV) \
	PHP_DOTLESS=$(PHP_DOTLESS) \
	PHP=$(PHP) \
	PROJECT=dev \
	VERSION_DOTLESS=$(VERSION_DOTLESS) \
	VERSION=$(VERSION) \
		docker-compose \
			-p chevereto${VERSION_DOTLESS}-dev-php${PHP_DOTLESS} \
			-f projects/dev.yml \
			up -d
	@./wait.sh chevereto${VERSION}-dev-php${PHP}
	@docker exec -it \
		chevereto${VERSION}-dev-php${PHP} \
		bash /var/scripts/sync.sh
	@docker exec --user ${DOCKER_USER} -it \
		chevereto${VERSION}-dev-php${PHP} \
		composer dump-autoload \
			--working-dir app \
			--classmap-authoritative
	@docker exec -it --user ${DOCKER_USER} \
		chevereto${VERSION}-dev-php${PHP} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--demo: arguments
	@docker exec -it \
    	chevereto${VERSION}-dev-php${PHP} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${DOCKER_USER} \
		-it chevereto${VERSION}-dev-php${PHP} \
		app/bin/legacy -C importing
	@echo "👉 http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--composer: arguments
	@docker exec -it --user ${DOCKER_USER} \
		chevereto${VERSION}-dev-php${PHP} \
		composer ${run} \
			--working-dir app \
			--ignore-platform-reqs

dev--sh: arguments
	@docker exec -it \
		chevereto${VERSION}-dev-php${PHP} \
		bash /var/scripts/${run}.sh

log-error: arguments
	@docker logs chevereto${VERSION}-${PROJECT}-php${PHP} -f 1>/dev/null

log-access: arguments
	@docker logs chevereto${VERSION}-${PROJECT}-php${PHP} -f 2>/dev/null

up: arguments
	@SOURCE=$(SOURCE) docker-compose \
		-p chevereto${VERSION_DOTLESS}-${PROJECT}-php${PHP_DOTLESS} \
		-f projects/${PROJECT}.yml \
		up

up--d: arguments
	@SOURCE=$(SOURCE) docker-compose \
		-p chevereto${VERSION_DOTLESS}-${PROJECT}-php${PHP_DOTLESS} \
		-f projects/${PROJECT}.yml \
		up -d

stop: arguments
	@SOURCE='' docker-compose \
		-p chevereto${VERSION_DOTLESS}-${PROJECT}-php${PHP_DOTLESS} \
		-f projects/${PROJECT}.yml \
		stop

down: arguments
	@SOURCE='' docker-compose \
		-p chevereto${VERSION_DOTLESS}-${PROJECT}-php${PHP_DOTLESS} \
		-f projects/${PROJECT}.yml \
		down

down--volumes: arguments
	@SOURCE='' docker-compose \
		-p chevereto${VERSION_DOTLESS}-${PROJECT}-php${PHP_DOTLESS} \
		-f projects/${PROJECT}.yml \
		down --volumes

build-httpd: 
	@echo "👉 Downloading source httpd.conf"
	@docker run --rm httpd:2.4 cat /usr/local/apache2/conf/httpd.conf > httpd.conf
	@echo "👉 Adding chevereto.conf to httpd.conf"
	@cat chevereto.conf >> httpd.conf
	@echo "✅ httpd.conf updated"

arguments:
	@echo "${FEEDBACK}"
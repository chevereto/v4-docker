# Default arguments
project ?= dev
version ?= 4.0
user ?= www-data
php ?= 8.1

# Ports
FLAG_PROD = 1
FLAG_DEMO = 2
FLAG_DEV = 4
VERSION_PORT = $(shell echo \${version}\${php} | tr -d '.')

# License ask
LICENSE ?= $(shell stty -echo; read -p "License key: " license; stty echo; echo $$license)

FEEDBACK = $(shell echo 👉 V\${version} \${project} [PHP \${php}] \(\${user}\))

build: arguments
	@docker build . \
    	-f php/${php}/Dockerfile \
    	-t ghcr.io/chevereto/docker:${version}-php${php}

bash: arguments
	@docker exec -it --user ${user} \
		chevereto${version}-${project}-php${php} \
		bash

prod: prod--down
	@LICENSE=$(LICENSE) docker-compose \
		-p chevereto${version}-prod-php${php} \
		-f php/${php}/prod.yml \
		up -d
	@./wait.sh chevereto${version}-prod-php${php}
	@echo "👉 http://localhost:${FLAG_PROD}${VERSION_PORT}"

prod--down: arguments
	@LICENSE="" docker-compose \
		-p chevereto${version}-prod-php${php} \
		-f php/${php}/prod.yml \
		down --volumes

demo: demo--down
	@LICENSE=$(LICENSE) docker-compose \
		-p chevereto${version}-demo-php${php} \
		-f php/${php}/demo.yml \
		up -d
	@./wait.sh chevereto${version}-demo-php${php}
	@docker exec -it --user ${user} \
		chevereto${version}-demo-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@docker exec -it \
    	chevereto${version}-demo-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${user} \
		-it chevereto${version}-demo-php${php} \
		app/bin/legacy -C importing
	@echo "👉 admin:password http://localhost:${FLAG_DEMO}${VERSION_PORT}"

demo--down: arguments
	@LICENSE="" docker-compose \
		-p chevereto${version}-demo-php${php} \
		-f php/${php}/demo.yml \
		down --volumes

dev: dev--down
	@docker-compose \
		-p chevereto${version}-dev-php${php} \
		-f php/${php}/dev.yml \
		up -d
	@./wait.sh chevereto${version}-dev-php${php}
	@docker exec -it \
		chevereto${version}-dev-php${php} \
		bash /var/scripts/sync.sh
	@docker exec --user ${user} -it \
		chevereto${version}-dev-php${php} \
		composer update --ignore-platform-reqs --working-dir app
	@docker exec -it --user ${user} \
		chevereto${version}-dev-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--down: arguments
	@docker-compose \
		-p chevereto${version}-dev-php${php} \
		-f php/${php}/dev.yml \
		down --volumes

dev--demo: arguments
	@docker exec -it \
    	chevereto${version}-dev-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${user} \
		-it chevereto${version}-dev-php${php} \
		app/bin/legacy -C importing
	@echo "👉 http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--composer: arguments
	@docker exec -it --user ${user} \
		chevereto${version}-dev-php${php} \
		composer ${run} --ignore-platform-reqs --working-dir app

dev--sh: arguments
	@docker exec -it \
		chevereto${version}-dev-php${php} \
		bash /var/scripts/${run}.sh

log-error: arguments
	@docker logs chevereto${version}-${project}-php${php} -f 1>/dev/null

log-access: arguments
	@docker logs chevereto${version}-${project}-php${php} -f 2>/dev/null

arguments:
	@echo "${FEEDBACK}"
# Default arguments
project ?= dev
version ?= 4.0
user ?= www-data
php ?= 8.1
source ?= ~/git/chevereto/v4
# Port
FLAG_PROD = 1
FLAG_DEMO = 2
FLAG_DEV = 4
VERSION_DOTLESS = $(shell echo \${version} | tr -d '.')
PHP_DOTLESS = $(shell echo \${php} | tr -d '.')
VERSION_PORT = ${VERSION_DOTLESS}${PHP_DOTLESS}
# License ask
LICENSE ?= $(shell stty -echo; read -p "License key: " license; stty echo; echo $$license)
# Echo doing
FEEDBACK = $(shell echo 👉 V\${version} \${project} [PHP \${php}] \(\${user}\))
FEEDBACK_SHORT = $(shell echo 👉 V\${version} [PHP \${php}] \(\${user}\))

build:
	@echo "${FEEDBACK_SHORT}"
	@docker build . \
    	-f php/${php}/Dockerfile \
    	-t ghcr.io/chevereto/docker:${version}-php${php}

bash: arguments
	@docker exec -it --user ${user} \
		chevereto${version}-${project}-php${php} \
		bash

prod: prod--down
	@LICENSE=$(LICENSE) docker-compose \
		-p chevereto${VERSION_DOTLESS}-prod-php${PHP_DOTLESS} \
		-f php/${php}/prod.yml \
		up -d
	@./wait.sh chevereto${version}-prod-php${php}
	@echo "👉 http://localhost:${FLAG_PROD}${VERSION_PORT}"

prod--down: arguments
	@LICENSE="" docker-compose \
		-p chevereto${VERSION_DOTLESS}-prod-php${PHP_DOTLESS} \
		-f php/${php}/prod.yml \
		down --volumes

demo: demo--down
	@LICENSE=$(LICENSE) docker-compose \
		-p chevereto${VERSION_DOTLESS}-demo-php${PHP_DOTLESS} \
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
		-p chevereto${VERSION_DOTLESS}-demo-php${PHP_DOTLESS} \
		-f php/${php}/demo.yml \
		down --volumes

dev: dev--down
	@SOURCE=$(source) docker-compose \
		-p chevereto${VERSION_DOTLESS}-dev-php${PHP_DOTLESS} \
		-f php/${php}/dev.yml \
		up -d
	@./wait.sh chevereto${version}-dev-php${php}
	@docker exec -it \
		chevereto${version}-dev-php${php} \
		bash /var/scripts/sync.sh
	@docker exec --user ${user} -it \
		chevereto${version}-dev-php${php} \
		composer update \
			--working-dir app \
			--ignore-platform-reqs 
	@docker exec -it --user ${user} \
		chevereto${version}-dev-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--down: arguments
	@SOURCE='' docker-compose \
		-p chevereto${VERSION_DOTLESS}-dev-php${PHP_DOTLESS} \
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
		composer ${run} \
			--working-dir app \
			--ignore-platform-reqs

dev--sh: arguments
	@docker exec -it \
		chevereto${version}-dev-php${php} \
		bash /var/scripts/${run}.sh

log-error: arguments
	@docker logs chevereto${version}-${project}-php${php} -f 1>/dev/null

log-access: arguments
	@docker logs chevereto${version}-${project}-php${php} -f 2>/dev/null

source--httpd: 
	@echo "👉 Downloading source httpd.conf"
	@docker run --rm httpd:2.4 cat /usr/local/apache2/conf/httpd.conf > httpd.conf
	@echo "👉 Adding chevereto.conf to httpd.conf"
	@cat chevereto.conf >> httpd.conf
	@echo "✅ httpd.conf updated"

arguments:
	@echo "${FEEDBACK}"
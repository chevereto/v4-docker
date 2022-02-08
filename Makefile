# Default arguments
p ?= dev
v ?= 4.0
u ?= www-data
php ?= 8.0

# Ports
FLAG_PROD = 1
FLAG_DEMO = 2
FLAG_DEV = 4
VERSION_PORT = $(shell echo \${v}\${php} | tr -d '.')

# License ask
LICENSE ?= $(shell stty -echo; read -p "License key: " license; stty echo; echo $$license)

FEEDBACK = $(shell echo 👉 V\${v} \${p} [PHP \${php}] \(\${u}\))

bash: arguments
	@docker exec -it --user ${u} \
		chevereto${v}-${p}-php${php} \
		bash

prod: prod--down
	@LICENSE=$(LICENSE) docker-compose \
		-p chevereto${v}-prod-php${php} \
		-f php/${php}/prod.yml \
		up -d
	@./wait.sh chevereto${v}-prod-php${php}
	@echo "👉 http://localhost:${FLAG_PROD}${VERSION_PORT}"

prod--down: arguments
	@LICENSE="" docker-compose \
		-p chevereto${v}-prod-php${php} \
		-f php/${php}/prod.yml \
		down --volumes

demo: demo--down
	@LICENSE=$(LICENSE) docker-compose \
		-p chevereto${v}-demo-php${php} \
		-f php/${php}/demo.yml \
		up -d
	@./wait.sh chevereto${v}-demo-php${php}
	@docker exec -it --user ${u} \
		chevereto${v}-demo-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@docker exec -it \
    	chevereto${v}-demo-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${u} \
		-it chevereto${v}-demo-php${php} \
		app/bin/legacy -C importing
	@echo "👉 admin:password http://localhost:${FLAG_DEMO}${VERSION_PORT}"

demo--down: arguments
	@LICENSE="" docker-compose \
		-p chevereto${v}-demo-php${php} \
		-f php/${php}/demo.yml \
		down --volumes

dev: dev--down
	@docker-compose \
		-p chevereto${v}-dev-php${php} \
		-f php/${php}/dev.yml \
		up -d
	@./wait.sh chevereto${v}-dev-php${php}
	@docker exec -it \
		chevereto${v}-dev-php${php} \
		bash /var/scripts/sync.sh
	@docker exec --user ${u} -it \
		chevereto${v}-dev-php${php} \
		composer update --ignore-platform-reqs
	@docker exec -it --user ${u} \
		chevereto${v}-dev-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--down: arguments
	@docker-compose \
		-p chevereto${v}-dev-php${php} \
		-f php/${php}/dev.yml \
		down --volumes

dev--demo: arguments
	@docker exec -it \
    	chevereto${v}-dev-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user ${u} \
		-it chevereto${v}-dev-php${php} \
		app/bin/legacy -C importing
	@echo "👉 http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--composer: arguments
	@docker exec -it --user ${u} \
		chevereto${v}-dev-php${php} \
		composer ${run} --ignore-platform-reqs

dev--sh: arguments
	@docker exec -it \
		chevereto${v}-dev-php${php} \
		bash /var/scripts/${run}.sh

log-error: arguments
	@docker logs chevereto${v}-${p}-php${php} -f 1>/dev/null

log-access: arguments
	@docker logs chevereto${v}-${p}-php${php} -f 2>/dev/null

arguments:
	@echo "${FEEDBACK}"
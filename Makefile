FLAG_PROD = 1
FLAG_DEMO = 2
FLAG_DEV = 4
VERSION_PORT=$(shell echo \${version}\${php} | tr -d '.')

prod:
	@docker-compose \
		-p chevereto${version}-prod-php${php} \
		-f php/${php}/prod.yml \
		down --volumes
	@docker-compose \
		-p chevereto${version}-prod-php${php} \
		-f php/${php}/prod.yml \
		up -d
	@./wait.sh chevereto${version}-prod-php${php}
	@docker exec -it --user www-data \
		chevereto${version}-prod-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_PROD}${VERSION_PORT}"

prod--demo:
	@docker exec -it \
    	chevereto${version}-prod-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user www-data \
		-it chevereto${version}-prod-php${php} \
		app/bin/legacy -C importing
	@echo "👉 http://localhost:${FLAG_PROD}${VERSION_PORT}"

demo:
	@docker-compose \
		-p chevereto${version}-demo-php${php} \
		-f php/${php}/demo.yml \
		down --volumes
	@docker-compose \
		-p chevereto${version}-demo-php${php} \
		-f php/${php}/demo.yml \
		up -d
	@./wait.sh chevereto${version}-demo-php${php}
	@docker exec -it --user www-data \
		chevereto${version}-demo-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@docker exec -it \
    	chevereto${version}-demo-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user www-data \
		-it chevereto${version}-demo-php${php} \
		app/bin/legacy -C importing
	@echo "👉 admin:password http://localhost:${FLAG_DEMO}${VERSION_PORT}"

dev:
	@docker-compose \
		-p chevereto${version}-dev-php${php} \
		-f php/${php}/dev.yml \
		down --volumes
	@docker-compose \
		-p chevereto${version}-dev-php${php} \
		-f php/${php}/dev.yml \
		up -d
	@./wait.sh chevereto${version}-dev-php${php}
	@docker exec -it \
		chevereto${version}-dev-php${php} \
		bash /var/scripts/sync.sh
	@docker exec --user www-data -it \
		chevereto${version}-dev-php${php} \
		composer update --ignore-platform-reqs
	@docker exec -it --user www-data \
		chevereto${version}-dev-php${php} \
		app/bin/legacy -C install \
			-u admin \
			-e admin@chevereto.loc \
			-x password
	@echo "👉 admin:password http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--demo:
	@docker exec -it \
    	chevereto${version}-dev-php${php} \
    	bash /var/scripts/demo-importing.sh
	@docker exec --user www-data \
		-it chevereto${version}-dev-php${php} \
		app/bin/legacy -C importing
	@echo "👉 http://localhost:${FLAG_DEV}${VERSION_PORT}"

dev--cmd:
	@docker exec -it \
		chevereto${version}-dev-php${php} \
		bash /var/scripts/${run}.sh
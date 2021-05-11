#!/usr/bin/env bash
echo "Build Chevereto dev [httpd (mpm_prefork), mod_php] at port 8008"
echo -n "* Clean install (y/n)?"
read cleanInstall
if [ "$cleanInstall" != "${cleanInstall#[Yy]}" ]; then
    echo -n "* Create user dev:password (y/n)?"
    read createDev
fi
docker network inspect chv-network >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup Network"
    docker network create chv-network
fi
docker container inspect chv-dev >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-dev"
    docker rm -f chv-dev >/dev/null 2>&1
fi
docker container inspect chv-dev-mariadb >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-dev-mariadb"
    docker rm -f chv-dev-mariadb >/dev/null 2>&1
fi
echo "* Provide MariaDB Server"
if [ "$cleanInstall" != "${cleanInstall#[Yy]}" ]; then
    echo "* Remove existing database at /var/www/html/chevereto.loc/database/*"
    sudo rm -rf /var/www/html/chevereto.loc/database/*
fi
docker run -d \
    -e MYSQL_ROOT_PASSWORD=password \
    --name chv-dev-mariadb \
    --network chv-network \
    --network-alias dev-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    --mount src="/var/www/html/chevereto.loc/database",target=/var/lib/mysql,type=bind \
    mariadb:focal >/dev/null 2>&1
printf "* Starting mysqld"
while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-dev-mariadb) != "\"healthy\"" ]; do
    printf "."
    sleep 1
done
echo ""
docker exec -it chv-dev-mariadb test -d /var/lib/mysql/chevereto
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup database"
    docker exec chv-dev-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
fi
SOFTWARE="Chevereto Source"
echo "* Provide v3-httpd-php"
docker run -d \
    -p 8008:80 \
    -e "CHEVERETO_DB_HOST=dev-mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_TABLE_PREFIX=chv_" \
    -e "CHEVERETO_DB_PORT=3306" \
    -e "CHEVERETO_DB_DRIVER=mysql" \
    -e "CHEVERETO_UPLOAD_MAX_FILESIZE=25M" \
    -e "CHEVERETO_POST_MAX_SIZE=25M" \
    -e "CHEVERETO_MAX_EXECUTION_TIME=30" \
    -e "CHEVERETO_MEMORY_LIMIT=512M" \
    -e "CHEVERETO_DEBUG_LEVEL=1" \
    --name chv-dev \
    --network chv-network \
    --network-alias dev \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto/servicing:v3-httpd-php >/dev/null 2>&1
echo '* Applying permissions'
docker exec -it chv-dev bash -c "chown www-data: . -R"
if [ "$createDev" != "${createDev#[Yy]}" ]; then
    echo "* Creating dev:password"
    docker exec -d chv-dev \
        curl -X POST http://localhost:80/install \
        --data "username=dev" \
        --data "email=dev@chevereto.loc" \
        --data "password=password" \
        --data "email_from_email=dev@chevereto.loc" \
        --data "email_incoming_email=dev@chevereto.loc" \
        --data "website_mode=community" >/dev/null 2>&1
fi
echo "[OK] $SOFTWARE is running at localhost:8008"
echo "-------------------------------------------"
echo "All done!"
echo "- Front http://localhost:8008"
echo "- Dashboard http://localhost:8008/dashboard"
if [ "$createDev" != "${createDev#[Yy]}" ]; then
    echo "(username dev)"
    echo "(password password)"
fi

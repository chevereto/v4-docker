#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT="$(dirname $DIR)"
SOFTWARE="chevereto-dev"
PORT="8008"
DB_DIR="$PROJECT/build/database/dev"
echo "Build Chevereto dev [httpd (mpm_prefork), mod_php] at port $PORT"
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
echo "* Need to create $DB_DIR"
mkdir -p $DB_DIR
docker container inspect chv-dev-mariadb >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-dev-mariadb"
    docker rm -f chv-dev-mariadb >/dev/null 2>&1
fi
echo "* Provide MariaDB Server"
if [ "$cleanInstall" != "${cleanInstall#[Yy]}" ]; then
    echo "* Remove existing database at $DB_DIR/*"
    sudo rm -rf $DB_DIR/*
fi
docker run -d \
    -e MYSQL_ROOT_PASSWORD=password \
    --name chv-dev-mariadb \
    --network chv-network \
    --network-alias dev-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    --mount src="$DB_DIR",target=/var/lib/mysql,type=bind \
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
echo "* Provide v3-httpd-php"
docker run -d \
    -p "$PORT:80" \
    -e "CHEVERETO_DB_HOST=dev-mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_TAG=dev" \
    --name chv-dev \
    --network chv-network \
    --network-alias dev \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing",target=/var/www/html/importing,type=bind \
    chevereto/chevereto:latest-httpd-php >/dev/null 2>&1
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
echo "[OK] $SOFTWARE is running at localhost:$PORT"
echo "-------------------------------------------"
echo "All done!"
echo "- Front http://localhost:8008"
echo "- Dashboard http://localhost:8008/dashboard"
if [ "$createDev" != "${createDev#[Yy]}" ]; then
    echo "(username dev)"
    echo "(password password)"
fi

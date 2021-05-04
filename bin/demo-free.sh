#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT="$(dirname $DIR)"
SOFTWARE="Chevereto-Free"
PORT="8002"
DB_DIR="$PROJECT/build/database/demo-free"
mkdir -p $DB_DIR
RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi
echo "Build $SOFTWARE [httpd (mpm_prefork), mod_php] at port $PORT"
echo "* Building v3-demo image"
docker build -t chevereto:v3-demo "$PROJECT/"demo >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi
docker network inspect chv-network >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup chv-network network"
    docker network create chv-network
fi
docker container inspect chv-demo-free >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-demo-free"
    docker rm -f chv-demo-free >/dev/null 2>&1
fi
docker container inspect chv-demo-free-mariadb >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-demo-free-mariadb"
    docker rm -f chv-demo-free-mariadb >/dev/null 2>&1
fi
echo "* Provide MariaDB Server"
docker run -d \
    --name chv-demo-free-mariadb \
    --network chv-network \
    --network-alias chv-demo-free-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    --mount src="$DB_DIR",target=/var/lib/mysql,type=bind \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal >/dev/null 2>&1
printf "* Starting mysqld"
while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-demo-free-mariadb) != "\"healthy\"" ]; do
    printf "."
    sleep 1
done
echo ""
docker exec -it chv-demo-free-mariadb test -d /var/lib/mysql/chevereto
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup database"
    docker exec chv-demo-free-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
fi
echo "* Provide chv-demo-free"
docker run -d \
    --name chv-demo-free \
    --network chv-network \
    -e "CHEVERETO_DB_HOST=chv-demo-free-mariadb" \
    -p "$PORT:80" \
    chevereto:v3-demo >/dev/null 2>&1
echo "* Creating demo:password"
docker exec -d chv-demo-free \
    curl -X POST http://localhost:80/install \
    --data "username=demo" \
    --data "email=demo@chevereto.loc" \
    --data "password=password" \
    --data "email_from_email=no-reply@chevereto.loc" \
    --data "email_incoming_email=inbox@chevereto.loc" \
    --data "website_mode=community" >/dev/null 2>&1
echo "[OK] $SOFTWARE is running at localhost:$PORT"
echo "* About to import demo data"
sleep 2
count=4
for i in $(seq $count); do
    echo '...'
    docker exec -it \
        --user www-data \
        -e IS_CRON=1 \
        -e THREAD_ID=1 \
        chv-demo-free /usr/local/bin/php /var/www/html/importing.php
done
echo "-------------------------------------------"
echo "All done!"
echo "- Front http://localhost:$PORT"
echo "- Dashboard http://localhost:$PORT/dashboard"
echo "(username demo)"
echo "(password password)"

#!/usr/bin/env bash
# set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT="$(dirname $DIR)"
SOFTWARE="Chevereto"
PORT="8001"
DB_DIR="$PROJECT/build/database/demo"
echo "Build $SOFTWARE [httpd (mpm_prefork), mod_php] at port $PORT"
echo "* Pull chevereto/chevereto:latest-httpd-php"
docker pull chevereto/chevereto:latest-httpd-php
docker network inspect chv-network >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup chv-network network"
    docker network create chv-network
fi
docker container inspect chv-demo >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-demo"
    docker rm -f chv-demo >/dev/null 2>&1
fi
if [ -d "$DB_DIR" ]; then
    echo "* Need to remove $DB_DIR"
    rm -rf $DB_DIR
fi
echo "* Need to create $DB_DIR"
mkdir -p $DB_DIR
docker container inspect chv-demo-mariadb >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-demo-mariadb"
    docker rm -f chv-demo-mariadb >/dev/null 2>&1
fi
echo "* Provide MariaDB Server"
docker run -d \
    --name chv-demo-mariadb \
    --network chv-network \
    --network-alias chv-demo-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    --mount src="$DB_DIR",target=/var/lib/mysql,type=bind \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal >/dev/null 2>&1
printf "* Starting mysqld"
while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-demo-mariadb) != "\"healthy\"" ]; do
    printf "."
    sleep 1
done
echo ""
docker exec -it chv-demo-mariadb test -d /var/lib/mysql/chevereto
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup database"
    docker exec chv-demo-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
fi
echo "* Provide chv-demo"
echo -n "* $SOFTWARE key:"
read -s license
echo
docker run -it \
    -p "$PORT:80" \
    -e "CHEVERETO_DB_HOST=chv-demo-mariadb" \
    -e "CHEVERETO_SOFTWARE=chevereto" \
    -e "CHEVERETO_TAG=latest" \
    -e "CHEVERETO_LICENSE=$license" \
    --name chv-demo \
    --network chv-network \
    chevereto/chevereto:latest-httpd-php
sleep 45
echo "* Creating demo:password"
docker exec -it \
    --user www-data \
    -e THREAD_ID=1 \
    chv-demo /usr/local/bin/php /var/www/html/cli.php -C install \
    -u demo \
    -e demo@chevereto.loc \
    -x password
echo "[OK] $SOFTWARE is running at localhost:$PORT"
docker exec chv-demo-free mkdir -p /var/www/html/importing
docker exec chv-demo-free curl -S -o /var/www/html/importing/importing.tar.gz -L 'https://codeload.github.com/chevereto/demo-importing/tar.gz/refs/heads/main'
docker exec chv-demo-free tar -xvzf /var/www/html/importing/importing.tar.gz -C /var/www/html/importing/
docker exec chv-demo-free sh -c "mv /var/www/html/importing/demo-importing-main/no-parse/* /var/www/html/importing/no-parse"
docker exec chv-demo-free sh -c "mv /var/www/html/importing/demo-importing-main/parse-albums/* /var/www/html/importing/parse-albums"
docker exec chv-demo-free sh -c "mv /var/www/html/importing/demo-importing-main/parse-users/* /var/www/html/importing/parse-users"
docker exec chv-demo-free rm -rf /var/www/html/importing/demo-importing-main
docker exec chv-demo-free sh -c "chown www-data: /var/www/html -R"
echo "* About to import demo data"
sleep 2
count=4
for i in $(seq $count); do
    echo '...'
    docker exec -it \
        --user www-data \
        -e THREAD_ID=1 \
        chv-demo /usr/local/bin/php /var/www/html/cli.php -C importing
done
echo "-------------------------------------------"
echo "All done!"
echo "- Front http://localhost:$PORT"
echo "- Dashboard http://localhost:$PORT/dashboard"
echo "(username demo)"
echo "(password password)"

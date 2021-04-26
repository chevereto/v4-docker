#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT="$(dirname $DIR)"
SOFTWARE="Chevereto"
PORT="8002"
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
docker container inspect chv-demo >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "* Removing existing chv-demo"
    docker rm -f chv-demo >/dev/null 2>&1
fi
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
    --mount src="/var/www/html/chevereto.loc/database/demo",target=/var/lib/mysql,type=bind \
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
docker run -d \
    --name chv-demo \
    --network chv-network \
    -e "CHEVERETO_DB_HOST=chv-demo-mariadb" \
    -p "$PORT:80" \
    chevereto:v3-demo >/dev/null 2>&1
echo -n "* $SOFTWARE key:"
read -s license
echo
docker exec -it \
    --user www-data \
    chv-demo php installer.php -a download -s chevereto -l=$license
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo '[OK] License valid'
else
    echo "Not a valid license key. Go to http://chv.to/pricing if you haven't one already"
    exit 1
fi
echo "* Installing paid edition"
docker exec -it \
    --user www-data \
    chv-demo bash -c "php installer.php -a extract -s chevereto -p /var/www/html -f chevereto-pkg-*.zip"
echo "* Creating demo:password"
docker exec -it \
    --user www-data \
    -e THREAD_ID=1 \
    chv-demo /usr/local/bin/php /var/www/html/cli.php -C install \
    -u demo \
    -e demo@chevereto.loc \
    -x password
echo "[OK] $SOFTWARE is running at localhost:$PORT"
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

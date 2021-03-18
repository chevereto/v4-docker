# !/usr/bin/bash
echo "Build Chevereto demo at port 8001"
docker network inspect chv-network >/dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup Network"
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
docker run -d --name chv-demo-mariadb \
    --network chv-network \
    --network-alias demo-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal >/dev/null 2>&1
echo "* Waiting for mysqld"
while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-demo-mariadb) != "\"healthy\"" ]; do
    printf "."
    sleep 1
done
echo "\n"
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
    -p 8001:80 \
    chevereto:v3-demo >/dev/null 2>&1
echo "* Creating demo:password user credentials"
docker exec -d chv-demo \
    curl -X POST http://localhost:80/install \
    --data "username=demo" \
    --data "email=demo@chevereto.loc" \
    --data "password=password" \
    --data "email_from_email=demo@chevereto.loc" \
    --data "email_incoming_email=demo@chevereto.loc" \
    --data "website_mode=community" >/dev/null 2>&1
echo "\n💯 Done! Chevereto is running at localhost:8001\n"
echo "Front http://localhost:8001"
echo "Dashboard http://localhost:8001/dashboard"
echo "Username demo"
echo "Password password"
# !/usr/bin/bash

docker rm chv-demo -f
docker build -t chevereto:v3-demo demo

# echo "✨ Setup Network"

# docker network create chv-network

echo "✨ Removing any existing container"

# docker rm -f -v chv-demo
# docker rm -f -v chv-demo chv-demo-mariadb

# echo "✨ Run MariaDB Server"

# docker run -d --name chv-demo-mariadb \
#     --network chv-network \
#     --network-alias demo-mariadb \
#     --health-cmd='mysqladmin ping --silent' \
#     -e MYSQL_ROOT_PASSWORD=password \
#     mariadb:focal

# echo "✨ Waiting for mysqld"

# while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-demo-mariadb) != "\"healthy\"" ]; do
#     printf "."
#     sleep 1
# done

# echo "\n"

# docker exec -it chv-demo-mariadb test -d /var/lib/mysql/chevereto

# RESULT=$?

# if [ $RESULT -eq 1 ]; then
#     echo "✨ Database Setup"
#     docker exec chv-demo-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto;"
#     docker exec chv-demo-mariadb mysql -uroot -ppassword -e "CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password';"
#     docker exec chv-demo-mariadb mysql -uroot -ppassword -e "GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
# fi

echo "✨ Web Server & PHP Setup"

docker run -d \
    --name chv-demo \
    --network chv-network \
    -p 8001:80 \
    chevereto:v3-demo

echo "✨ Creating demo:password user credentials"

docker exec -d chv-demo \
    curl -X POST http://localhost:80/install \
    --data "username=demo" \
    --data "email=demo@chevereto.loc" \
    --data "password=password" \
    --data "email_from_email=demo@chevereto.loc" \
    --data "email_incoming_email=demo@chevereto.loc" \
    --data "website_mode=community"

echo "\n💯 Done! Chevereto is running at http://localhost:8001"

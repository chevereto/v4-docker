# !/usr/bin/bash

docker rm chv-mariadb -f
docker run -it \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal

# --mount src="/var/www/html/chevereto.loc/database",target=/var/lib/mysql,type=bind \
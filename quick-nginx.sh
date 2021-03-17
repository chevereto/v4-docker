# !/usr/bin/bash

echo "✨ Setup Network"

docker network create chv-network

echo "✨ Removing any existing container"

docker rm -f -v chv-php chv-nginx chv-mariadb

echo "✨ Run MariaDB Server"

docker run -itd \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal

echo "✨ Waiting for mysqld"

while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-mariadb) != "\"healthy\"" ]; do
    printf "."
    sleep 1
done

echo "\n"

docker exec -it chv-mariadb test -d /var/lib/mysql/chevereto

RESULT=$?

if [ $RESULT -eq 1 ]; then
    echo "✨ Database Setup"
    docker exec -it chv-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto;"
    docker exec -it chv-mariadb mysql -uroot -ppassword -e "CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password';"
    docker exec -it chv-mariadb mysql -uroot -ppassword -e "GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
fi

echo "✨ PHP Setup"

docker run -itd \
    --name chv-php \
    --network chv-network \
    --network-alias php \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    chevereto:v3-php-fpm

echo "✨ Nginx Setup"

docker run -itd \
    --name chv-nginx \
    --network chv-network \
    --network-alias webserver \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    -p 8000:80 \
    chevereto:v3-nginx

echo '✨ Applying permissions'

docker exec -it chv-php bash -c "chown www-data: . -R"

echo "\n💯 Done! Chevereto is at http://localhost:8000"

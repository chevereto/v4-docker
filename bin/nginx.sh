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
    echo "* Setup database"
    docker exec chv-demo-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
fi

echo "✨ PHP Setup"

docker run -itd \
    --name chv-php \
    --network chv-network \
    --network-alias php \
    -p 4430:443 -p 8000:80 \
    -e "CHEVERETO_DB_HOST=mariadb" \
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
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
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

docker exec -it chv-php-fpm bash -c "chown www-data: * -R"

echo "\n💯 Done! Chevereto is at http://localhost:8000"

#!/usr/bin/bash
echo "Build Chevereto [httpd (mpm_event), php-fpm] at port 8000"
docker rm chv-php-fpm chv-httpd -f
docker network inspect chv-network
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup Network"
    docker network create chv-network
fi
docker container inspect chv-mariadb
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Provide MariaDB Server"
    docker run -d \
        --name chv-mariadb \
        --network chv-network \
        --network-alias mariadb \
        --health-cmd='mysqladmin ping --silent' \
        -e MYSQL_ROOT_PASSWORD=password \
        --mount src="/var/www/html/chevereto.loc/database",target=/var/lib/mysql,type=bind \
        mariadb:focal
    echo "* Waiting for mysqld"
    while [ $(docker inspect --format "{{json .State.Health.Status }}" chv-mariadb) != "\"healthy\"" ]; do
        printf "."
        sleep 1
    done
    echo "\n"
else
    docker start chv-mariadb
fi
docker exec -it chv-mariadb test -d /var/lib/mysql/chevereto
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Setup database"
    docker exec chv-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
fi
docker container inspect chv-php-fpm
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Provide PHP-FPM"
    docker run -d \
        --name chv-php-fpm \
        --network chv-network \
        --network-alias php \
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
else
    docker start chv-php-fpm
fi
docker container inspect chv-httpd
RESULT=$?
if [ $RESULT -eq 1 ]; then
    echo "* Provide Apache HTTP Server"
    docker run -d \
        --name chv-httpd \
        --network chv-network \
        --network-alias httpd \
        --volumes-from chv-php-fpm \
        -p 8000:80 \
        chevereto:v3-httpd
else
    docker start chv-httpd
fi
echo '* Applying permissions'
docker exec -it chv-php-fpm bash -c "chown www-data: . -R"
echo "\n💯 Done! Chevereto is running at localhost:8000\n"
echo "Front http://localhost:8000"
echo "Dashboard http://localhost:8000/dashboard"

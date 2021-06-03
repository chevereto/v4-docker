docker run -d \
    -e MYSQL_ROOT_PASSWORD=password \
    --name chv-dev-mariadb \
    --network chv-network \
    --network-alias dev-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    mariadb:focal

docker exec chv-dev-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"

docker run -d \
    -p "8008:80" \
    -e "CHEVERETO_DB_HOST=dev-mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_TAG=dev" \
    -e "CHEVERETO_ASSET_STORAGE_NAME=dev-assets" \
    -e "CHEVERETO_ASSET_STORAGE_TYPE=local" \
    --name chv-dev \
    --network chv-network \
    --network-alias dev \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    chevereto/chevereto:latest-httpd-php

# !/usr/bin/bash
echo "🔸Removing any existing container"
docker rm -f chv-v3 || true
docker rm -f chv-mariadb || true

echo "🔹Run MariaDB Server"

docker run -itd \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    --mount src="/var/www/html/chevereto.loc/database",target=/var/lib/mysql,type=bind \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal

echo "🔸Database Setup"

sleep 1

docker exec -it chv-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto;
CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password;'
GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password;'
quit;"

echo "🔹Server Setup"

sleep 1

docker run -itd \
    --name chv-v3 \
    --network chv-network \
    --restart always \
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
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto:v3-docker

echo "\n✨ Chevereto is at http://localhost:8000"

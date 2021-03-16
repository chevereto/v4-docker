# !/usr/bin/bash

echo "✨ Setup Network"

docker network create chv-network

echo "✨ Removing any existing container"

docker rm -f -v chv-v3 chv-mariadb

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
    docker exec -it chv-mariadb mysql -uroot -ppassword -e "CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password;'"
    docker exec -it chv-mariadb mysql -uroot -ppassword -e "GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password;'"
fi

echo "✨ Server Setup"

docker run -itd \
    --name chv-v3 \
    --network chv-network \
    --restart always \
    -p 4430:443 -p 8000:80 \
    chevereto:v3-docker

echo '✨ Applying permissions'

docker exec -it chv-v3 bash -c "chown www-data: . -R"

echo "\n💯 Done! Chevereto is at http://localhost:8000"

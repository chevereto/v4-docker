# !/usr/bin/bash
echo "✨ Removing any existing container"
docker rm -f chv-v3 || true
docker rm -f chv-mariadb || true

echo "✨ Run MariaDB Server"

docker run -itd \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal

echo "✨ Database Setup"

sleep 1

docker exec -it chv-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto;
CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password;'
GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password;'
quit;"

echo "✨ Server Setup"

sleep 1

docker run -itd \
    --name chv-v3 \
    --network chv-network \
    --restart always \
    -p 4430:443 -p 8000:80 \
    chevereto:v3-docker

echo '✨ Applying permissions'

docker exec -it chv-v3 bash -c "chown www-data: . -R"

echo "\n💯 Chevereto is at http://localhost:8000"

docker network create chv-network
docker rm -f chv-demo chv-demo-mariadb
docker run -d --name chv-demo-mariadb --network chv-network --network-alias demo-mariadb -e MYSQL_ROOT_PASSWORD=password mariadb:focal
timeout 10
docker exec chv-demo-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
docker run -d --name chv-demo --network chv-network -p 8001:80 chevereto:v3-demo
docker exec -d chv-demo curl -X POST http://localhost:80/install --data "username=demo" --data "email=demo@chevereto.loc" --data "password=password" --data "email_from_email=demo@chevereto.loc" --data "email_incoming_email=demo@chevereto.loc" --data "website_mode=community"
PAUSE
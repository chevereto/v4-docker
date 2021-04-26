# demo

## Build

```sh
docker build -t chevereto:v3-demo . 
```

## Run

Run MariaDB Server container:

```sh
docker run -d \
    --name chv-demo-mariadb \
    --network chv-network \
    --network-alias demo-mariadb \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal
```

Setup Chevereto MariaDB demo database:

```sh
docker exec chv-demo-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
```

Run Chevereto demo website:

```sh
docker run -d \
    --name chv-demo \
    --network chv-network \
    -p 8001:80 \
    chevereto:v3-demo
```

- Front [localhost:8001](http://localhost:8001)
- Dashboard [localhost:8001/dashboard](http://localhost:8001/dashboard)

Open the website to complete the installation. This can be also made running:

```sh
docker exec -d chv-demo \
    curl -X POST http://localhost:80/install \
    --data "username=demo" \
    --data "email=demo@chevereto.loc" \
    --data "password=password" \
    --data "email_from_email=demo@chevereto.loc" \
    --data "email_incoming_email=demo@chevereto.loc" \
    --data "website_mode=community"
```

## Importing

Chevereto V3.20+

```sh
docker exec -it \
    -e THREAD_ID=1 \
    chv-demo /usr/local/bin/php /var/www/html/cli.php -C importing
```

Chevereto V3.18 - Chevereto-Free

```sh
docker exec -it \
    -e IS_CRON=1 \
    -e THREAD_ID=1 \
    chv-demo /usr/local/bin/php /var/www/html/importing.php
```

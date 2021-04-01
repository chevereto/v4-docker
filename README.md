# Docker

> 🔔 [Subscribe](https://newsletter.chevereto.com/subscription?f=PmL892XuTdfErVq763PCycJQrvZ8PYc9JbsVUttqiPV1zXt6DDtf7lhepEStqE8LhGs8922ZYmGT7CYjMH5uSx23pL6Q) to don't miss any update regarding Chevereto.

![Chevereto](LOGO.svg)

[![Discord](https://img.shields.io/discord/759137550312407050?style=flat-square)](https://chv.to/discord)

This repository is for the official [Chevereto V3](https://chevereto.com/pricing) / [Chevereto-Free](https://github.com/chevereto/chevereto-free) Docker images, providing the servicing required to run any existing or new Chevereto installation.

## What it does?

It provides the **servicing layer**.

The [Dockerfile](Dockerfile) creates a container image that setups PHP, its extensions and Apache HTTP web server for spawning any Chevereto based project. Application updates are handled directly by the application.

## Dockerfile

### `httpd-php`

The [httpd-php](https://github.com/Chevereto/docker/tree/main/httpd-php) image contains Apache HTTP web server + PHP (mod_php).

### `php-fpm`

The [php-fpm](https://github.com/Chevereto/docker/tree/main/php-fpm) image contains PHP-FPM to be used with a proxy pass server (`httpd`, `nginx`).

### `httpd`

The [httpd](https://github.com/Chevereto/docker/tree/main/nginx) image contains Apache HTTP web server that connects to the `php-fpm` container.

### `nginx`

The [httpd](https://github.com/Chevereto/docker/tree/main/nginx) image contains Apache HTTP web server that connects to the `nginx` container.

<!-- ## Setup Project

A Chevereto project could be either the [Installer](https://github.com/chevereto/installer), [Chevereto V3](https://chevereto.com/pricing) or [Chevereto-Free](https://github.com/chevereto/chevereto-free).

* The project is a folder intended to be served under an HTTP server.
* This guide assumes `/var/www/html/chevereto.loc` as project folder.

```sh
cd /var/www/html/chevereto.loc/
```

Create the volumes (if required):

```sh
mkdir {public_html,images,database}
mkdir -p importing/{no-parse,parse-albums,parse-users}
```

* The application will be at `public_html`
* Local uploads will be stored at `images`

> All these directories are for reference, you can customize the volumes at [Setup v3-docker](#setup-v3-docker).

### Installer Project (recommended)

* Download the Installer at your project's public folder:

```sh
wget -O public_html/index.php https://chevereto.com/download/file/installer
```

### Existing Project

If you already have a Chevereto project simply take note on the host path. It will be used to mount the application in the containers build using this image.

## Automatic Setup

TODO.

## Manual Setup

### Setup `chv-network`

Create the `chv-network` that containers will use to communicate each other.

```sh
docker network create chv-network
```

### Setup `chv-mariadb`

* Create the `chv-mariadb` container, mounting the database to the target data store destination and connected to `chv-network`.

```sh
docker run -itd \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    --mount src="/var/www/html/chevereto.loc/database",target=/var/lib/mysql,type=bind \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal
```

Alternatively, run MariaDB without mounting the storage path:

```sh
docker run -itd \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal
```

**Note:** Use your own password at `password`.

* Enter the `chv-mariadb` container SQL console:

```sh
docker exec -it chv-mariadb mysql -uroot -p
```

Then create the `chevereto` database and its user binding.

```sql
CREATE DATABASE chevereto;
CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password';
GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';
quit
```

**Note:** Use your own password at `user_database_password`.

* Secure MariaDB installation:

```sh
docker exec -it chv-mariadb mysql_secure_installation
```

Answer wisely:

```sh
Switch to unix_socket authentication [Y/n] n
Change the root password? [Y/n] (up to you?)
Remove anonymous users? [Y/n] y
Disallow root login remotely? [Y/n] y
Remove test database and access to it? [Y/n] y
Reload privilege tables now? [Y/n] y
```

### Setup `chv-php`

Uses the `chevereto:v3-php-fpm` Dockerfile image.

```sh
docker run -it \
    --name chv-php \
    --network chv-network \
    --network-alias php \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    chevereto:v3-php-fpm
```

### Setup `chv-nginx`

Uses the `chevereto:v3-nginx` Dockerfile image.

```sh
docker run -it \
    --name chv-nginx \
    --network chv-network \
    --network-alias webserver \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    -p 8000:80 \
    chevereto:v3-nginx
```

### Setup `v3-docker`

Short command:

```sh
docker run -itd \
    --name chv-v3 \
    --network chv-network \
    --network-alias chevereto \
    --restart always \
    -p 4430:443 -p 8000:80 \
    --mount src="/var/www/html/chevereto.loc/installer",target=/var/www/html,type=bind \
    chevereto:v3-docker
```

Port mapping:

```sh
    -p 443:443 -p 80:80 \
```

Full command:

```sh
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
    -e "CHEVERETO_DEBUG_LEVEL=1" \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto:v3-docker
```

* [localhost:8000](http://localhost:8000)
* [localhost:4430](https://localhost:4430)

## Setup Cron

You can add the following commands to your host crontab.

### Background Tasks

```sh
docker exec -it -e IS_CRON=1 chv-v3 /usr/local/bin/php /var/www/html/cron.php
```

### Automatic Importing

The following command will execute automatic importing.

```sh
docker exec -it -e IS_CRON=1 -e THREAD_ID=1 chv-demo /usr/local/bin/php /var/www/html/importing.php
``` -->

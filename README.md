# Docker

> 🔔 [Subscribe](https://newsletter.chevereto.com/subscription?f=PmL892XuTdfErVq763PCycJQrvZ8PYc9JbsVUttqiPV1zXt6DDtf7lhepEStqE8LhGs8922ZYmGT7CYjMH5uSx23pL6Q) to don't miss any update regarding Chevereto.

![Chevereto](https://github.com/chevereto/docker/raw/main/LOGO.svg)

[![Discord](https://img.shields.io/discord/759137550312407050?style=flat-square)](https://chv.to/discord)

This repository is for the official [Chevereto](https://chevereto.com) Docker images.

## Network setup

Create the `chv-network` that containers will use to communicate each other.

```sh
docker network create chv-network
```

## Database setup

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

## `httpd-php`

```sh
docker run -d \
    -p 8008:80 \
    --name chv-dev \
    --network chv-network \
    --network-alias dev \
    -e "CHEVERETO_DB_HOST=mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_TABLE_PREFIX=chv_" \
    -e "CHEVERETO_DB_PORT=3306" \
    -e "CHEVERETO_DB_DRIVER=mysql" \
    -e "CHEVERETO_SOFTWARE=chevereto" \
    -e "CHEVERETO_TAG=latest" \
    -e "CHEVERETO_LICENSE=license_key" \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto/chevereto:latest-httpd-php
```

## `php-fpm`

```sh
docker run -d \
    -p :9000 \
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
    -e "CHEVERETO_SOFTWARE=chevereto" \
    -e "CHEVERETO_TAG=latest" \
    -e "CHEVERETO_LICENSE=license_key" \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto/chevereto:latest-php-fpm
```

## Chevereto-Free users

Chevereto-Free users need to override `docker run` command with the following environment options.

```sh
-e "CHEVERETO_SOFTWARE=chevereto-free" \
-e "CHEVERETO_LICENSE=" \
```

## `demo`

```sh
docker run -d \
    -p 8000:80 \
    --name chv-demo-free \
    --network chv-network \
    -e "CHEVERETO_DB_HOST=demo-mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_TABLE_PREFIX=chv_" \
    -e "CHEVERETO_DB_PORT=3306" \
    -e "CHEVERETO_DB_DRIVER=mysql" \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto/demo
```

See working examples at [demo.sh](../bin/demo.sh) & [demo-free.sh](../bin/demo-free.sh).

## Dev setup

A Chevereto project could be either the [Installer](https://github.com/chevereto/installer), [Chevereto V3](https://chevereto.com/pricing) or [Chevereto-Free](https://github.com/chevereto/chevereto-free).

* The project is a folder intended to be served under an HTTP server
* This guide assumes `/var/www/html/chevereto.loc` as project folder

```sh
cd /var/www/html/chevereto.loc/
```

Create the volumes (if required) at `/var/www/html/chevereto.loc/`:

```sh
mkdir public_html
mkdir -p database/{dev,demo,demo-free}
mkdir -p importing/{no-parse,parse-albums,parse-users}
```

* The application will be at `public_html/`
* Local uploads will be stored at `images/`

> All these directories are for reference, you can customize the volumes with the `--mount` option.

## Automatic setup

The folder at [bin/](bin/) contains shell scripts that automates the provisioning process based on provided Dockerimages.

| Script                           | Stack                  | Description                                                                                         |
| -------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------- |
| [demo.sh](bin/demo.sh)           | `mariadb`, `httpd-php` | Chevereto V3 (requires license) demo with [dummy data](https://github.com/chevereto/demo-importing) |
| [demo-free.sh](bin/demo-free.sh) | `mariadb`, `httpd-php` | Chevereto-Free demo with [dummy data](https://github.com/chevereto/demo-importing)                  |
| [dev.sh](bin/dev.sh)             | `mariadb`, `httpd-php` | Dev stack (install and account opts)                                                                |


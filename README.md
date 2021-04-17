# Docker

> 🔔 [Subscribe](https://newsletter.chevereto.com/subscription?f=PmL892XuTdfErVq763PCycJQrvZ8PYc9JbsVUttqiPV1zXt6DDtf7lhepEStqE8LhGs8922ZYmGT7CYjMH5uSx23pL6Q) to don't miss any update regarding Chevereto.

![Chevereto](LOGO.svg)

[![Discord](https://img.shields.io/discord/759137550312407050?style=flat-square)](https://chv.to/discord)

This repository is for the official [Chevereto V3](https://chevereto.com/pricing) / [Chevereto-Free](https://github.com/chevereto/chevereto-free) Docker images, providing the servicing required to run any existing or new Chevereto installation.

## Dockerfile

This repository provides both PHP and webserver servicing. For database use any official MariaDB image.

### `httpd-php`

The [httpd-php](httpd-php/README.md) image contains Apache HTTP webserver built-in with PHP (mod_php).

### `php-fpm`

The [php-fpm](php-fpm/README.md) image contains PHP-FPM to be used with a proxy pass server (to use with `httpd`, `nginx` or anything else).

### `httpd`

The [httpd](httpd/README.md) image contains Apache HTTP web server to use with `php-fpm` container.

### `nginx`

The [nginx](nginx/README.md) image contains Apache HTTP web server to use with `nginx` container.

## Setup Project

A Chevereto project could be either the [Installer](https://github.com/chevereto/installer), [Chevereto V3](https://chevereto.com/pricing) or [Chevereto-Free](https://github.com/chevereto/chevereto-free).

* The project is a folder intended to be served under an HTTP server
* This guide assumes `/var/www/html/chevereto.loc` as project folder

```sh
cd /var/www/html/chevereto.loc/
```

Create the volumes (if required):

```sh
mkdir {public_html,images,database}
mkdir -p importing/{no-parse,parse-albums,parse-users}
```

* The application will be at `public_html/`
* Local uploads will be stored at `images/`

> All these directories are for reference, you can customize the volumes with the `--mount` option.

### Installer project (recommended)

* Download the Installer at your project's public folder:

```sh
wget -O public_html/installer.php https://chevereto.com/download/file/installer
```

### Existing project

Take note on the host path to your Chevereto installation, it will be used to mount the application at that path.

## Building images

The script at [bin/imaginery.sh](bin/imaginery.sh) contains the build steps for the images provides by this repo.

## Automatic setup

The folder at [bin/](bin/) contains shell scripts that automates the provisioning process.

| Script                   | Stack                         | Description                                                         |
| ------------------------ | ----------------------------- | ------------------------------------------------------------------- |
| [demo.sh](bin/demo.sh)   | `mariadb`, `httpd-php`        | Demo with [dummy data](https://github.com/chevereto/demo-importing) |
| [dev.sh](bin/dev.sh)     | `mariadb`, `httpd-php`        | Dev stack (install and account opts)                                |
| [httpd.sh](bin/httpd.sh) | `mariadb`, `httpd`, `php-fpm` | Same as `dev.sh` but for httpd (mpm_event) + php-fpm                |
| [nginx.sh](bin/nginx.sh) | `mariadb`, `nginx`, `php-fpm` | Same as `dev.sh` but for nginx + php-fpm                            |

## Manual database setup

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

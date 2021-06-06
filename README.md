# Docker

> 🔔 [Subscribe](https://newsletter.chevereto.com/subscription?f=PmL892XuTdfErVq763PCycJQrvZ8PYc9JbsVUttqiPV1zXt6DDtf7lhepEStqE8LhGs8922ZYmGT7CYjMH5uSx23pL6Q) to don't miss any update regarding Chevereto.

![Chevereto](LOGO.svg)

[![Community](https://img.shields.io/badge/chv.to-community-blue?style=flat-square)](https://chv.to/community)
[![Discord](https://img.shields.io/discord/759137550312407050?style=flat-square)](https://chv.to/discord)
[![Twitter Follow](https://img.shields.io/twitter/follow/chevereto?style=social)](https://twitter.com/chevereto)

This repository is for the official [Chevereto](https://chevereto.com) Docker images used for development/production base standard required to run Chevereto.

## Dockerfile

| Name                   | Base             | Usage                                                                         |
| ---------------------- | ---------------- | ----------------------------------------------------------------------------- |
| `demo.Dockerfile`      | `php:7.4-apache` | Chevereto demo with [dummy data](https://github.com/chevereto/demo-importing) |
| `httpd-php.Dockerfile` | `php:7.4-apache` | Chevereto with Apache HTTP Server + mod_php based provisioning                |
| `php-fpm.Dockerfile`   | `php:7.4-fpm`    | Chevereto with PHP-FPM based provisioning                                     |

## How it works?

The `./bootstrap.sh` script is executed on container run and it contains logic that detects the container status (stopped or new), it provides Chevereto application code using the [Installer](https://github.com/chevereto/installer) on first-run.

The containers are intend to be used in systems where once the container gets created, it is then either stopped or started (not removed).

For disposable container-based provisioning (application provided at image layer) check our `chevereto/docker-builder` repository.

## Requirements

* A MariaDB/MySQL container
* A Docker network that containers will use to communicate each other

### Network setup

Create the `chv-network`.

```sh
docker network create chv-network
```

### Database setup

Create the `chv-mariadb` container connected to `chv-network`.

```sh
docker run -itd \
    --name chv-mariadb \
    --network chv-network \
    --network-alias mariadb \
    --health-cmd='mysqladmin ping --silent' \
    -e MYSQL_ROOT_PASSWORD=password \
    mariadb:focal
```

Create the `chevereto` database and its user binding:

```sh
docker exec chv-mariadb mysql -uroot -ppassword -e "CREATE DATABASE chevereto; \
    CREATE USER 'chevereto' IDENTIFIED BY 'user_database_password'; \
    GRANT ALL ON chevereto.* TO 'chevereto' IDENTIFIED BY 'user_database_password';"
```

Secure database installation:

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

## Run

Containers take the following `-e` options:

### Software properties

| Key                  | Values                    | Default   |
| -------------------- | ------------------------- | --------- |
| `CHEVERETO_SOFTWARE` | chevereto, chevereto-free | chevereto |
| `CHEVERETO_TAG`      | 3.20.3, latest, dev       | 3.20.3    |
| `CHEVERETO_LICENSE`  | license key               |           |

### Hostname

| Key                       | Values          | Default   |
| ------------------------- | --------------- | --------- |
| `CHEVERETO_HOSTNAME`      | hostname        | localhost |
| `CHEVERETO_HOSTNAME_PATH` | path to website | /         |

### Assets

| Key                                    | Values       | Default |
| -------------------------------------- | ------------ | ------- |
| `CHEVERETO_ASSET_STORAGE_NAME`         | name         | assets  |
| `CHEVERETO_ASSET_STORAGE_TYPE`         | *see below   | local   |
| `CHEVERETO_ASSET_STORAGE_KEY`          | key          |         |
| `CHEVERETO_ASSET_STORAGE_SECRET`       | secret       |         |
| `CHEVERETO_ASSET_STORAGE_BUCKET`       | bucket       |         |
| `CHEVERETO_ASSET_STORAGE_URL`          | URL          |         |
| `CHEVERETO_ASSET_STORAGE_REGION`       | region       |         |
| `CHEVERETO_ASSET_STORAGE_SERVER`       | server       |         |
| `CHEVERETO_ASSET_STORAGE_SERVICE`      | service      |         |
| `CHEVERETO_ASSET_STORAGE_ACCOUNT_ID`   | account id   |         |
| `CHEVERETO_ASSET_STORAGE_ACCOUNT_NAME` | account name |         |

#### `CHEVERETO_ASSET_STORAGE_TYPE` options

| API               | Type         | URL example                                            |
| ----------------- | ------------ | ------------------------------------------------------ |
| Alibaba Cloud OSS | oss          | `https://<bucket>.<endpoint>/`                         |
| Amazon S3         | s3           | `https://s3.amazonaws.com/<bucket>/`                   |
| Backblaze B2      | b2           | `https://f002.backblazeb2.com/file/<bucket>/`          |
| FTP               | ftp          | `https://hostname/`                                    |
| Google Cloud      | gcloud       | `https://storage.googleapis.com/<bucket>/`             |
| Local             | local        | `https://hostname/`                                    |
| Microsoft Azure   | azure        | `https://<account>.blob.core.windows.net/<container>/` |
| OpenStack         | openstack    | `https://hostname/`                                    |
| S3 compatible     | s3compatible | `https://hostname/`                                    |
| SFTP              | sftp         | `https://hostname/`                                    |

Learn more at the [external storage documentation](https://v3-docs.chevereto.com/features/integrations/external-storage.html).

### Database

| Key                         | Values         | Default                |
| --------------------------- | -------------- | ---------------------- |
| `CHEVERETO_DB_HOST`         | hostname, ip   | mariadb                |
| `CHEVERETO_DB_USER`         | user           | chevereto              |
| `CHEVERETO_DB_PASS`         | password       | user_database_password |
| `CHEVERETO_DB_NAME`         | name           | chevereto              |
| `CHEVERETO_DB_TABLE_PREFIX` | table prefix   | chv_                   |
| `CHEVERETO_DB_PORT`         | port           | 3306                   |
| `CHEVERETO_DB_DRIVER`       | driver         | mysql                  |
| `CHEVERETO_DB_PDO_ATTRS`    | PDO attributes | []                     |

### Sessions

| Key                              | Values       | Default |
| -------------------------------- | ------------ | ------- |
| `CHEVERETO_SESSION_SAVE_HANDLER` | files, redis | files   |
| `CHEVERETO_SESSION_SAVE_PATH`    | path, tcp:// | /tmp    |

### Service tuning

| Key                                 | Values              | Default              |
| ----------------------------------- | ------------------- | -------------------- |
| `CHEVERETO_IMAGE_FORMATS_AVAILABLE` | format list         | JPG,PNG,BMP,GIF,WEBP |
| `CHEVERETO_UPLOAD_MAX_FILESIZE`     | PHP INI size format | 25M                  |
| `CHEVERETO_POST_MAX_SIZE`           | PHP INI size format | 25M                  |
| `CHEVERETO_MEMORY_LIMIT`            | PHP INI size format | 512M                 |
| `CHEVERETO_MAX_EXECUTION_TIME`      | seconds             | 30                   |

### `httpd-php`

```sh
docker run -d \
    -p 8008:80 \
    --name chv-httpd-php \
    --network chv-network \
    --network-alias chv-httpd-php \
    -e "CHEVERETO_SOFTWARE=chevereto" \
    -e "CHEVERETO_LICENSE=put_license_here" \
    -e "CHEVERETO_DB_HOST=mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_TABLE_PREFIX=chv_" \
    -e "CHEVERETO_DB_PORT=3306" \
    -e "CHEVERETO_DB_DRIVER=mysql" \
    -e "CHEVERETO_HOSTNAME=localhost" \
    -e "CHEVERETO_HOSTNAME_PATH=/" \
    -e "CHEVERETO_SESSION_SAVE_HANDLER=files" \
    -e "CHEVERETO_SESSION_SAVE_PATH=/tmp" \
    -e "CHEVERETO_UPLOAD_MAX_FILESIZE=25M" \
    -e "CHEVERETO_POST_MAX_SIZE=25M" \
    -e "CHEVERETO_MAX_EXECUTION_TIME=30" \
    -e "CHEVERETO_MEMORY_LIMIT=512M" \
    -e "CHEVERETO_ASSET_STORAGE_NAME=assets" \
    -e "CHEVERETO_ASSET_STORAGE_TYPE=local" \
    -e "CHEVERETO_ASSET_STORAGE_KEY=" \
    -e "CHEVERETO_ASSET_STORAGE_SECRET=" \
    -e "CHEVERETO_ASSET_STORAGE_BUCKET=" \
    -e "CHEVERETO_ASSET_STORAGE_URL=" \
    -e "CHEVERETO_ASSET_STORAGE_REGION=" \
    -e "CHEVERETO_ASSET_STORAGE_SERVER=" \
    -e "CHEVERETO_ASSET_STORAGE_SERVICE=" \
    -e "CHEVERETO_ASSET_STORAGE_ACCOUNT_ID=" \
    -e "CHEVERETO_ASSET_STORAGE_ACCOUNT_NAME=" 
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
    --network-alias chv-php-fpm \
    -e "CHEVERETO_SOFTWARE=chevereto" \
    -e "CHEVERETO_LICENSE=put_license_here" \
    -e "CHEVERETO_DB_HOST=mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_TABLE_PREFIX=chv_" \
    -e "CHEVERETO_DB_PORT=3306" \
    -e "CHEVERETO_DB_DRIVER=mysql" \
    -e "CHEVERETO_HOSTNAME=localhost" \
    -e "CHEVERETO_HOSTNAME_PATH=/" \
    -e "CHEVERETO_SESSION_SAVE_HANDLER=files" \
    -e "CHEVERETO_SESSION_SAVE_PATH=/tmp" \
    -e "CHEVERETO_UPLOAD_MAX_FILESIZE=25M" \
    -e "CHEVERETO_POST_MAX_SIZE=25M" \
    -e "CHEVERETO_MAX_EXECUTION_TIME=30" \
    -e "CHEVERETO_MEMORY_LIMIT=512M" \
    -e "CHEVERETO_ASSET_STORAGE_NAME=assets" \
    -e "CHEVERETO_ASSET_STORAGE_TYPE=local" \
    -e "CHEVERETO_ASSET_STORAGE_KEY=" \
    -e "CHEVERETO_ASSET_STORAGE_SECRET=" \
    -e "CHEVERETO_ASSET_STORAGE_BUCKET=" \
    -e "CHEVERETO_ASSET_STORAGE_URL=" \
    -e "CHEVERETO_ASSET_STORAGE_REGION=" \
    -e "CHEVERETO_ASSET_STORAGE_SERVER=" \
    -e "CHEVERETO_ASSET_STORAGE_SERVICE=" \
    -e "CHEVERETO_ASSET_STORAGE_ACCOUNT_ID=" \
    -e "CHEVERETO_ASSET_STORAGE_ACCOUNT_NAME=" 
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

### Remarks

Chevereto-Free is not optimized for containers as Chevereto, you will encounter some issues:

* Chevereto-Free doesn't support external storage, will need to bind mount the `/var/www/html/` and `/var/www/html/images` paths
* Chevereto-Free doesn't output to `stderr`, will need a log file

## `demo`

See working one-click demos at [demo.sh](../bin/demo.sh) & [demo-free.sh](../bin/demo-free.sh).

## Dev setup

Pass `CHEVERETO_TAG=dev` and bind mount `/var/www/html/` to the development working directory. By doing this the `bootstrap.sh` script will only spawn services at the Chevereto project, which could be either the [Installer](https://github.com/chevereto/installer), [Chevereto V3](https://chevereto.com/pricing) or [Chevereto-Free](https://github.com/chevereto/chevereto-free).

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

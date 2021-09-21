# Dev

To develop Chevereto it will require to install Chevereto source.

* chevereto-source [v4](https://github.com/chevereto/v4)

## docker-compose

Compose file: [httpd-php-dev.yml](docker-compose/httpd-php-dev.yml)

* `SOURCE` is the absolute path to the chevereto source project.

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto-v4-dev \
    -f docker-compose/httpd-php-dev.yml \
    up
```

[localhost:8940](http://localhost:8940)

* Clear volumes

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto-v4-dev \
    -f docker-compose/httpd-php-dev.yml \
    down --volumes
```

## Sync with application code

Run this command from the Docker host:

```sh
docker exec -it **chevereto**-v4-dev_bootstrap \
    bash /var/www/sync.sh
```

> TIP: This sync is automatic with your project code changes.

## Composer

Use `composer` to manage dependencies.

```sh
docker exec -it chevereto-v4-dev_bootstrap \
    composer install
```

```sh
docker exec -it chevereto-v4-dev_bootstrap \
    composer update
```

## Run Chevereto

Run application commands under `www-data` user.

```sh
docker exec --user www-data \
    -it chevereto-v4-dev_bootstrap \
    command_name
```

* Run `index.php` entry point at the given path.

```sh
docker exec --user www-data \
    -it chevereto-v4-dev_bootstrap \
    php index.php -p=/
```

* Run `-C` CLI commands:

```sh
docker exec --user www-data \
    -it chevereto-v4-dev_bootstrap \
    php cli.php -C cron
```

## Viewing logs

* Errors

```sh
docker logs chevereto-v4-dev_bootstrap -f 1>/dev/null
```

* Access

```sh
docker logs chevereto-v4-dev_bootstrap -f 2>/dev/null
```

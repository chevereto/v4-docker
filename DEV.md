# Dev

To develop Chevereto it will require to install Chevereto source.

* chevereto-source [v4](https://github.com/chevereto/v4)

## docker-compose

Compose file: [httpd-php-dev.yml](docker-compose/httpd-php-dev.yml)

* `SOURCE` is the absolute path to the chevereto source project.

```sh
SOURCE=/Users/rodolfo/git/chevereto/v4 \
docker-compose \
    -p chevereto-v4-dev \
    -f docker-compose/httpd-php-dev.yml \
    up
```

[localhost:8009](http://localhost:8009)

## Sync with application code

Run this command from the Docker host:

```sh
docker exec -it chv-dev-bootstrap \
    bash /var/www/sync.sh
```

> TIP: press up arrow key to call the command again.

## Composer

Use `composer` to manage dependencies.

```sh
docker exec -t chv-dev-bootstrap \
    composer install
```

```sh
docker exec -t chv-dev-bootstrap \
    composer update
```

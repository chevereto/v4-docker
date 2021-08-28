# Dev

To develop Chevereto it will require to install Chevereto source.

* chevereto-source [v3](https://github.com/chevereto/v3)

## docker-compose

Compose file: [httpd-php-dev.yml](docker-compose/httpd-php-dev.yml)

* `CHEVERETO_SOURCE` is the absolute path to the chevereto source project.

```sh
CHEVERETO_SOURCE=/Users/rodolfo/git/chevereto/v3 \
docker-compose \
    -f docker-compose/httpd-php-dev.yml \
    up
```

[localhost:8009](http://localhost:8009)

## Sync with application code

Run this command from the Docker host:

```sh
docker exec -it chv-dev-bootstrap rsync -r -I -og \
    --chown=www-data:www-data \
    --info=progress2 \
    --exclude 'app/settings.php' \
    --exclude 'app/license/key.php' \
    --exclude '.git' \
    --exclude '.gitignore' \
    /var/www/chevereto/ /var/www/html/
```

> TIP: press up arrow key to call the command again.

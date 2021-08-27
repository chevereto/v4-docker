# Dev guide

To develop Chevereto it will require to install Chevereto source.

* chevereto-source [v3](https://github.com/chevereto/v3)

## Application volume

An application volume will be used to store the files used by the container. The host project (working folder) won't be exposed to docker, instead the files will be synced on project update to this volume.

To create `chv-dev-app` application volume:

```sh
docker volume create chv-dev-app
```

## docker-compose

[httpd-php-dev.yml](docker-compose/httpd-php-dev.yml)

Where `CHEVERETO_SOURCE` is the absolute path to the chevereto project.

### Up

```sh
CHEVERETO_SOURCE=/Users/rodolfo/git/chevereto/v3 docker compose \
    -f docker-compose/httpd-php-dev.yml \
    up -d
```

### Stop

```sh
CHEVERETO_SOURCE=/Users/rodolfo/git/chevereto/v3 docker compose \
    -f docker-compose/httpd-php-dev.yml \
    stop
```

## Sync with application code

Enter the container:

```sh
docker exec -it chv-bootstrap bash
```

Run `rsync`:

```sh
rsync -r -I -og \
    --chown=www-data:www-data \
    --info=progress2 \
    --exclude 'app/settings.php' \
    --exclude 'app/license/key.php' \
    --exclude '.git' \
    --exclude '.gitignore' \
    /var/www/chevereto/ /var/www/html/
```

> TIP: Keep the container console opened and press up arrow key to call the command again.

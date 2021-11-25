# Compose

Compose file: [httpd-php.yml](../httpd-php.yml)

## Up

* Replace `YOUR_V4_LICENSE_KEY` with your [Chevereto license](https://chevereto.com/panel/license) key.

Run this command to spawn (start) Chevereto.

```sh
LICENSE=YOUR_V4_LICENSE_KEY \
docker-compose \
    -p chevereto-v4 \
    -f httpd-php.yml \
    up --abort-on-container-exit
```

[localhost:8840](http://localhost:8840)

## Stop

Run this command to stop Chevereto.

```sh
docker-compose \
    -p chevereto-v4 \
    -f httpd-php.yml \
    stop
```

### Down (uninstall)

Run this command to down Chevereto (stop containers, remove networks and volumes created by it).

```sh
docker-compose \
    -p chevereto-v4 \
    -f httpd-php.yml \
    down --volumes
```

## Logs

Run this command to retrieve and follow the error logs.

```sh
docker logs chevereto-v4_bootstrap -f 1>/dev/null
```

Run this command to retrieve and follow the access logs.

```sh
docker logs chevereto-v4_bootstrap -f 2>/dev/null
```

## Commands

### Demo

Run this command to import [demo-importing](https://github.com/chevereto/demo-importing) project assets to `/var/www/html/importing`.

```sh
docker exec -it \
    chevereto-v4_bootstrap \
    bash /var/www/demo-importing.sh
```

### Import

Run this command to import content using the [Bulk Content Importer](https://v3-docs.chevereto.com/features/content/bulk-content-importer.html).

```sh
docker exec --user www-data \
    -it chevereto-v4_bootstrap \
    app/bin/legacy -C importing
```

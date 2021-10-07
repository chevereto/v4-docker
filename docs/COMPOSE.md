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

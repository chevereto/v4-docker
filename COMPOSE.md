# Compose

Compose file: [httpd-php.yml](docker-compose/httpd-php.yml)

## Up

* `LICENSE` your [Chevereto license key](https://chevereto.com/pricing).

Run this command to spawn (start) Chevereto.

```sh
LICENSE=yourLicenseKey \
docker-compose \
    -p chevereto-v4 \
    -f docker-compose/httpd-php.yml \
    up --abort-on-container-exit
```

[localhost:8840](http://localhost:8840)

## Stop

Run this command to stop Chevereto.

```sh
docker-compose \
    -p chevereto-v4 \
    -f docker-compose/httpd-php.yml \
    stop
```

### Down (uninstall)

Run this command to down Chevereto (stop containers, remove networks and volumes created by it).

```sh
docker-compose \
    -p chevereto-v4 \
    -f docker-compose/httpd-php.yml \
    down --volumes
```

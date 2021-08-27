# Compose

* [httpd-php](docker-compose/httpd-php.yml)

* `CHEVERETO_SOURCE` is the absolute path to the chevereto project.
* `CHEVERETO_LICENSE` your [Chevereto license key](https://chevereto.com/pricing).

## Up

[localhost:8008](http://localhost:8008z)

```sh
CHEVERETO_LICENSE=yourLicenseKey \
docker-compose \
    -f docker-compose/httpd-php.yml \
    up -d
```

## Stop

```sh
CHEVERETO_LICENSE=yourLicenseKey \
docker-compose \
    -f docker-compose/httpd-php.yml \
    stop
```

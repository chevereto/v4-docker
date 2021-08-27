# Compose

* [httpd-php](docker-compose/httpd-php.yml)

* `CHEVERETO_SOURCE` is the absolute path to the chevereto project.
* `CHEVERETO_LICENSE` your [Chevereto license key](https://chevereto.com/pricing).

## Up

```sh
CHEVERETO_SOURCE=/Users/rodolfo/git/chevereto/v3
CHEVERETO_LICENSE=yourLicenseKey \
docker compose \
    -f docker-compose/httpd-php.yml \
    up -d
```

## Stop

```sh
CHEVERETO_SOURCE=/Users/rodolfo/git/chevereto/v3
CHEVERETO_LICENSE=yourLicenseKey \
docker compose \
    -f docker-compose/httpd-php.yml \
    stop
```

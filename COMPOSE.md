# Compose

* [httpd-php](docker-compose/httpd-php.yml)

* `CHEVERETO_LICENSE` your [Chevereto license key](https://chevereto.com/pricing).

[localhost:8008](http://localhost:8008)

```sh
CHEVERETO_LICENSE=yourLicenseKey \
docker-compose \
    -f docker-compose/httpd-php.yml \
    up
```

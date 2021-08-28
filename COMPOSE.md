# Compose

Compose file: [httpd-php.yml](docker-compose/httpd-php.yml)

* `CHEVERETO_LICENSE` your [Chevereto license key](https://chevereto.com/pricing).

```sh
CHEVERETO_LICENSE=yourLicenseKey \
docker-compose \
    -f docker-compose/httpd-php.yml \
    up
```

[localhost:8008](http://localhost:8008)

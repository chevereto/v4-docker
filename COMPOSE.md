# Compose

Compose file: [httpd-php.yml](docker-compose/httpd-php.yml)

* `LICENSE` your [Chevereto license key](https://chevereto.com/pricing).

```sh
LICENSE=yourLicenseKey \
docker-compose \
    -p chevereto-v4 \
    -f docker-compose/httpd-php.yml \
    up
```

[localhost:8840](http://localhost:8840)

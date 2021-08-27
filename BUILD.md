# Build

## arm64v8

```sh
docker build -t chevereto/httpd-php:edge . \
    -f httpd-php.Dockerfile \
    --build-arg ARCH=arm64v8
```

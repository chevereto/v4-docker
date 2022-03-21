# Build

The Dockerfile are at `php/{VERSION}/Dockerfile`, you need to take the Dockerfile for your target PHP.

```sh
docker build . \
    -f php/8.1/Dockerfile \
    -t ghcr.io/chevereto/docker:4.0-php8.1
```

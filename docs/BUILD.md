# Build

The Dockerfile are at `chevereto/{VERSION}/Dockerfile`, you need to take the Dockerfile for your target Chevereto version.

```sh
docker build . \
    -f chevereto/4.0/Dockerfile \
    -t ghcr.io/chevereto/docker:4.0-php8.1
```

# Build

* **Tip:** Tag `ghcr.io/chevereto/docker/4.0-php8.0` to override the [ghcr package](https://github.com/orgs/chevereto/packages?repo_name=docker) with local

```sh
cp php/8.0/Dockerfile .
docker build -t ghcr.io/chevereto/docker:4.0-php8.0 .
```

* For custom tag: Replace `tag` with your own.

```sh
cp php/8.0/Dockerfile .
docker build -t chevereto/docker:tag . \
```

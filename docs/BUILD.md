# Build

* **Tip:** Tag `ghcr.io/chevereto/docker/4.0-php80` to override the [ghcr package](https://github.com/orgs/chevereto/packages?repo_name=docker) with local

```sh
cp -r .docker-files/* php/8.0
docker build -t ghcr.io/chevereto/docker:4.0-php80 php/8.0
```

* For custom tag: Replace `tag` with your own.

```sh
cp -r .docker-files/* php/8.0
docker build -t chevereto/docker:tag php/8.0 \
```

# Build

* **Tip:** Tag `ghcr.io/chevereto/httpd-php:4.0` to override the [ghcr package](https://github.com/orgs/chevereto/packages?repo_name=docker) with local

```sh
docker build -t ghcr.io/chevereto/httpd-php:4.0 . \
    -f httpd-php.Dockerfile
```

* For custom tag: Replace `tag` with your own.

```sh
docker build -t chevereto/httpd-php:tag . \
    -f httpd-php.Dockerfile
```

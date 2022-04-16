# Make

[Makefile](../Makefile) provides commands for managing multiple container provisioning.

*Note:* Pass `DOCKER_USER=<user>` to set the user for run commands. Default `www-data`.

```sh
make <command> <VERSION=4.0 PHP=8.1 DOCKER_USER=www-data ... >
```

Default values:

* DOCKER_USER=www-data
* PHP=8.1
* TARGET=dev
* VERSION=4.0

## Production

💡 It requires a [Chevereto license](https://chevereto.com/pricing) key.

* To build a production instance:

```sh
make prod
```

## Demo

💡 It requires a [Chevereto license](https://chevereto.com/pricing) key.

* To build a demo instance:

```sh
make demo
```

## Dev

A dev instance is used when you have a Chevereto project in your system (`SOURCE` argument). A Chevereto project is any folder containing Chevereto code, including your own modified versions.

💡 It requires a Chevereto project.

* To build a dev instance:

```sh
make dev SOURCE=~/git/chevereto/v4
```

* To implement demo on dev:

```sh
make dev--demo
```

* To run composer `update` on dev:

```sh
make dev--composer run=update
```

* To run composer `install` on dev:

```sh
make dev--composer run=install
```

* To run `sync` script on dev instance:

💡 It syncs your `SOURCE` with the code running in the container.

```sh
make dev--sh run=sync
```

* To run `observe` script on dev instance:

💡 Same as sync, but observe `SOURCE` for auto re-sync.

```sh
make dev--sh run=observe
```

## General commands

Available options:

* TARGET=dev (dev, demo, prod)

### Up

* To up an instance:

```sh
make up
```

* To up an instance (daemon):

```sh
make up-d
```

### Down

* To takedown an instance (keep volumes):

```sh
make down
```

* To takedown an instance (remove volumes):

```sh
make down--volumes
```

### Logs

To retrieve and follow the error log:

```sh
make log-error
```

To retrieve and follow the access log:

```sh
make log-access
```

### Bash

To enter a container's bash shell:

```sh
make bash
```

### Build container image

To build a container image:

```sh
make build
```

### Build httpd.conf

To build your custom [httpd.conf](../httpd/httpd.conf), edit the contents of [chevereto.conf](../httpd/chevereto.conf) and run:

```sh
make build-httpd
```

## Troubleshooting

### Container never stars

**Problem**: If you get the following loop:

```plain
[* starting] Waiting for chevereto4.0-prod-php8.1...
[* unhealthy] Waiting for chevereto4.0-prod-php8.1...
[* starting] Waiting for chevereto4.0-prod-php8.1...
.
.
.
```

**Possible cause**: Wrong license key provided.

**Workaround**: Make sure to use `cmd + v` when using macOS, and `shift + ctrl + v` if using Linux to paste the license key.

### Unable to run containers

**Problem**: Wrong Docker engine/compose versions.

**Workaround**: Check if you are running latest Docker version with [Compose V2](https://docs.docker.com/compose/cli-command/) `docker compose` (not `docker-compose`).

If Docker was included with your Linux distribution check for [Install Docker Engine](https://docs.docker.com/engine/install/) on Linux. Some distributions may be providing old docker engine for LTS compliance, make sure to follow Docker instructions.

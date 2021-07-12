# Docker

> 🔔 [Subscribe](https://newsletter.chevereto.com/subscription?f=PmL892XuTdfErVq763PCycJQrvZ8PYc9JbsVUttqiPV1zXt6DDtf7lhepEStqE8LhGs8922ZYmGT7CYjMH5uSx23pL6Q) to don't miss any update regarding Chevereto.

![Chevereto](LOGO.svg)

[![Community](https://img.shields.io/badge/chv.to-community-blue?style=flat-square)](https://chv.to/community)
[![Discord](https://img.shields.io/discord/759137550312407050?style=flat-square)](https://chv.to/discord)
[![Twitter Follow](https://img.shields.io/twitter/follow/chevereto?style=social)](https://twitter.com/chevereto)

This repository is for the [Chevereto](https://chevereto.com) Docker images used for development base standard required to run Chevereto.

## Dockerfile

| Name                   | Base             | Usage                                                                         |
| ---------------------- | ---------------- | ----------------------------------------------------------------------------- |
| `demo.Dockerfile`      | `php:7.4-apache` | Chevereto demo with [dummy data](https://github.com/chevereto/demo-importing) |
| `httpd-php.Dockerfile` | `php:7.4-apache` | Chevereto with Apache HTTP Server + mod_php based provisioning                |
| `php-fpm.Dockerfile`   | `php:7.4-fpm`    | Chevereto with PHP-FPM based provisioning                                     |

## How it works?

The `./bootstrap.sh` script is executed on container run and it contains logic that detects the container status (stopped or new), it provides Chevereto application code using the [Installer](https://github.com/chevereto/installer) on first-run.

The containers are intend to be used in systems where once the container gets created, it is then either stopped or started (not removed).

For disposable container-based provisioning (application provided at image layer) check our [chevereto/container-builder](https://github.com/chevereto/container-builder) repository.

## Requirements

* A MariaDB/MySQL container
* A Docker network that containers will use to communicate each other
* Persistent storage

## Compose

* [httpd-php](compose/httpd-php.yml)
* php-fpm

### Manual setup

Check the scripts at [bin/](bin/).

## Demo

See working one-click demo at [demo.sh](../bin/demo.sh).

## Dev setup

Pass `CHEVERETO_TAG=dev` and bind mount `/var/www/html/` to the development working directory. By doing this the `bootstrap.sh` script will only spawn services at the Chevereto project, which could be either the [Installer](https://github.com/chevereto/installer), [Chevereto V3](https://chevereto.com/pricing).

* The project is a folder intended to be served under an HTTP server
* This guide assumes `/var/www/html/chevereto.loc` as project folder

```sh
cd /var/www/html/chevereto.loc/
```

Create the dirs (if required) at `/var/www/html/chevereto.loc/`:

```sh
mkdir public_html
mkdir -p database/{dev,demo}
mkdir -p importing/{no-parse,parse-albums,parse-users}
```

* The application will be at `public_html/`
* Local uploads will be stored at `images/`

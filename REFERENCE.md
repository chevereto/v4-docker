# Reference

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

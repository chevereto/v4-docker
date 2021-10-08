# Dev

## Quick start

* Clone [chevereto/docker](https://github.com/chevereto/docker)
  * Use `4.0` branch `git switch 4.0`
  * Run [docker-compose up](#up)

* Using [chevereto/v4](https://github.com/chevereto/v4) repository:
  * Clone the repository
  * Your clone path will be your `SOURCE`

* Using [chevereto.com/panel/downloads](https://chevereto.com/panel/downloads):
  * Download the target V4 release
  * Your extract path will be your `SOURCE`

* [Sync code](#sync-code) to bootstrap the application files and sync changes
* [Install dependencies](#dependencies)

## Reference

* `SOURCE` is the absolute path to the cloned chevereto project
* You need to replace `SOURCE=~/git/chevereto/v4` with your own path
* `SOURCE` will be mounted at `/var/www/chevereto/` inside the container
* Chevereto will be available at [localhost:8940](http://localhost:8940)

✨ This dev setup mounts `SOURCE` to provide the application files to the container. We provide a sync system that copies these files on-the-fly to the actual application runner for better isolation.

## docker-compose

Compose file: [httpd-php-dev.yml](../httpd-php-dev.yml)

Alter `SOURCE` in the commands below to reflect your project path.

### Up

Run this command to spawn (start) Chevereto.

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto-v4-dev \
    -f httpd-php-dev.yml \
    up -d
```

### Stop

Run this command to stop Chevereto.

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto-v4-dev \
    -f httpd-php-dev.yml \
    stop
```

### Down (uninstall)

Run this command to down Chevereto (stop containers, remove networks and volumes created by it).

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto-v4-dev \
    -f httpd-php-dev.yml \
    down --volumes
```

## Sync code

Run this command to sync the application code with your working project.

```sh
docker exec -it \
    chevereto-v4-dev_bootstrap \
    bash /var/www/sync.sh
```

This system will observe for changes in your working project filesystem and it will automatically sync the files inside the container.

**Note:** This command must keep running to provide the sync functionality. You should close it once you stop working with the source.

## Dependencies

We use [composer](https://getcomposer.org) to manage dependencies.

Run this command to provide the vendor dependencies.

```sh
docker exec -it \
    chevereto-v4-dev_bootstrap \
    composer update
```

## Logs

Run this command to retrieve and follow the error logs.

```sh
docker logs chevereto-v4-dev_bootstrap -f 1>/dev/null
```

Run this command to retrieve and follow the access logs.

```sh
docker logs chevereto-v4-dev_bootstrap -f 2>/dev/null
```

## Running Chevereto commands

Chevereto application commands must run under `www-data` user.

Run the command below to phony `index.php` requests at the given path.

```sh
docker exec --user www-data \
    -it chevereto-v4-dev_bootstrap \
    php index.php -p=/
```

Run the command below to execute `cron` `-C` CLI commands.

```sh
docker exec --user www-data \
    -it chevereto-v4-dev_bootstrap \
    php cli.php -C cron
```

Available commands: `cron` `langs` `importing`
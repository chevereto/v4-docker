# Dev

## Reference

* `SOURCE` is the absolute path to the cloned chevereto project
* You need to replace `SOURCE=~/git/chevereto/v4` with your own path
* `SOURCE` will be mounted at `/var/www/chevereto/` inside the container
* Chevereto will be available at [localhost:40809](http://localhost:40809)

## Quick start

* Clone [chevereto/docker](https://github.com/chevereto/docker)
  * Use `4.0` branch `git switch 4.0`
  * Run [docker-compose up](#up)

You will need a Chevereto V4 project, which you can provide as a git repo or as a package.

* Git repo alternative:
  * Clone the [chevereto/v4](https://github.com/chevereto/v4) repository (your clone path will be your `SOURCE`)
* Package alternative:
  * Download the target V4 release from [chevereto.com/panel/downloads](https://chevereto.com/panel/downloads) (your extract path will be your `SOURCE`)

To work with dev resources you will require to sync and install dependencies.

* [Sync code](#sync-code) to bootstrap the application files and sync changes
* [Install dependencies](#dependencies)

✨ This dev setup mounts `SOURCE` to provide the application files to the container. We provide a sync system that copies these files on-the-fly to the actual application runner for better isolation.

## docker-compose

Compose file: [php/8.0/dev.yml](../php/8.0/dev.yml)

Alter `SOURCE` in the commands below to reflect your project path.

### Up

Run this command to spawn (start) Chevereto.

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto4.0-dev-php8.0 \
    -f php/8.0/dev.yml \
    up -d
```

### Stop

Run this command to stop Chevereto.

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto4.0-dev-php8.0 \
    -f php/8.0/dev.yml \
    stop
```

### Down (uninstall)

Run this command to down Chevereto (stop containers, remove networks and volumes created by it).

```sh
SOURCE=~/git/chevereto/v4 \
docker-compose \
    -p chevereto4.0-dev-php8.0 \
    -f php/8.0/dev.yml \
    down --volumes
```

## Logs

Run this command to retrieve and follow the error logs.

```sh
docker logs chevereto4.0-dev-php8.0 -f 1>/dev/null
```

Run this command to retrieve and follow the access logs.

```sh
docker logs chevereto4.0-dev-php8.0 -f 2>/dev/null
```

## Commands

### Sync code

Run this command to sync the application code with your working project.

```sh
docker exec -it \
    chevereto4.0-dev-php8.0 \
    bash /var/www/sync.sh
```

This system will observe for changes in your working project filesystem and it will automatically sync the files inside the container.

**Note:** This command must keep running to provide the sync functionality. You should close it once you stop working with the source.

### Dependencies

Run this command to provide the vendor dependencies.

```sh
docker exec --user www-data -it \
    chevereto4.0-dev-php8.0 \
    composer update
```

### Demo

Run this command to import [demo-importing](https://github.com/chevereto/demo-importing) project assets to `/var/www/html/importing`.

```sh
docker exec -it \
    chevereto4.0-dev-php8.0 \
    bash /var/www/demo-importing.sh
```

### Import

Run this command to import content using the [Bulk Content Importer](https://v3-docs.chevereto.com/features/content/bulk-content-importer.html).

```sh
docker exec --user www-data -it \
    chevereto4.0-dev-php8.0 \
    app/bin/legacy -C importing
```

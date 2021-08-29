# Demo

## Build demo assets

Run this command to import [demo-importing](https://github.com/chevereto/demo-importing) project assets to `/var/www/html/importing`.

```sh
docker exec -it chv-bootstrap \
    bash /var/www/demo-importing.sh
```

## Import

Run the [Bulk Content Importer](https://v3-docs.chevereto.com/features/content/bulk-content-importer.html).

```sh
docker exec -it chv-bootstrap \
    php cli.php -C importing
```

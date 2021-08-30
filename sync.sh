#!/usr/bin/env bash
set -e
rsync -r -I -og \
    --chown=www-data:www-data \
    --info=progress2 \
    --exclude '.git' \
    --exclude 'vendor' \
    --exclude 'app/settings.php' \
    /var/www/chevereto/ /var/www/html/

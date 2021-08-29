#!/usr/bin/env bash
set -e
rsync -r -I -og \
    --chown=www-data:www-data \
    --info=progress2 \
    --exclude 'app/settings.php' \
    --exclude '.git' \
    --exclude '.gitignore' \
    /var/www/chevereto/ /var/www/html/

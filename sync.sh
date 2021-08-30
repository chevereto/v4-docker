#!/usr/bin/env bash
set -e
rsync -r -I -og \
    --chown=www-data:www-data \
    --info=progress2 \
    --filter=':- .gitignore' \
    --exclude '.git' \
    --delete \
    /var/www/chevereto/ /var/www/html/

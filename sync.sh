#!/usr/bin/env bash
set -e
while inotifywait -r -e modify,create,delete /var/www/chevereto/; do
    rsync -r -I -og \
        --chown=www-data:www-data \
        --info=progress2 \
        --filter=':- .gitignore' \
        --exclude '.git' \
        --delete \
        /var/www/chevereto/ /var/www/html/
done

#!/usr/bin/env bash
set -e
function sync() {
    rsync -r -I -og \
        --chown=www-data:www-data \
        --info=progress2 \
        --filter=':- .gitignore' \
        --exclude '.git' \
        --exclude 'importing/' \
        --exclude 'images/' \
        --exclude '_assets/' \
        --delete \
        /var/www/chevereto/ /var/www/html/
}
sync
while inotifywait -r -e modify,create,delete /var/www/chevereto/; do
    sync
done

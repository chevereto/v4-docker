#!/usr/bin/env bash
set -e
SOURCE=/var/www/chevereto/
TARGET=/var/www/html/
EXCLUDE="\.git|\.DS_Store|\.vscode|\/app\/vendor|\/app\/settings\.php|\/app\/importer\/jobs"
cp "${SOURCE}".gitignore "${TARGET}".gitignore
function sync() {
    rsync -r -I -og \
        --chown=www-data:www-data \
        --info=progress2 \
        --filter=':- .gitignore' \
        --exclude '.git' \
        --exclude '_assets/' \
        --delete \
        $SOURCE $TARGET
}
sync
inotifywait \
    --event create \
    --event delete \
    --event modify \
    --event move \
    --format "%e %w%f" \
    --exclude $EXCLUDE \
    --monitor \
    --recursive \
    $SOURCE |
    while read CHANGED; do
        sync
    done

#!/usr/bin/env bash
set -e
SOURCE=/var/www/chevereto/
TARGET=/var/www/html/
cp "${SOURCE}".gitignore "${TARGET}".gitignore
EXCLUDE=$(
    readarray -t ARRAY <"${SOURCE}".gitignore
    IFS='|'
    echo "${ARRAY[*]}"
)"|\.git"
function sync() {
    rsync -r -I -og \
        --chown=www-data:www-data \
        --info=progress2 \
        --filter=':- .gitignore' \
        --exclude '.git' \
        --delete \
        $SOURCE $TARGET
}
sync
while inotifywait --exclude ${EXCLUDE} -r -e modify,create,delete ${SOURCE}; do
    sync
done

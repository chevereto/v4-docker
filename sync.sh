#!/usr/bin/env bash
set -e
cp /var/www/chevereto/.gitignore /var/www/html/.gitignore
function sync() {
    rsync -r -I -og \
        --chown=www-data:www-data \
        --info=progress2 \
        --filter=':- .gitignore' \
        --exclude '.git' \
        --delete \
        /var/www/chevereto/ /var/www/html/
}
sync
EXCLUDE=$(
    readarray -t ARRAY </var/www/chevereto/.gitignore
    IFS='|'
    echo "${ARRAY[*]}"
)"|\.git"
while inotifywait --exclude ${EXCLUDE} -r -e modify,create,delete /var/www/chevereto/; do
    sync
done

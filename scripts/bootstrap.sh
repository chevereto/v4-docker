#!/usr/bin/env bash
set -e
DIR="/var/www"
WORKING_DIR="/var/www/html"
CONTAINER_STARTED="/var/CONTAINER_STARTED_PLACEHOLDER"
CHEVERETO_PACKAGE=$CHEVERETO_TAG"-lite"
CHEVERETO_API_DOWNLOAD="https://chevereto.com/api/download/"
chv_install() {
    rm -rf /chevereto/download
    echo "Making working dir /chevereto/download"
    mkdir -p /chevereto/download
    echo "cd /chevereto/download"
    cd /chevereto/download
    echo "* Downloading chevereto/v4 $CHEVERETO_PACKAGE package"
    curl -f -SOJL \
        -H "License: $CHEVERETO_LICENSE" \
        "${CHEVERETO_API_DOWNLOAD}${CHEVERETO_PACKAGE}"
    echo "* Extracting package"
    unzip -oq ${CHEVERETO_SOFTWARE}*.zip -d $WORKING_DIR
    echo "* Installing dependencies"
    composer install \
        --working-dir=$WORKING_DIR/app \
        --no-progress \
        --classmap-authoritative \
        --ignore-platform-reqs
}
chv_provide() {
    echo "* chown www-data: $WORKING_DIR -R"
    chown www-data: $WORKING_DIR -R
    echo "$CHEVERETO_TAG" >$CONTAINER_STARTED
    echo "[OK] $CHEVERETO_SOFTWARE $CHEVERETO_TAG provisioned"
}
echo $CONTAINER_STARTED
if [ ! -e $CONTAINER_STARTED ]; then
    if [ "$CHEVERETO_TAG" != "dev" ]; then
        chv_install
    fi
    chv_provide
fi
echo "[OK] Started $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
cd $WORKING_DIR
$1

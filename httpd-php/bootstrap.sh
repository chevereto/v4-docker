#!/usr/bin/env bash
set -e
DIR="/var/www"
WORKING_DIR="$DIR/html"
CONTAINER_STARTED="$DIR/CONTAINER_STARTED_PLACEHOLDER"
DEV_TAG="dev"
if [ "$CHEVERETO_TAG" != "$DEV_TAG" ] && [ ! -e $CONTAINER_STARTED ]; then
    echo "[FIRST RUN] $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
    echo "* Downloading installer.php"
    curl -o installer.php https://chevereto.com/download/file/installer
    echo "* Downloading $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
    php installer.php -a download -s $CHEVERETO_SOFTWARE -t=$CHEVERETO_TAG -l="$CHEVERETO_LICENSE"
    echo "* Extracting downloaded file"
    php installer.php -a extract -s $CHEVERETO_SOFTWARE -f chevereto-pkg-*.zip -p $WORKING_DIR
    echo "* chown www-data: . -R"
    chown www-data: . -R
    rm -rf installer.php
    echo "[OK] $CHEVERETO_SOFTWARE $CHEVERETO_TAG installed!"
    touch $CONTAINER_STARTED
else
    echo "[OK] Container startup"
fi
apache2-foreground

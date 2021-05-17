#!/usr/bin/env bash
set -e
DIR="/var/www"
WORKING_DIR="$DIR/html"
CONTAINER_STARTED="$DIR/CONTAINER_STARTED_PLACEHOLDER"
DEV_TAG="dev"
if [ "$CHEVERETO_TAG" != "$DEV_TAG" ] && [ ! -e $CONTAINER_STARTED ]; then
    echo "[FIRST RUN] $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
    echo "Making working dir /chevereto/{download,installer}"
    mkdir -p /chevereto/{download,installer}
    echo "[cd] /chevereto/download"
    cd /chevereto/download
    echo "* Downloading chevereto/installer $CHEVERETO_INSTALLER_TAG"
    curl -S -o installer.tar.gz -L "https://github.com/chevereto/installer/archive/${CHEVERETO_INSTALLER_TAG}.tar.gz"
    echo "* Extracting installer.tar.gz"
    tar -xvzf installer.tar.gz
    echo "* Moving extracted installer"
    mv -v installer-"${CHEVERETO_INSTALLER_TAG}"/* /chevereto/installer/
    echo "[cd] /chevereto/installer"
    cd /chevereto/installer
    echo "* Downloading $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
    php installer.php -a download -s $CHEVERETO_SOFTWARE -t=$CHEVERETO_TAG -l="$CHEVERETO_LICENSE"
    echo "* Extracting downloaded file"
    php installer.php -a extract -s $CHEVERETO_SOFTWARE -f chevereto-pkg-*.zip -p $WORKING_DIR
    echo "* chown www-data: $WORKING_DIR -R"
    chown www-data: $WORKING_DIR -R
    touch $CONTAINER_STARTED
    cd $WORKING_DIR
    echo "[OK] $CHEVERETO_SOFTWARE $CHEVERETO_TAG installed!"
else
    echo "[OK] Container startup"
fi
apache2-foreground

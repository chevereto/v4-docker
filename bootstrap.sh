#!/usr/bin/env bash
set -e
DIR="/var/www"
WORKING_DIR="/var/www/html"
CONTAINER_STARTED="/var/CONTAINER_STARTED_PLACEHOLDER"

chv_install() {
    rm -rf /chevereto/{download,installer}
    echo "Making working dir /chevereto/{download,installer}"
    mkdir -p /chevereto/{download,installer}
    echo "cd /chevereto/download"
    cd /chevereto/download
    echo "* Downloading chevereto/installer $CHEVERETO_INSTALLER_TAG"
    curl -Ss -o installer.tar.gz -L "https://github.com/chevereto/installer/archive/${CHEVERETO_INSTALLER_TAG}.tar.gz"
    echo "* Extracting installer.tar.gz"
    tar -xvzf installer.tar.gz
    echo "* Moving extracted installer"
    mv -v installer-"${CHEVERETO_INSTALLER_TAG}"/* /chevereto/installer/
    echo "cd /chevereto/installer"
    cd /chevereto/installer
    echo "* Downloading $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
    php installer.php -a download -s $CHEVERETO_SOFTWARE -t=$CHEVERETO_TAG -l=$CHEVERETO_LICENSE
    echo "* Extracting downloaded file"
    php installer.php -a extract -s $CHEVERETO_SOFTWARE -f chevereto-pkg-*.zip -p $WORKING_DIR
}

chv_provide() {
    echo "* chown www-data: $WORKING_DIR -R"
    chown www-data: $WORKING_DIR -R
    echo "$CHEVERETO_TAG" >$CONTAINER_STARTED
    cd $WORKING_DIR
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
$1

#!/usr/bin/env bash
set -e
DIR="/var/www"
WORKING_DIR="$DIR/html"
CONTAINER_STARTED="$DIR/CONTAINER_STARTED_PLACEHOLDER"
DEV_TAG="dev"
if [ ! -e $CONTAINER_STARTED ]; then
    echo "[FIRST RUN] $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
    if [ "$CHEVERETO_TAG" != "$DEV_TAG" ]; then
        echo "Making working dir /chevereto/{download,installer}"
        mkdir -p /chevereto/{download,installer}
        echo "cd /chevereto/download"
        cd /chevereto/download
        echo "* Downloading chevereto/installer $CHEVERETO_INSTALLER_TAG"
        curl -S -o installer.tar.gz -L "https://github.com/chevereto/installer/archive/${CHEVERETO_INSTALLER_TAG}.tar.gz"
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
    fi
    echo "* Creating app/settings.php (env based)"
    mkdir -p $WORKING_DIR/app
    set -eux
    {
        echo "<?php"
        echo "\$settings = ["
        echo "  'asset_storage_account_id' => getenv('CHEVERETO_ASSET_STORAGE_ACCOUNT_ID'),"
        echo "  'asset_storage_account_name' => getenv('CHEVERETO_ASSET_STORAGE_ACCOUNT_NAME'),"
        echo "  'asset_storage_bucket' => getenv('CHEVERETO_ASSET_STORAGE_BUCKET'),"
        echo "  'asset_storage_key' => getenv('CHEVERETO_ASSET_STORAGE_KEY'),"
        echo "  'asset_storage_name' => getenv('CHEVERETO_ASSET_STORAGE_NAME'),"
        echo "  'asset_storage_region' => getenv('CHEVERETO_ASSET_STORAGE_REGION'),"
        echo "  'asset_storage_secret' => getenv('CHEVERETO_ASSET_STORAGE_SECRET'),"
        echo "  'asset_storage_server' => getenv('CHEVERETO_ASSET_STORAGE_SERVER'),"
        echo "  'asset_storage_service' => getenv('CHEVERETO_ASSET_STORAGE_SERVICE'),"
        echo "  'asset_storage_type' => getenv('CHEVERETO_ASSET_STORAGE_TYPE'),"
        echo "  'asset_storage_url' => getenv('CHEVERETO_ASSET_STORAGE_URL'),"
        echo "  'db_driver' => getenv('CHEVERETO_DB_DRIVER'),"
        echo "  'db_host' => getenv('CHEVERETO_DB_HOST'),"
        echo "  'db_name' => getenv('CHEVERETO_DB_NAME'),"
        echo "  'db_pass' => getenv('CHEVERETO_DB_PASS'),"
        echo "  'db_pdo_attrs' => getenv('CHEVERETO_DB_PDO_ATTRS'),"
        echo "  'db_port' => (int) getenv('CHEVERETO_DB_PORT'),"
        echo "  'db_table_prefix' => getenv('CHEVERETO_DB_TABLE_PREFIX'),"
        echo "  'db_user' => getenv('CHEVERETO_DB_USER'),"
        echo "  'debug_level' => (int) getenv('CHEVERETO_DEBUG_LEVEL'),"
        echo "  'disable_php_pages' => (bool) getenv('CHEVERETO_DISABLE_PHP_PAGES'),"
        echo "  'hostname_path' => getenv('CHEVERETO_HOSTNAME_PATH'),"
        echo "  'hostname' => getenv('CHEVERETO_HOSTNAME'),"
        echo "  'https' => (bool) getenv('CHEVERETO_HTTPS'),"
        echo "  'image_formats_available' => explode(',', getenv('CHEVERETO_IMAGE_FORMATS_AVAILABLE')),"
        echo "  'session.save_handler' => getenv('CHEVERETO_SESSION_SAVE_HANDLER'),"
        echo "  'session.save_path' => getenv('CHEVERETO_SESSION_SAVE_PATH'),"
        echo "];"
    } >"$WORKING_DIR"/app/settings.php
    echo "* chown www-data: $WORKING_DIR -R"
    chown www-data: $WORKING_DIR -R
    touch $CONTAINER_STARTED
    cd $WORKING_DIR
    echo "[OK] $CHEVERETO_SOFTWARE $CHEVERETO_TAG provisioned"
fi
echo "[OK] Started $CHEVERETO_SOFTWARE $CHEVERETO_TAG"
$1

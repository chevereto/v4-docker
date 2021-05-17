FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libgd-dev \
    libzip-dev \
    zip \
    imagemagick libmagickwand-dev --no-install-recommends \
    && docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/ \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install -j$(nproc) exif gd pdo_mysql zip opcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick opcache \
    && php -m  \
    && a2enmod rewrite

ARG CHEVERETO_SOFTWARE=chevereto
ARG CHEVERETO_TAG=latest
ARG CHEVERETO_INSTALLER_TAG=2.2.0
ARG CHEVERETO_SERVICING=docker

ENV CHEVERETO_SOFTWARE=$CHEVERETO_SOFTWARE \
    CHEVERETO_TAG=$CHEVERETO_TAG \
    CHEVERETO_INSTALLER_TAG=$CHEVERETO_INSTALLER_TAG \
    CHEVERETO_SERVICING=$CHEVERETO_SERVICING \
    CHEVERETO_LICENSE= \
    CHEVERETO_DB_HOST=mariadb \
    CHEVERETO_DB_USER=chevereto \
    CHEVERETO_DB_PASS=user_database_password \
    CHEVERETO_DB_NAME=chevereto \
    CHEVERETO_DB_TABLE_PREFIX=chv_ \
    CHEVERETO_DB_PORT=3306 \
    CHEVERETO_DB_DRIVER=mysql \
    CHEVERETO_DB_PDO_ATTRS=[] \
    CHEVERETO_DEBUG_LEVEL=1 \
    CHEVERETO_ERROR_LOG= \
    CHEVERETO_IMAGE_FORMATS_AVAILABLE=JPG,PNG,BMP,GIF,WEBP \
    CHEVERETO_HOSTNAME=localhost \
    CHEVERETO_HOSTNAME_PATH=/ \
    CHEVERETO_SESSION_SAVE_HANDLER=files \
    CHEVERETO_SESSION_SAVE_PATH=/tmp \
    CHEVERETO_UPLOAD_MAX_FILESIZE=25M \
    CHEVERETO_POST_MAX_SIZE=25M \
    CHEVERETO_MAX_EXECUTION_TIME=30 \
    CHEVERETO_MEMORY_LIMIT=512M

RUN set -eux; \
    { \
    echo "log_errors = On"; \
    echo "error_log = /dev/stderr"; \
    echo "upload_max_filesize = \${CHEVERETO_UPLOAD_MAX_FILESIZE}"; \
    echo "post_max_size = \${CHEVERETO_POST_MAX_SIZE}"; \
    echo "max_execution_time = \${CHEVERETO_MAX_EXECUTION_TIME}"; \
    echo "memory_limit = \${CHEVERETO_MEMORY_LIMIT}"; \
    } > $PHP_INI_DIR/conf.d/php.ini

RUN mkdir -p /var/www/html/app/ && \
    set -eux; \
    { \
    echo "<?php"; \
    echo "\$settings = ["; \
    echo "  'db_host' => getenv('CHEVERETO_DB_HOST'),"; \
    echo "  'db_name' => getenv('CHEVERETO_DB_NAME'),"; \
    echo "  'db_user' => getenv('CHEVERETO_DB_USER'),"; \
    echo "  'db_pass' => getenv('CHEVERETO_DB_PASS'),"; \
    echo "  'db_port' => getenv('CHEVERETO_DB_PORT'),"; \
    echo "  'db_table_prefix' => getenv('CHEVERETO_DB_TABLE_PREFIX'),"; \
    echo "  'db_driver' => getenv('CHEVERETO_DB_DRIVER'),"; \
    echo "  'db_pdo_attrs' => getenv('CHEVERETO_DB_PDO_ATTRS'),"; \
    echo "  'image_formats_available' => getenv('CHEVERETO_IMAGE_FORMATS_AVAILABLE'),"; \
    echo "  'hostname' => getenv('CHEVERETO_HOSTNAME'),"; \
    echo "  'hostname_path' => getenv('CHEVERETO_HOSTNAME_PATH'),"; \
    echo "  'debug_level' => getenv('CHEVERETO_DEBUG_LEVEL'),"; \
    echo "  'session.save_handler' => getenv('CHEVERETO_SESSION_SAVE_HANDLER'),"; \
    echo "  'session.save_path' => getenv('CHEVERETO_SESSION_SAVE_PATH'),"; \
    echo "  'https' => getenv('CHEVERETO_HTTPS'),"; \
    echo "  'disable_php_pages' => getenv('CHEVERETO_DISABLE_PHP_PAGES'),"; \
    echo "];"; \
    } > /var/www/html/app/settings.php

VOLUME /var/www/html/
VOLUME /var/www/html/images
VOLUME /var/www/html/importing/no-parse
VOLUME /var/www/html/importing/parse-albums
VOLUME /var/www/html/importing/parse-users

ADD bootstrap.sh /var/www/bootstrap.sh
RUN chmod +x /var/www/bootstrap.sh
CMD ["/bin/bash", "/var/www/bootstrap.sh", "apache2-foreground"]
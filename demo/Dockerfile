FROM alpine as downloader

ARG CHEVERETO_VERSION=1.3.0

RUN apk add --no-cache curl && \
    curl -sS -o /tmp/installer.php -L "https://raw.githubusercontent.com/Chevereto/installer/master/installer.php"

FROM php:7.4-apache

COPY --from=downloader --chown=33:33 /tmp/installer.php /var/www/html/installer.php

RUN apt-get update && apt-get install -y \
    ssl-cert \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libgd-dev \
    libzip-dev \
    zip \
    imagemagick libmagickwand-dev --no-install-recommends

RUN docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd pdo_mysql zip opcache
RUN docker-php-ext-configure opcache --enable-opcache
RUN pecl install imagick
RUN docker-php-ext-enable imagick
RUN php -m 
RUN a2enmod rewrite

RUN php installer.php -a download -s chevereto-free
RUN php installer.php -a extract -s chevereto-free -p $(pwd) -f chevereto-pkg-*.zip

ENV CHEVERETO_SERVICING=docker \
    CHEVERETO_DB_HOST=demo-mariadb \
    CHEVERETO_DB_USER=chevereto \
    CHEVERETO_DB_PASS=user_database_password \
    CHEVERETO_DB_NAME=chevereto \
    CHEVERETO_DB_TABLE_PREFIX=chv_ \
    CHEVERETO_DB_PORT=3306 \
    CHEVERETO_DB_DRIVER=mysql \
    CHEVERETO_SESSION_SAVE_HANDLER=files \
    CHEVERETO_SESSION_SAVE_PATH=/tmp

RUN set -eux; \
    { \
    echo "log_errors = On"; \
    echo "error_log = /dev/stderr"; \
    echo "upload_max_filesize = 25M"; \
    echo "post_max_size = 25M"; \
    echo "max_execution_time = 30"; \
    echo "memory_limit = 512M"; \
    } > $PHP_INI_DIR/conf.d/php.ini

RUN set -eux; \
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
    echo "  'db_pdo_attrs' => [],"; \
    echo "  'debug_level' => 3,"; \
    echo "];"; \
    } > /var/www/html/app/settings.php

RUN chown www-data: /var/www/html -R
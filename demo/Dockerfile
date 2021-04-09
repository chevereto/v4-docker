FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    ssl-cert \
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
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip opcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && php -m  \
    && a2enmod rewrite

ENV CHEVERETO_SERVICING=docker \
    CHEVERETO_DB_HOST=demo-mariadb \
    CHEVERETO_DB_USER=chevereto \
    CHEVERETO_DB_PASS=user_database_password \
    CHEVERETO_DB_NAME=chevereto \
    CHEVERETO_DB_TABLE_PREFIX=chv_ \
    CHEVERETO_DB_PORT=3306 \
    CHEVERETO_DB_DRIVER=mysql \
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

RUN curl -S -o /var/www/html/installer.php -L "https://raw.githubusercontent.com/chevereto/installer/master/installer.php" \
    && php installer.php -a download -s chevereto-free \
    && php installer.php -a extract -s chevereto-free -p $(pwd) -f chevereto-pkg-*.zip

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

ARG CACHEBUST=1
RUN echo "$CACHEBUST"
RUN curl -S -o /var/www/html/importing/importing.tar.gz -L "https://codeload.github.com/Chevereto/demo-importing/tar.gz/refs/heads/main"

RUN tar -xf /var/www/html/importing/importing.tar.gz -C /var/www/html/importing/ \
    && rm -rf /var/www/html/importing/importing.tar.gz \
    && mv /var/www/html/importing/demo-importing-main/* /var/www/html/importing \
    && rm -rf /var/www/html/importing/demo-importing-main

RUN chown www-data: /var/www/html -R
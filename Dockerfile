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
    && docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && php -m \
    && a2enmod ssl \
    && a2enmod rewrite \
    && a2ensite default-ssl.conf

VOLUME /var/www/html/
VOLUME /var/www/html/images
VOLUME /var/www/html/importing/no-parse
VOLUME /var/www/html/importing/parse-albums
VOLUME /var/www/html/importing/parse-users

EXPOSE 80 443

ENV CHEVERETO_SERVICING docker

ENV CHEVERETO_DB_HOST mariadb
ENV CHEVERETO_DB_USER chevereto
ENV CHEVERETO_DB_PASS user_database_password
ENV CHEVERETO_DB_NAME chevereto
ENV CHEVERETO_DB_TABLE_PREFIX chv_
ENV CHEVERETO_DB_PORT 3306
ENV CHEVERETO_DB_DRIVER mysql

ENV CHEVERETO_SESSION_SAVE_HANDLER files
ENV CHEVERETO_SESSION_SAVE_PATH /tmp

ENV CHEVERETO_UPLOAD_MAX_FILESIZE 25M
ENV CHEVERETO_POST_MAX_SIZE 25M
ENV CHEVERETO_MAX_EXECUTION_TIME 30
ENV CHEVERETO_MEMORY_LIMIT 512M

RUN echo "upload_max_filesize = \${CHEVERETO_UPLOAD_MAX_FILESIZE}" >> $PHP_INI_DIR/conf.d/php.ini
RUN echo "post_max_size = \${CHEVERETO_POST_MAX_SIZE}" >> $PHP_INI_DIR/conf.d/php.ini
RUN echo "max_execution_time = \${CHEVERETO_MAX_EXECUTION_TIME}" >> $PHP_INI_DIR/conf.d/php.ini
RUN echo "memory_limit = \${CHEVERETO_MEMORY_LIMIT}" >> $PHP_INI_DIR/conf.d/php.ini
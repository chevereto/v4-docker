FROM debian:buster

VOLUME /var/www/html/
VOLUME /var/www/html/images
VOLUME /var/www/html/importing/no-parse
VOLUME /var/www/html/importing/parse-albums
VOLUME /var/www/html/importing/parse-users

RUN apt-get update -y \
    && apt-get -y install apache2 

COPY apache.conf /etc/apache2/sites-available/000-default.conf

RUN a2dismod mpm_prefork 
RUN a2enmod actions proxy_fcgi rewrite

COPY apache2-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/apache2-foreground

ENV CHEVERETO_SERVICING=docker \
    CHEVERETO_DB_HOST=mariadb \
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

EXPOSE 80
CMD ["apache2-foreground"]
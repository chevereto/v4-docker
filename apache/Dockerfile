FROM debian:buster

VOLUME /var/www/html/
VOLUME /var/www/html/images
VOLUME /var/www/html/importing/no-parse
VOLUME /var/www/html/importing/parse-albums
VOLUME /var/www/html/importing/parse-users

RUN apt-get update -y
RUN apt-get install apache2 -y

COPY apache.conf /etc/apache2/sites-available/000-default.conf

RUN a2dismod mpm_prefork 
RUN a2enmod actions proxy_fcgi rewrite

COPY apache2-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/apache2-foreground

EXPOSE 80
CMD ["apache2-foreground"]
# !/usr/bin/bash
echo '* Building v3-httpd-php'
docker build -t chevereto:v3-httpd-php httpd-php
echo '* Building v3-demo'
docker build -t chevereto:v3-demo demo
echo '* Building v3-httpd'
docker build -t chevereto:v3-httpd httpd
echo '* Building v3-php-fpm'
docker build -t chevereto:v3-php-fpm php-fpm
echo '\n💯 Chevereto imagenery done!'

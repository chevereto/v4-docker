# !/usr/bin/bash

docker rm chv-php-fpm -f
docker build -t chevereto:v3-php-fpm php-fpm
docker run -it \
    --name chv-php-fpm \
    --network chv-network \
    --network-alias php \
    --mount src="/var/www/html/chevereto.loc/installer",target=/var/www/html,type=bind \
    chevereto:v3-php-fpm

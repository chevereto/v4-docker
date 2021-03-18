# !/usr/bin/bash

docker rm chv-apache-php -f
docker build -t chevereto:v3-apache-php apache-php
docker run -it \
    --name chv-apache-php \
    --network chv-network \
    --network-alias apache-php \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    -p 8000:80 \
    chevereto:v3-apache-php

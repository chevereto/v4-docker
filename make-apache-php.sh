# !/usr/bin/bash

docker rm chv-apache-php -f
docker build -t chevereto:v3-apache-php apache-php
docker run -it \
    --name chv-apache-php \
    --network chv-network \
    --network-alias apache-php \
    --mount src="/var/www/html/chevereto.loc/installer",target=/var/www/html,type=bind \
    -p 8000:80 \
    chevereto:v3-apache-php

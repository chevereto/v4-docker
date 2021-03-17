# !/usr/bin/bash

docker rm chv-apache-php -f
docker build -t chevereto:v3-apache-php apache-php
docker run -it \
    --name chv-apache-php \
    --network chv-network \
    --network-alias apache-php \
    -p 4430:443 -p 8111:80 \
    --mount src="/var/www/html/chevereto.loc/installer",target=/var/www/html,type=bind \
    chevereto:v3-apache-php

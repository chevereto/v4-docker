# !/usr/bin/bash

docker rm chv-apache -f
docker build -t chevereto:v3-apache apache
docker run -it \
    --name chv-apache \
    --network chv-network \
    --network-alias apache \
    --mount src="/var/www/html/chevereto.loc/installer",target=/var/www/html,type=bind \
    -p 8080:80 \
    chevereto:v3-apache

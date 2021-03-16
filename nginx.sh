# !/usr/bin/bash

docker rm chv-nginx -f
docker build -t chevereto:v3-nginx nginx
docker run -it \
    --name chv-nginx \
    --network chv-network \
    --network-alias webserver \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    -p 8000:80 \
    chevereto:v3-nginx

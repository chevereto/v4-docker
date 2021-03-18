# nginx

```sh
docker run -d \
    --name chv-nginx \
    --network chv-network \
    --network-alias nginx \
    --volumes-from chv-php-fpm \
    --mount src="$(pwd)/nginx/nginx.conf",target=/etc/nginx/conf.d/default.conf,type=bind \
    -p 8010:80 \
    nginx:1
```

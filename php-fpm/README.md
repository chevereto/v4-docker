# nginx

```sh
docker run -d \
    --name chv-php-fpm \
    --network chv-network \
    --network-alias nginx \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    --mount src="$(pwd)/nginx/nginx.conf",target=/etc/nginx/conf.d/default.conf,type=bind \
    -p 8010:80 \
    chevereto:v3-php-fpm
```

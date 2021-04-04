# php-fpm

## Build

```sh
docker build -t chevereto:v3-php-fpm . 
```

## Run

```sh
docker run -d \
    --name chv-php-fpm \
    --network chv-network \
    --network-alias php \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    -p 8010:80 \
    chevereto:v3-php-fpm
```

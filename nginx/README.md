# nginx

```sh
docker run -d \
    --name chv-nginx \
    --network chv-network \
    --network-alias nginx \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    -p 8010:80 \
    chevereto:v3-nginx
```

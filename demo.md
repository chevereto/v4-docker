# demo

## Run

```sh
docker run -d \
    -p 8000:80 \
    --name chv-demo-free \
    --network chv-network \
    -e "CHEVERETO_DB_HOST=demo-mariadb" \
    -e "CHEVERETO_DB_USER=chevereto" \
    -e "CHEVERETO_DB_PASS=user_database_password" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_TABLE_PREFIX=chv_" \
    -e "CHEVERETO_DB_PORT=3306" \
    -e "CHEVERETO_DB_DRIVER=mysql" \
    --mount src="/var/www/html/chevereto.loc/public_html",target=/var/www/html,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/images",target=/var/www/html/images,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/no-parse",target=/var/www/html/importing/no-parse,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-albums",target=/var/www/html/importing/parse-albums,type=bind \
    --mount src="/var/www/html/chevereto.loc/public_html/importing/parse-users",target=/var/www/html/importing/parse-users,type=bind \
    chevereto/demo
```

## Deploy

See working examples at [demo.sh](../bin/demo.sh) & [demo-free.sh](../bin/demo-free.sh).

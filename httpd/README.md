# httpd

```sh
docker run -d \
    --name chv-httpd \
    --network chv-network \
    --network-alias httpd \
    --volumes-from chv-php-fpm \
    --mount src="$(pwd)/httpd/httpd.conf",target=/etc/apache2/sites-available/000-default.conf,type=bind \
    -p 8000:80 \
    chevereto:v3-httpd
```

# httpd

## Build

```sh
docker build -t chevereto:v3-httpd . 
```

## Run

```sh
docker run -d \
    -p 8000:80 \
    --name chv-httpd \
    --network chv-network \
    --network-alias httpd \
    --volumes-from chv-php-fpm \
    --mount src="$(pwd)/httpd/httpd.conf",target=/etc/apache2/sites-available/000-default.conf,type=bind \
    chevereto:v3-httpd
```

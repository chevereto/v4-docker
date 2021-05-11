# httpd-php

## Build

```sh
docker build -t chevereto/servicing:v3-httpd-php . 
```

## Run

```sh
docker run -d \
    -p 8008:80 \
    --name chv-dev \
    --network chv-network \
    --network-alias dev \
    chevereto/servicing:v3-httpd-php
```

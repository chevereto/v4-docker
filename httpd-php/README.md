# httpd-php

```sh
docker run -d \
    -p 8008:80 \
    --name chv-dev \
    --network chv-network \
    --network-alias dev \
    chevereto:v3-httpd-php
```

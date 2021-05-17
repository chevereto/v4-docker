#!/usr/bin/env bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT="$(dirname $DIR)"
echo '* Building chevereto/servicing:v3-httpd-php'
echo "docker build -t chevereto/servicing:v3-httpd-php . -f $PROJECT/httpd-php.Dockerfile"
docker build -t chevereto/servicing:v3-httpd-php . -f "$PROJECT/"httpd-php.Dockerfile
echo '* Building v3-php-fpm'
docker build -t chevereto/servicing:v3-php-fpm . -f "$PROJECT/"php-fpm.Dockerfile
echo '* Building chevereto/demo:latest'
docker build -t chevereto/demo:latest . -f "$PROJECT/"demo.Dockerfile
printf '[OK] Chevereto imagenery done!\n'

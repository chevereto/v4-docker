#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT="$(dirname $DIR)"
echo '* Building v3-httpd-php'
docker build -t chevereto:v3-httpd-php "$PROJECT/"httpd-php
RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi
echo '* Building v3-demo'
docker build -t chevereto:v3-demo "$PROJECT/"demo
RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi
echo '* Building v3-httpd'
docker build -t chevereto:v3-httpd "$PROJECT/"httpd
RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi
echo '* Building v3-php-fpm'
docker build -t chevereto:v3-php-fpm "$PROJECT/"php-fpm
RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi
printf '[OK] Chevereto imagenery done!\n'

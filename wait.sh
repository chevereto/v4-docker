#!/usr/bin/env bash
set -e
while
    STATUS=$(docker inspect --format "{{.State.Health.Status}}" $1)
    [ $STATUS != "healthy" ]
do
    echo "[* $STATUS] Waiting for $1..."
    sleep 5
done

#!/bin/bash

PROJ=jilaidai-api
REGISTRY=127.0.0.1:5000

if [ $# < 1 ]; then
    echo "version lost"
    exit
fi

num=`docker images | grep $REGISTRY | grep $1 | wc -l`
if [ $num -lt 1 ]; then
    docker pull $REGISTRY/$PROJ:$1
    
    num=`docker images | grep $REGISTRY | grep $1 | wc -l`
    if [ $num -lt 1 ]; then
        echo "image not exist: $REGISTRY/$PROJ:$1"
        exit
    fi
fi

docker rm -f $PROJ
docker run --name $PROJ \
    --restart=always \
    -p 81:80 \
    -p 8081:8080 \
    -v /home/docker/$PROJ/syslog:/data/log \
    -v /home/docker/$PROJ/runtime:/data/www/runtime \
    -v /home/docker/webimg/uploads:/data/www/uploads \
    -d $REGISTRY/$PROJ:$1



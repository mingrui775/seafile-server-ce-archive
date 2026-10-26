#!/bin/bash

if [[ $# != 1 ]]; then
    echo ''
    echo 'Usage: ./seafile-docker-build.sh $version'
    echo ''
    exit 0
fi

version=$1

docker build \
    -f docker/Dockerfile \
    --build-arg server_version=${version} \
    -t seafile-server-ce:${version} .

exit $?
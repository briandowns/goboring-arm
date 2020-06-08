#!/bin/sh

set -e

if [ "${DEBUG}" = 1 ]; then
    set -x
fi

DOCKER="$(command -v docker)"
if [ -z "${DOCKER}" ]; then
    echo "error: docker command not found"
    exit 1
fi

GO_VERSION=1.14.1
ARM64_IMAGE=arm64v8/ubuntu
ARM32v7_IMAGE=armhf/ubuntu

case "${ARM_VERSION}" in
    armv5|armv6|armv7)
        ${DOCKER} build -t BUILD_IMAGE=${} briandowns/goboring:${GO_VERSION}-arm .
    ;;
    *)
        echo "error: unrecognized arm version"
        exit 1
    ;;
esac



exit 0

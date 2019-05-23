#!/bin/bash

set -eu

ISTIO_EXPECTED_PATH=/go/src/istio.io/istio
# Istio's Makefile is particular about where Istio is built.
# This path can be seen in the Istio Makefile's check-tree target.
sudo mkdir -p ${ISTIO_EXPECTED_PATH}
sudo cp -r . ${ISTIO_EXPECTED_PATH}
cd ${ISTIO_EXPECTED_PATH}

# Permissions are all over the place. 
# TODO(spike): fix w/minimal perms
sudo chmod 777 -R /go/

# This container can't apt-get what it needs to build because it can't resolve DNS
# within the container
sed -i '/^docker\.proxy_init: pilot/a \
docker.proxy_init: BUILD_ARGS=--network=host \
'  ./tools/istio-docker.mk

sudo apt-get install -y make golang-go
make sync
export GOPATH=/go
make docker.all
make test/local/auth/e2e_simple

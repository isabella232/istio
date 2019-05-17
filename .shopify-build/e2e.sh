#!/bin/bash

set -eu

make sync
make docker.all
docker images
sudo minikube stop
bin/testEnvRootMinikube.sh
make test/local/auth/e2e_simple

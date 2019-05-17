#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "/buildkite/scripts/pipa_build_tools.bash"

ISTIO_EXPECTED_PATH=/go/src/istio.io/istio
ARTIFACT_OUT_DIR=/go/out/linux_amd64/release

# Download Istio binaries from the previous build step and put in the right place.
# If these files are not exactly where the Makefile target expects them to be, then
# Make will attempt to rebuild them which won't work as Go is not available within the
# Pipa container.
mkdir -p ${ARTIFACT_OUT_DIR}
from_buildkite linux_amd64/release/* /go/out/

# Istio's Makefile is particular about where Istio is built.
# This path can be seen in the Istio Makefile's check-tree target.
mkdir -p ${ISTIO_EXPECTED_PATH}
cp -r . ${ISTIO_EXPECTED_PATH}
cd ${ISTIO_EXPECTED_PATH}

# Bunch of other targets the Makefile thinks should be there but aren't actually needed for
# building the necessary Istio control plane images. If it doesn't find them it will attempt to
# rebuild them and fail due to not having Go installed.
for target in pkg-test-application-echo-client pkg-test-application-echo-server mixer-test-policybackend hyperistio servicegraph; do
  touch ${ARTIFACT_OUT_DIR}/${target}
done

HUB="gcr.io/shopify-docker-images/istio"
TAG=${BUILDKITE_BRANCH}-test

# We have to trick the Makefile into thinking Go is installed somewhere,
# otherwise it will refuse to run even though we are only building Docker images.
# This make target builds all the docker images without rebuilding binaries
GO="/usr/local/bin/go" TAG=${TAG} HUB=${HUB} make docker.all

# We need to strip the gcr.io prefix (cut -d / -f2-) from the name as Pipa re-prepends it
docker images | grep "${TAG}" | awk '{print $1}' | cut -d / -f2- | xargs -I {} pipa image push -n {} -t "${TAG}"

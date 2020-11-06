#!/bin/bash
#
# Build and tag production OpenCSPM Docker images
#
set -exu
source .dockerdev/docker-development.env

# Build
docker build -f ${DOCKER_FILE} -t ${BASE_TAG}:${VERSION} .

# Tag
docker tag ${BASE_TAG}:${VERSION} ${GCR_TAG}
docker tag ${BASE_TAG}:${VERSION} ${ECR_TAG}

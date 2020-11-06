#!/bin/bash
#
# Push production OpenCSPM Docker images
#
set -exu
source .dockerdev/docker-development.env

# Push
docker push ${GCR_TAG}
docker push ${ECR_TAG}

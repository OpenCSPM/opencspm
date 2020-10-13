#!/usr/bin/env bash
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/opencspm-collection.json
IMAGE="opencspm/k8s-cai-exporter"
TAG="$(cat version)"

GCS_BUCKET_NAME="darkbit-collection-us-cspm"
GCS_BUCKET_FOLDER="k8s"
PORT=9090

docker run --rm --net=host \
-p ${PORT}:8080 \
-e GCS_BUCKET_NAME="${GCS_BUCKET_NAME}" \
-e GCS_BUCKET_FOLDER="${GCS_BUCKET_FOLDER}" \
-e K_SERVICE=dev \
-e K_CONFIGURATION=dev \
-e K_REVISION=dev-00001 \
-e GOOGLE_APPLICATION_CREDENTIALS=/tmp/keys/credentials.json \
-v $GOOGLE_APPLICATION_CREDENTIALS:/tmp/keys/credentials.json:ro \
-v /Users/bg/.kube/config:/root/.kube/config:ro \
"gcr.io/${IMAGE}:${TAG}"

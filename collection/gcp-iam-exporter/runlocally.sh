#!/usr/bin/env bash
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/opencspm-collection.json
IMAGE="opencspm/gcp-iam-exporter"
TAG="$(cat version)"

CAI_PARENT_PATH="organizations/1071234196403"
GCS_BUCKET_NAME="darkbit-collection-us-cspm"
GCS_BUCKET_FOLDER="iam"
PORT=9090

docker run \
-p ${PORT}:8080 \
-e CAI_PARENT_PATH="${CAI_PARENT_PATH}" \
-e GCS_BUCKET_NAME="${GCS_BUCKET_NAME}" \
-e GCS_BUCKET_FOLDER="${GCS_BUCKET_FOLDER}" \
-e K_SERVICE=dev \
-e K_CONFIGURATION=dev \
-e K_REVISION=dev-00001 \
-e GOOGLE_APPLICATION_CREDENTIALS=/tmp/keys/credentials.json \
-v $GOOGLE_APPLICATION_CREDENTIALS:/tmp/keys/credentials.json:ro \
"gcr.io/${IMAGE}:${TAG}"

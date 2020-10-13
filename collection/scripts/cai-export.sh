#!/usr/bin/env bash

ORGANIZATION_ID="<replaceme>" # run `gcloud organizations list` and use the number
EXPORTTIME="$(date +%s)"
GCS_BUCKET_PATH="gs://<replaceme>/" # run `gsutil ls` and get the path with the trailing slash

for TYPE in resource iam-policy org-policy access-policy; do
  gcloud beta asset export --organization="$ORGANIZATION_ID" --output-path="${GCS_BUCKET_PATH}${EXPORTTIME}-${TYPE}.json" --content-type="${TYPE}"
done

sleep 30
gsutil cp "${GCS_BUCKET_PATH}"/${EXPORTTIME}-resource.json ../assets
gsutil cp "${GCS_BUCKET_PATH}"/${EXPORTTIME}-iam-policy.json ../assets
gsutil cp "${GCS_BUCKET_PATH}"/${EXPORTTIME}-org-policy.json ../assets
gsutil cp "${GCS_BUCKET_PATH}"/${EXPORTTIME}-access-policy.json ../assets

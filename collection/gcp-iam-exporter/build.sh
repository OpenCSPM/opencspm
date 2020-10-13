#!/usr/bin/env bash

IMAGE="opencspm/gcp-iam-exporter"
TAG="$(cat version)"

gcloud builds submit --tag "gcr.io/${IMAGE}:${TAG}"

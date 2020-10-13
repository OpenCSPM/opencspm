#!/usr/bin/env bash

IMAGE="opencspm/k8s-cai-exporter"
TAG="$(cat version)"

gcloud builds submit --tag "gcr.io/${IMAGE}:${TAG}"

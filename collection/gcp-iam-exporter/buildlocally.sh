#!/usr/bin/env bash

IMAGE="opencspm/gcp-iam-exporter"
TAG="$(cat version)"

docker build --tag "gcr.io/${IMAGE}:${TAG}" .

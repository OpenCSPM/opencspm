#!/usr/bin/env bash

IMAGE="opencspm/gcp-cai-exporter"
TAG="$(cat version)"

docker build --tag "gcr.io/${IMAGE}:${TAG}" .

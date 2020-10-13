#!/usr/bin/env bash

IMAGE="opencspm/k8s-cai-exporter"
TAG="$(cat version)"

docker build --tag "gcr.io/${IMAGE}:${TAG}" .

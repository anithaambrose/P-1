#!/bin/bash
set -e

IMAGE="anitodevops/app-image:latest"

echo "Building Docker ${IMAGE}"
docker build -t "${IMAGE}" .

echo "Pushing Docker ${IMAGE} to Registry"
docker push ${IMAGE}


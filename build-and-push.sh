#!/usr/bin/env bash
set -euo pipefail

repo="${1:?Pass the ECR repository URI}"
version="${2:-v2}"
region="us-east-1"
dir="$(cd "$(dirname "$0")" && pwd)"

aws ecr get-login-password --region "$region" |
  docker login --username AWS --password-stdin "${repo%%/*}"

for image in ollama open-webui prometheus grafana; do
  docker buildx build \
    --platform linux/amd64 \
    -t "$repo:$image-$version" \
    --push \
    "$dir/$image"
done
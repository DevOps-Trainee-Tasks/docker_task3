#!/usr/bin/env bash
set -euo pipefail

repo="${1:?Pass the ECR URI prefix (ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/task3)}"
tag="${2:?Pass a new image tag (for example, v6)}"
region="us-east-1"
dir="$(cd "$(dirname "$0")" && pwd)"

aws ecr get-login-password --region "$region" |
  docker login --username AWS --password-stdin "${repo%%/*}"

for image in ollama open-webui prometheus grafana db-init ecs-exporter log-router; do
  docker buildx build \
    --platform linux/amd64 \
    --tag "$repo/$image:$tag" \
    --push \
    "$dir/$image"
done
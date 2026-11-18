#!/bin/sh
set -eu

AZ=$(curl -fsS "${ECS_CONTAINER_METADATA_URI_V4}/task" | jq -er '.AvailabilityZone')
export AZ

exec /entrypoint.sh
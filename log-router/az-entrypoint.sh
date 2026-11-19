#!/bin/sh
set -eu

TASK=$(curl -fsS "${ECS_CONTAINER_METADATA_URI_V4}/task")
AZ=$(printf '%s' "$TASK" | jq -er '.AvailabilityZone')
FAMILY=$(printf '%s' "$TASK" | jq -er '.Family')
SERVICE=${FAMILY#task3-}

cat > /extra.conf <<EOF
[OUTPUT]
    Name  file
    Match *firelens*
    Path  /logs/$AZ
    Mkdir true

[OUTPUT]
    Name  cloudwatch_logs
    Match *firelens*
    region us-east-1
    log_group_name /ecs/task3/$SERVICE
    log_stream_prefix firelens-
    log_key log
EOF

exec /entrypoint.sh
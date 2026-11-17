#!/bin/sh
set -eu

until pg_isready; do
  sleep 3
done

psql -v ON_ERROR_STOP=1 \
  -v "dbuser=$WEBUI_DB_USERNAME" \
  -v "dbpass=$WEBUI_DB_PASSWORD" \
  -f /init.sql
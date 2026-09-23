#!/bin/sh
set -eu

POSTGRES_PASSWORD="$(cat /run/secrets/postgres_password)"

export DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"

exec dbmate "$@"

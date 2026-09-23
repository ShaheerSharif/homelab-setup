#!/bin/sh
set -e

exec valkey-server /usr/local/valkey/valkey.conf \
  --requirepass "$(cat /run/secrets/valkey_password)"

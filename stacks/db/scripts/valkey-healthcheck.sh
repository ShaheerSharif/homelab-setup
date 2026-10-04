#!/bin/sh
set -e

exec valkey-cli -p 6380 -a "$(cat /run/secrets/valkey_password)" ping

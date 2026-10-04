#!/usr/bin/env bash
set -euo pipefail

STACKS="stacks"
ENV_FILE=".env"

# Preflight: must be run from the project root
[[ -d $STACKS ]]   || { echo "ERROR: '$STACKS' directory not found in $PWD" >&2; exit 1; }
[[ -f $ENV_FILE ]] || { echo "ERROR: '$ENV_FILE' file not found in $PWD" >&2; exit 1; }

# dc <compose-file> <args...>  (project name = the compose file's directory name)
dc() {
  local file=$1; shift
  docker compose --env-file "$ENV_FILE" -p "$(basename "$(dirname "$file")")" -f "$file" "$@"
}

# Best-effort start: warn and continue
up_optional() {
  dc "$1" up -d || echo "WARN: $1 failed to start" >&2
}

ensure_network() {  # ensure_network <name> [extra create flags]
  docker network inspect "$1" >/dev/null 2>&1 || docker network create "${@:2}" "$1" >/dev/null
}

# Shared networks (owned by this script, declared external in the compose files)
ensure_network homelab_postgres-net --internal
ensure_network homelab_valkey-net --internal
ensure_network homelab_internal-net --internal
ensure_network homelab_socket-proxy-net --internal
ensure_network homelab_external-net

# 1. Databases: any failure aborts the whole script (set -e)
DB="$STACKS/db/compose.db.yml"
dc "$DB" up -d --wait postgres valkey
dc "$DB" run --rm migrate

# 2. Socket proxy
up_optional "$STACKS/socket-proxy/compose.socket-proxy.yml"

# 3. Utils (tika, gotenberg)
up_optional "$STACKS/utils/compose.utils.yml"

# 4. Services, any order, failures tolerated
for f in "$STACKS"/sso/compose.*.yml "$STACKS"/services/*/compose.*.yml; do
  [[ -f $f ]] || continue
  up_optional "$f"
done

# 5. nginx last
up_optional "$STACKS/server/compose.server.yml"

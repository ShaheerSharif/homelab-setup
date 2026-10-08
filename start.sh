#!/usr/bin/env bash
set -euo pipefail

STACKS="stacks"
ENV_FILE=".env"

usage() {
  echo "Usage: $0 [-b] [-f]"
  echo "  -b  rebuild images before starting"
  echo "  -f  rebuild images with --no-cache before starting (implies -b)"
}

BUILD=false
NO_CACHE=false
while getopts "bfh" opt; do
  case $opt in
    b) BUILD=true ;;
    f) BUILD=true; NO_CACHE=true ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

# Preflight: must be run from the project root
[[ -d $STACKS ]]   || { echo "ERROR: '$STACKS' directory not found in $PWD" >&2; exit 1; }
[[ -f $ENV_FILE ]] || { echo "ERROR: '$ENV_FILE' file not found in $PWD" >&2; exit 1; }

# dc <compose-file> <args...>  (project name = the compose file's directory name)
dc() {
  local file=$1; shift
  docker compose --env-file "$ENV_FILE" -p "$(basename "$(dirname "$file")")" -f "$file" "$@"
}

# Rebuild a stack's images if -b/-f was given (no-op for services without a build section)
build_stack() {
  $BUILD || return 0
  echo ">> Build: $1"
  if $NO_CACHE; then
    dc "$1" build --no-cache
  else
    dc "$1" build
  fi
}

# Best-effort start: warn and continue
up_optional() {
  { build_stack "$1" && dc "$1" up -d; } || echo "WARN: $1 failed to build or start" >&2
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
build_stack "$DB"
dc "$DB" up -d --wait postgres valkey
dc "$DB" run --rm migrate

# 2. Socket proxy
SOCKET_PROXY="$STACKS/socket-proxy/compose.socket-proxy.yml"
build_stack "$SOCKET_PROXY"
dc "$SOCKET_PROXY" up -d --wait socket-proxy

# 3. Utils (tika, gotenberg)
up_optional "$STACKS/utils/compose.utils.yml"

# 4. SSO (authentik)
up_optional "$STACKS/sso/compose.sso.yml"

# 5. Services, any order, failures tolerated
for f in "$STACKS"/services/*/compose.*.yml; do
  [[ -f $f ]] || continue
  up_optional "$f"
done

# 6. nginx last
up_optional "$STACKS/server/compose.server.yml"

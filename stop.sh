#!/usr/bin/env bash
set -uo pipefail   # no -e: keep going if one stack fails to come down

STACKS="stacks"
ENV_FILE=".env"

usage() {
  echo "Usage: $0 [-v] [-y]"
  echo "  -v  also delete named volumes (DESTROYS DATA)"
  echo "  -y  skip the confirmation prompt for -v"
}

REMOVE_VOLUMES=false
ASSUME_YES=false
while getopts "vyh" opt; do
  case $opt in
    v) REMOVE_VOLUMES=true ;;
    y) ASSUME_YES=true ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

# Preflight: must be run from the project root
[[ -d $STACKS ]]   || { echo "ERROR: '$STACKS' directory not found in $PWD" >&2; exit 1; }
[[ -f $ENV_FILE ]] || { echo "ERROR: '$ENV_FILE' file not found in $PWD" >&2; exit 1; }

# Confirm destructive action
if $REMOVE_VOLUMES && ! $ASSUME_YES; then
  echo "This will delete the named volumes of every stack (databases, paperless data, etc.)."
  read -r -p "Type 'yes' to continue: " answer
  [[ $answer == yes ]] || { echo "Aborted."; exit 1; }
fi

DOWN_FLAGS=()
$REMOVE_VOLUMES && DOWN_FLAGS+=(-v)

FAILED=()

# dc <compose-file> <args...>  (project name = the compose file's directory name)
dc() {
  local file=$1; shift
  docker compose --env-file "$ENV_FILE" -p "$(basename "$(dirname "$file")")" -f "$file" "$@"
}

down() {
  local f=$1
  [[ -f $f ]] || return 0
  echo ">> Down: $f"
  dc "$f" down "${DOWN_FLAGS[@]}" || { echo "WARN: $f failed to go down" >&2; FAILED+=("$f"); }
}

# Reverse of start order

# 1. nginx
down "$STACKS/server/compose.server.yml"

# 2. SSO (authentik)
down "$STACKS/sso/compose.sso.yml"

# 3. Services
for f in "$STACKS"/services/*/compose.*.yml; do
  down "$f"
done

# 4. Utils
down "$STACKS/utils/compose.utils.yml"

# 5. Socket proxy
down "$STACKS/socket-proxy/compose.socket-proxy.yml"

# 6. Databases last
down "$STACKS/db/compose.db.yml"

# 7. Shared networks (created by start.sh, external in the compose files, so
#    `down` doesn't remove them). Fails harmlessly if something is still attached.
for n in homelab_postgres-net homelab_valkey-net homelab_internal-net \
         homelab_socket-proxy-net homelab_external-net; do
  docker network rm "$n" >/dev/null 2>&1 && echo ">> Removed network $n"
done

if ((${#FAILED[@]})); then
  echo "Finished with failures:" >&2
  printf '  %s\n' "${FAILED[@]}" >&2
  exit 1
fi
echo "Done."

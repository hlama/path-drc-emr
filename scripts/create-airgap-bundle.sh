#!/usr/bin/env bash
# Creates an air-gapped bundle of Docker images referenced by a docker-compose file.
#
# The bundle is a .tgz containing:
#   - one .tar per image (created via `docker save`)
#   - load-images.sh: a script that runs `docker load` for each tar on the target host
#
# Usage: create-airgap-bundle.sh <compose-file> <output-bundle.tgz>

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <compose-file> <output-bundle.tgz>" >&2
  exit 1
fi

COMPOSE_FILE="$1"
OUTPUT_BUNDLE="$2"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

for cmd in yq docker tar; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command not found: $cmd" >&2
    exit 1
  fi
done

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# yq here is mikefarah/yq (v4). Null entries (services with `build:` and no `image:`)
# are emitted literally as "null"; filter and de-duplicate them.
mapfile -t IMAGES < <(yq '.services[].image' "$COMPOSE_FILE" | grep -vx 'null' | awk 'NF' | sort -u)

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "No images found in $COMPOSE_FILE" >&2
  exit 1
fi

echo "Found ${#IMAGES[@]} image(s):"
printf '  %s\n' "${IMAGES[@]}"

LOAD_SCRIPT="$WORK_DIR/load-images.sh"
{
  echo '#!/usr/bin/env bash'
  echo 'set -euo pipefail'
  echo 'cd "$(dirname "$0")"'
} > "$LOAD_SCRIPT"

for IMAGE in "${IMAGES[@]}"; do
  TAR_NAME="$(printf '%s' "$IMAGE" | tr '/:' '__').tar"
  echo "Pulling $IMAGE"
  docker pull "$IMAGE"
  echo "Saving $IMAGE -> $TAR_NAME"
  docker save -o "$WORK_DIR/$TAR_NAME" "$IMAGE"
  printf 'docker load -i %q\n' "$TAR_NAME" >> "$LOAD_SCRIPT"
done

chmod +x "$LOAD_SCRIPT"

tar -czf "$OUTPUT_BUNDLE" -C "$WORK_DIR" .

echo "Bundle created: $OUTPUT_BUNDLE"

#!/bin/sh

DIR="$(cd -P "$(dirname "$0")" && pwd)"
MOUNT_DIR="$(dirname "$DIR")"

# Remove stale container from a previous crashed run (handles "name already in use")
docker rm -f syfraava 2>/dev/null || true

# Only pass --platform linux/amd64 on ARM machines (Apple Silicon, Raspberry Pi).
# On x86/amd64 the flag is unnecessary and breaks on older Docker versions.
PLATFORM_FLAG=""
case "$(uname -m)" in
    arm64|aarch64) PLATFORM_FLAG="--platform linux/amd64" ;;
esac

# Give the container user (uid 1000) write access to the mounted directory.
setfacl -R -m u:1000:rwx "$MOUNT_DIR" 2>/dev/null || true

# shellcheck disable=SC2086
docker run \
    $PLATFORM_FLAG \
    --name=syfraava \
    --rm \
    --interactive \
    --tty \
    --publish 8888:8888 \
    --publish 9090:9090 \
    --volume "$MOUNT_DIR":/home/jovyan/tp-va \
    mooaa/syfra-va:2

# Restore permissions
setfacl -R -x u:1000 "$MOUNT_DIR" 2>/dev/null || true

#!/usr/bin/env bash

# Mount NBD device inside the Docker container
# This script connects to the host's qemu-nbd server

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Get the script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../common.sh"

# Function to display usage information
usage() {
    cat <<EOF

🚀 mount.sh - Mount NBD device inside the container

Usage:
  $0 [-d <device>] [-p <port>] [-H <host>]

Options:
  -d DEVICE    NBD device path (default: from env or /dev/nbd0)               [OPTIONAL]
  -p PORT      NBD server port (default: from env or 10809)                   [OPTIONAL]
  -H HOST      NBD server host (default: from env or host.docker.internal)    [OPTIONAL]
  -h           Show this help message

Example:
  $0 -d /dev/nbd0 -p 10809

Environment Variables:
  NBD_DEVICE - Device path (injected by start-ventoy.sh)
  NBD_PORT   - Server port (injected by start-ventoy.sh)
  NBD_HOST   - Server host (injected by start-ventoy.sh)

EOF
    exit 1
}

# Use environment variables set by start-ventoy.sh, or defaults
DEVICE="${NBD_DEVICE:-/dev/nbd0}"
PORT="${NBD_PORT:-10809}"
HOST="${NBD_HOST:-host.docker.internal}"

# Parse command-line options (can override environment variables)
while getopts ":p:d:H:h" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    d)
        DEVICE="${OPTARG}"
        ;;
    H)
        HOST="${OPTARG}"
        ;;
    h)
        usage
        ;;
    *)
        usage
        ;;
    esac
done

echo "Connecting to NBD server..."
echo "  Host:   ${HOST}"
echo "  Port:   ${PORT}"
echo "  Device: ${DEVICE}"
echo ""

# Attempt to connect to NBD
if nbd-client "${HOST}" "${PORT}" "${DEVICE}"; then
    echo ""
    echo "✓ NBD device mounted successfully at ${DEVICE}"
    echo ""
    echo "You can now use Ventoy commands with this device:"
    echo "  ./Ventoy2Disk.sh -I ${DEVICE}"
    echo ""
else
    echo ""
    echo "✗ Failed to connect to NBD server"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Ensure start-nbd.sh is running on the host"
    echo "  2. Check the device and port match the NBD server"
    echo "  3. Verify the NBD server is accessible from the container"
    echo ""
    exit 1
fi

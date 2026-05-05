#!/usr/bin/env bash

# Start qemu-nbd server on macOS to export a block device over TCP
# This script must be run as root to access block devices

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Get the script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/scripts/common.sh"

# Function to display usage information
usage() {
    cat <<EOF

🚀 start-nbd.sh - Start qemu-nbd on macOS to export a block device over TCP

Usage:
  sudo $0 -d <device-path> [-p <port>]

Options:
  -d DEVICE    USB drive path to export (e.g., /dev/disk3)         [REQUIRED]
  -p PORT      TCP port to listen on (default: from .env or 10809) [OPTIONAL]
  -h           Show this help message

Example:
  sudo $0 -d /dev/disk3 -p 10809

Notes:
  • This script must be run as root
  • The device will be unmounted before starting qemu-nbd
  • Use 'diskutil list' to find available devices

Environment:
  Configure defaults in .env file in repository root
  See .env.example for all available options

EOF
    exit 1
}

# Load environment configuration
load_env
export_config

# Require root access
require_root "$@"

# Validate environment
validate_os
check_qemu
check_docker

# Parse command-line options (can override .env values)
PORT="${NBD_PORT}"
DEVICE=""

while getopts ":p:d:h" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    d)
        DEVICE="${OPTARG}"
        ;;
    h)
        usage
        ;;
    *)
        usage
        ;;
    esac
done

# Validate inputs
if [[ -z "${DEVICE}" ]]; then
    echo "✗ Device (-d) is required"
    usage
fi

if ! validate_block_device "${DEVICE}"; then
    exit 1
fi

# Unmount the device if mounted
unmount_device "${DEVICE}"

# Start qemu-nbd
echo ""
echo "Starting qemu-nbd on port ${PORT} with device ${DEVICE}..."
echo "✓ NBD server will be accessible at port ${PORT}"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

qemu-nbd --port="${PORT}" --persist -f raw "${DEVICE}"

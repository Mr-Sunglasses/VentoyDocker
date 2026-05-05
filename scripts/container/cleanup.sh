#!/usr/bin/env bash

# Cleanup NBD device inside the Docker container
# This script cleanly detaches the NBD device to prevent data loss

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Get the script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../common.sh"

# Function to display usage information
usage() {
    cat <<EOF

🚀 cleanup.sh - Cleanly detach NBD device

Usage:
  $0 [-d <device>]

Options:
  -d DEVICE    NBD device path to detach (default: from env or /dev/nbd0) [OPTIONAL]
  -h           Show this help message

Example:
  $0 -d /dev/nbd0

Environment Variables:
  NBD_DEVICE - Device path (injected by start-ventoy.sh)

Notes:
  Clean detach is essential to prevent data loss!

EOF
    exit 1
}

# Use environment variable set by start-ventoy.sh, or default
DEVICE="${NBD_DEVICE:-/dev/nbd0}"

# Parse command-line options (can override environment variable)
while getopts ":d:h" opt; do
    case "${opt}" in
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

echo "Detaching NBD device: ${DEVICE}..."
echo ""

# Attempt to detach NBD device
if nbd-client -d "${DEVICE}"; then
    echo ""
    echo "✓ NBD device ${DEVICE} detached successfully"
    echo "🧹 Cleanup complete!"
    echo ""
else
    echo ""
    echo "✗ Failed to detach NBD device ${DEVICE}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check if the device is actually mounted: ls -l ${DEVICE}"
    echo "  2. Verify you're using the correct device path"
    echo "  3. Ensure no processes are using the device"
    echo ""
    exit 1
fi

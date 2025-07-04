#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Function to display usage information
usage() {
    cat <<EOF

🚀 StartNbd.sh - Start qemu-nbd on macOS to export a block device over TCP

Usage:
  sudo $0 -d <device> [-p <port>]

Options:
  -d DEVICE    Block device path to export (e.g., /dev/disk3)   [REQUIRED]
  -p PORT      TCP port to listen on (default: 10809)           [OPTIONAL]

Example:
  sudo $0 -d /dev/disk3 -p 10809

Notes:
  • This script must be run as root.
  • The device will be unmounted before starting qemu-nbd.
  • To disconnect, use:
        nbd-client -d /dev/nbd0

EOF
    exit 1
}

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root. Please use sudo."
    exit 1
fi

# Detect OS
OS="$(uname -s)"
case "$OS" in
Darwin)
    echo "Detected macOS."
    ;;
Linux)
    echo "Detected Linux."
    echo "You can use Ventoy natively on Linux. Refer to:"
    echo "  https://www.ventoy.net/en/doc_start.html"
    exit 0
    ;;
*)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# macOS-only checks
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v qemu-system-x86_64 &>/dev/null; then
        echo "Error: qemu-system-x86_64 not found."
        echo "Install it with: brew install qemu"
        exit 1
    fi
    if ! command -v qemu-nbd &>/dev/null; then
        echo "Error: qemu-nbd not found."
        echo "Install it with: brew install qemu"
        exit 1
    fi
fi

# Check Docker
if ! command -v docker &>/dev/null; then
    echo "Error: Docker not found."
    echo "Install Docker: https://www.docker.com/get-started"
    exit 1
fi

# Defaults
PORT="10809"
DEVICE=""

# Parse options
while getopts ":p:d:" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    d)
        DEVICE="${OPTARG}"
        ;;
    *)
        usage
        ;;
    esac
done

# Validate inputs
if [[ -z "${DEVICE}" ]]; then
    echo "Error: Device (-d) is required."
    usage
fi

if [[ ! -b "${DEVICE}" ]]; then
    echo "Error: Device ${DEVICE} does not exist or is not a block device."
    exit 1
fi

# Unmount the device if mounted
echo "Unmounting device ${DEVICE}..."
diskutil unmountDisk force "${DEVICE}" || {
    echo "Warning: Could not unmount device ${DEVICE} (maybe already unmounted)."
}

# Start qemu-nbd
echo "Starting qemu-nbd on port ${PORT} with device ${DEVICE}..."
qemu-nbd --port="${PORT}" --persist -f raw "${DEVICE}"

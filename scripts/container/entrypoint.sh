#!/usr/bin/env bash

# Entrypoint script for Ventoy container
# Auto-mounts NBD device and sets up cleanup trap

set -uo pipefail

# Use environment variables passed from start-ventoy.sh
DEVICE="${NBD_DEVICE:-/dev/nbd0}"
PORT="${NBD_PORT:-10809}"
HOST="${NBD_HOST:-host.docker.internal}"

# Cleanup function to detach NBD device
cleanup() {
    echo ""
    echo "🧹 Cleaning up NBD connection..."
    if nbd-client -d "${DEVICE}" 2>/dev/null; then
        echo "✓ NBD device ${DEVICE} detached successfully"
    else
        echo "⚠️  NBD device was not mounted or already detached"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Display banner
cat <<'EOF'

==============================================================
🚀 VentoyDocker Container Starting...
==============================================================

EOF

# Verify NBD device exists (should be auto-created by --privileged)
if [ ! -e "${DEVICE}" ]; then
    echo "✗ Error: ${DEVICE} not available"
    echo "Container must be run with --privileged flag"
    echo ""
    echo "Starting shell for manual troubleshooting..."
    exec bash
fi

# Disconnect any existing NBD connection on this device
if nbd-client -d "${DEVICE}" 2>/dev/null; then
    echo "✓ Cleaned up stale NBD connection on ${DEVICE}"
fi

echo "✓ NBD device ${DEVICE} ready"

# Auto-mount NBD device
echo ""
echo "🔗 Connecting to NBD server..."
echo "  Host:   ${HOST}"
echo "  Port:   ${PORT}"
echo "  Device: ${DEVICE}"
echo ""

if nbd-client "${HOST}" "${PORT}" "${DEVICE}"; then
    echo "✓ NBD device mounted successfully at ${DEVICE}"
    echo ""
    echo "--------------------------------------------------------------"
    echo "🌐 Starting VentoyWeb interface..."
    echo ""
    echo "  Access at: http://localhost:${VENTOY_WEB_PORT:-24680}"
    echo ""
    echo "  Alternative CLI usage:"
    echo "    ./Ventoy2Disk.sh -I ${DEVICE}"
    echo ""
    echo "--------------------------------------------------------------"
    echo "ℹ️  NBD device will auto-cleanup when you exit"
    echo "ℹ️  Press Ctrl+C to stop VentoyWeb and exit"
    echo "=============================================================="
    echo ""

    # Start VentoyWeb
    exec ./VentoyWeb.sh -H 0.0.0.0
else
    echo "✗ Failed to connect to NBD server"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Ensure start-nbd.sh is running on the host"
    echo "  2. Check the NBD server is accessible: ${HOST}:${PORT}"
    echo ""
    echo "You can manually retry with:"
    echo "  ./scripts/container/mount.sh"
    echo ""
    echo "Starting shell for manual troubleshooting..."
    exec bash
fi

#!/usr/bin/env bash

# Common functions and configuration loading for VentoyDocker scripts
# This library provides shared functionality across all scripts

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Load environment variables from .env file if it exists
load_env() {
    local env_file="${1:-.env}"
    if [[ -f "${env_file}" ]]; then
        # shellcheck disable=SC1090
        source "${env_file}"
        echo "✓ Loaded configuration from ${env_file}"
    fi
}

# Detect operating system
detect_os() {
    OS="$(uname -s)"
    echo "${OS}"
}

# Check if running on macOS
is_macos() {
    [[ "$(detect_os)" == "Darwin" ]]
}

# Check if running on Linux
is_linux() {
    [[ "$(detect_os)" == "Linux" ]]
}

# Validate OS is supported (macOS only for this project)
validate_os() {
    local os
    os="$(detect_os)"

    case "${os}" in
        Darwin)
            echo "✓ Detected macOS"
            return 0
            ;;
        Linux)
            echo "ℹ️  You can directly use Ventoy on Linux, no need to use Docker."
            echo "   Please refer to: https://www.ventoy.net/en/doc_start.html"
            exit 0
            ;;
        *)
            echo "✗ Unsupported OS: ${os}"
            echo "  This project currently supports macOS only."
            exit 1
            ;;
    esac
}

# Check if QEMU is installed (macOS only)
check_qemu() {
    if ! is_macos; then
        return 0
    fi

    local missing=0

    if ! command -v qemu-system-x86_64 &>/dev/null; then
        echo "✗ qemu-system-x86_64 not found"
        missing=1
    fi

    if ! command -v qemu-nbd &>/dev/null; then
        echo "✗ qemu-nbd not found"
        missing=1
    fi

    if [[ ${missing} -eq 1 ]]; then
        echo ""
        echo "Install QEMU with: brew install qemu"
        exit 1
    fi

    echo "✓ QEMU is installed"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo "✗ Docker not found"
        echo "  Install Docker: https://www.docker.com/get-started"
        exit 1
    fi
    echo "✓ Docker is installed"
}

# Validate that script is run as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "✗ This script must be run as root"
        echo "  Please use: sudo $0 $*"
        exit 1
    fi
}

# Check if a block device exists
validate_block_device() {
    local device="$1"

    if [[ -z "${device}" ]]; then
        echo "✗ Device path is required"
        return 1
    fi

    if [[ ! -b "${device}" ]]; then
        echo "✗ Device ${device} does not exist or is not a block device"
        return 1
    fi

    return 0
}

# Unmount a device (macOS)
unmount_device() {
    local device="$1"

    echo "Unmounting device ${device}..."
    if diskutil unmountDisk force "${device}" 2>/dev/null; then
        echo "✓ Device unmounted successfully"
    else
        echo "⚠️  Could not unmount device (may already be unmounted)"
    fi
}

# Get configuration value with fallback to default
get_config() {
    local var_name="$1"
    local default_value="$2"
    local value="${!var_name:-${default_value}}"
    echo "${value}"
}

# Export common configuration variables with defaults
export_config() {
    export VENTOY_VERSION="${VENTOY_VERSION:-1.1.07}"
    export UBUNTU_VERSION="${UBUNTU_VERSION:-latest}"
    export DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:-ventoy-docker}"
    export DOCKER_CONTAINER_NAME="${DOCKER_CONTAINER_NAME:-ventoy-docker}"
    export VENTOY_WEB_PORT="${VENTOY_WEB_PORT:-24680}"
    export NBD_PORT="${NBD_PORT:-10809}"
    export NBD_DEVICE="${NBD_DEVICE:-/dev/nbd0}"
    export NBD_HOST="${NBD_HOST:-host.docker.internal}"
    export VENTOY_WORK_DIR="${VENTOY_WORK_DIR:-/root/ventoy-${VENTOY_VERSION}}"
    export VENTOY_DOWNLOAD_URL="${VENTOY_DOWNLOAD_URL:-https://github.com/ventoy/Ventoy/releases/download/v${VENTOY_VERSION}/ventoy-${VENTOY_VERSION}-linux.tar.gz}"
}

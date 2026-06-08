#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Function to display usage information
usage() {
    cat <<EOF

🚀 StartVentoy.sh - Start Docker container with ventoy. 

Usage:
  $0 [-p <port>]

Options:
  -p PORT      TCP port for ventoy web (default: 24680) [OPTIONAL]

Example:
  ./$0 -p 8080

EOF
    exit 1
}

# User operating system
OS=$(uname -s)

# check if the os is macos
if [[ "$OS" == "Darwin" ]]; then
    echo "macOS is supported."
elif [[ "$OS" == "Linux" ]]; then
    echo "You can directly use ventoy on Linux, no need to use docker."
    echo "Please refer to the official documentation for installation instructions: https://www.ventoy.net/en/doc_start.html"
    exit 0
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# check if qemu and qemu-nbd is installed  is macos
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v qemu-system-x86_64 &>/dev/null; then
        echo "qemu-system-x86_64 could not be found. Please install QEMU."
        echo "You can install it using Homebrew with the command: brew install qemu"
        exit 1
    fi
    if ! command -v qemu-nbd &>/dev/null; then
        echo "qemu-nbd could not be found. Please install QEMU."
        echo "You can install it using Homebrew with the command: brew install qemu"
        exit 1
    fi
fi

# check if docker is installed
if ! command -v docker &>/dev/null; then
    echo "Docker could not be found. Please install Docker."
    echo "You can download it from https://www.docker.com/get-started"
    exit 1
fi

# Build the Docker image if it is not already built
if ! docker image inspect ventoy-docker:1.1.12 &>/dev/null; then
    echo "Docker image 'ventoy-docker' not found. Building the image..."
    docker build -t ventoy-docker:1.1.12 .
fi

# Check if the build was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Docker image build failed."
    exit 1
fi

# Defaults
PORT="24680"

# Parse options
while getopts ":p:" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    *)
        usage
        ;;
    esac
done

# Run the Docker container
echo "Running the Docker container..."
docker run -it --rm \
    --name ventoy-docker \
    --privileged \
    -p "${PORT}":24680 \
    ventoy-docker:1.1.12 \
    bash \
    -c "
echo ''
echo '=============================================================='
echo '🔗  To connect to NBD from your host, run the following:'
echo ''
echo '    nbd-client host.docker.internal <nbd-port> <nbd-device>'
echo ''
echo '🟢 Example:'
echo '    nbd-client host.docker.internal 10809 /dev/nbd0'
echo ''
echo '📁 Optionally you can run the following script to connect to NBD from your host'
echo ''
echo '    ./scripts/mount.sh'
echo ''
echo '⚠️   Before exiting the container, cleanly detach NBD:'
echo ''
echo '    nbd-client -d /dev/nbd0'
echo ''
echo '🟢 Clean Detach Procedure is essential to avoid data loss.'
echo ''
echo '📁 Optionally you can run the following script cleanly detach NBD'
echo ''
echo '    ./scripts/cleanup.sh'
echo ''
echo '--------------------------------------------------------------'
echo '📢 Important Notes:'
echo ''
echo '✅ Only the Ventoy CLI and Ventoy Web is currently supported in this container.'
echo '❌ Ventoy GUI interface are NOT supported.'
echo ''
echo 'For official documentation, visit: https://www.ventoy.net/en/doc_start.html'
echo '=============================================================='
echo ''
exec bash
"

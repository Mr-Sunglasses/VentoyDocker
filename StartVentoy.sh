#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

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
if ! docker image inspect ventoy-docker:latest &>/dev/null; then
    echo "Docker image 'ventoy-docker' not found. Building the image..."
    docker build -t ventoy-docker .
fi

# Check if the build was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Docker image build failed."
    exit 1
fi

# Run the Docker container
echo "Running the Docker container..."
docker run -it --rm \
    --name ventoy-docker \
    --privileged \
    -p 8080:8080 \
    ventoy-docker \
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
echo '⚠️   Before exiting the container, cleanly detach NBD:'
echo ''
echo '    nbd-client -d /dev/nbd0'
echo ''
echo '🟢 Clean Detach Procedure is essential to avoid data loss.'
echo ''
echo '--------------------------------------------------------------'
echo '📢 Important Notes:'
echo ''
echo '✅ Only the Ventoy CLI is currently supported in this container.'
echo '❌ Ventoy Web interface and GUI tools are NOT supported.'
echo ''
echo 'For official documentation, visit: https://www.ventoy.net/en/doc_start.html'
echo '=============================================================='
echo ''
exec bash
"

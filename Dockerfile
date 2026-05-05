# Build arguments for configuration
ARG UBUNTU_VERSION=latest
ARG VENTOY_VERSION
ARG VENTOY_DOWNLOAD_URL

FROM ubuntu:${UBUNTU_VERSION}

# Re-declare ARGs after FROM to make them available in build stages
ARG VENTOY_VERSION
ARG VENTOY_DOWNLOAD_URL

# Install system dependencies
RUN apt update && apt install -y \
    nbd-client util-linux \
    wget tar xz-utils \
    parted fdisk \
    udev \
    dosfstools \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /root

# Download and extract Ventoy
RUN wget "${VENTOY_DOWNLOAD_URL}" -O ventoy.tar.gz \
    && tar -xzf ventoy.tar.gz \
    && rm ventoy.tar.gz

# Set working directory to Ventoy installation
WORKDIR /root/ventoy-${VENTOY_VERSION}

# Copy scripts into container
COPY ./scripts/ /root/ventoy-${VENTOY_VERSION}/scripts/

# Make all scripts executable
RUN find /root/ventoy-${VENTOY_VERSION}/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Create symlink for easier entrypoint access
RUN ln -s /root/ventoy-${VENTOY_VERSION}/scripts/container/entrypoint.sh /entrypoint.sh

# Expose VentoyWeb port
EXPOSE 24680

ENTRYPOINT ["/entrypoint.sh"]

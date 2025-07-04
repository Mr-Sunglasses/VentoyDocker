FROM ubuntu:latest

# Install system dependencies
RUN apt update && apt install -y \
    nbd-client util-linux \
    wget tar xz-utils \
    parted fdisk \
    udev \
    dosfstools

# Create work directory
WORKDIR /root

# Download and extract Ventoy
RUN wget https://github.com/ventoy/Ventoy/releases/download/v1.1.05/ventoy-1.1.05-linux.tar.gz \
    && tar -xzf ventoy-1.1.05-linux.tar.gz

# Set Working Directory
# This is where the Ventoy files are located
WORKDIR /root/ventoy-1.1.05

CMD ["bash"]
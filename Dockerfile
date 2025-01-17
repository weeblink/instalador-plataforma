FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    curl \
    gnupg \
    snapd \
    && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /www && \
    mkdir -p /etc/yum.repos.d && \
    touch /etc/motd

# Create directory for Docker socket
RUN mkdir -p /var/run/docker

# Copy your installation scripts
WORKDIR /app
COPY . /app/

# Make scripts executable
RUN chmod +x /app/*.sh

# Keep container running with a simple entrypoint
ENTRYPOINT ["tail", "-f", "/dev/null"]
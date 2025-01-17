#!/bin/bash

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GRAY_LIGHT='\033[0;37m'

# Build the image
printf "${WHITE}🔨 Building Docker image...${GRAY_LIGHT}\n"
if ! docker build -t installer-test .; then
    printf "${RED}❌ Failed to build Docker image${GRAY_LIGHT}\n"
    exit 1
fi

# Remove old container if exists
if docker ps -a | grep -q test-container; then
    printf "${YELLOW}🗑️  Removing old container...${GRAY_LIGHT}\n"
    docker rm -f test-container
fi

# Run the container
printf "${WHITE}🚀 Starting container...${GRAY_LIGHT}\n"
if ! docker run -d \
    --name test-container \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v www-data:/var/www \
    --privileged \
    installer-test; then
    printf "${RED}❌ Failed to start container${GRAY_LIGHT}\n"
    exit 1
fi

# Wait for container to start
printf "${WHITE}⏳ Waiting for container to start...${GRAY_LIGHT}\n"
sleep 5

# Check if container is running
if ! docker ps | grep -q test-container; then
    printf "${RED}❌ Container failed to start${GRAY_LIGHT}\n"
    docker logs test-container
    exit 1
fi

# Execute installation script
printf "${WHITE}📦 Running installation script...${GRAY_LIGHT}\n"
if ! docker exec -it test-container bash /app/install.sh; then
    printf "${RED}❌ Installation script failed${GRAY_LIGHT}\n"
    exit 1
fi

printf "${GREEN}✅ Process completed successfully${GRAY_LIGHT}\n"
#!/bin/bash

# Change to the correct directory
cd ~/n8n-compose

# Pull the latest version of the container images
docker compose pull

# Stop and remove the old containers
docker compose down

# Start the new containers in detached mode
docker compose up -d

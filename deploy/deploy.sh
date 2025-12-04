#!/bin/bash
set -xe

echo "Pulling latest image..."
docker compose pull compritas

echo "Restarting application..."
docker compose up -d compritas

# echo "Running migrations..."
# docker compose run --rm compritas ./bin/migrate

echo "Cleaning up old images..."
docker image prune -f --filter "dangling=true"

echo "Deploy completed!"
docker compose ps


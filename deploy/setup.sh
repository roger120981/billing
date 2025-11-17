#!/bin/bash
set -xe

echo "Starting initial setup..."

docker compose up -d postgres caddy

echo "Waiting for database..."
until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
  echo "Postgres not ready yet, waiting..."
  sleep 5
done

echo "Running migrations..."
docker compose run --rm compritas ./bin/migrate

echo "Starting application..."
docker compose up -d compritas

echo "Setup completed!"
docker compose ps


#!/bin/bash

set -e

echo "🧹 Cleaning Docker volumes for anvil-demo project..."

VOLUMES=(
   "anvil-demo_blockscout-db-data"
   "anvil-demo_stats-db-data"
   "anvil-demo_redis-data"
   "anvil-demo_backend-logs"
)

echo "Stopping containers..."
docker-compose down

echo "Removing volumes..."
for volume in "${VOLUMES[@]}"; do
   if docker volume ls -q | grep -q "^${volume}$"; then
       echo "Removing volume: $volume"
       docker volume rm "$volume"
   else
       echo "Volume not found: $volume"
   fi
done

echo "Cleaning up orphaned volumes..."
docker volume prune -f

echo "Removing local data directory..."
if [ -d "./data" ]; then
   rm -rf ./data/*
   echo "Cleared ./data directory"
fi

echo "✅ Cleanup completed"
echo "Run 'docker-compose up -d' to start fresh"
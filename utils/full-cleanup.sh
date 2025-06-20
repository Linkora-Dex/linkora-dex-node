#!/bin/bash

# Copyright 2025 Linkora DEX
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

echo "🧹 Full cleanup: containers, images, volumes for anvil-demo project..."

PROJECT_NAME="anvil-demo"

echo "Stopping and removing all project containers..."
docker-compose down --remove-orphans

echo "Removing project containers..."
CONTAINERS=$(docker ps -a --filter "name=${PROJECT_NAME}" -q)
if [ ! -z "$CONTAINERS" ]; then
   docker rm -f $CONTAINERS
   echo "Removed containers: $CONTAINERS"
else
   echo "No project containers found"
fi

echo "Removing project images..."
IMAGES=$(docker images --filter "reference=${PROJECT_NAME}*" -q)
if [ ! -z "$IMAGES" ]; then
   docker rmi -f $IMAGES
   echo "Removed images: $IMAGES"
else
   echo "No project images found"
fi

echo "Removing project volumes..."
VOLUMES=(
   "${PROJECT_NAME}_blockscout-db-data"
   "${PROJECT_NAME}_stats-db-data"
   "${PROJECT_NAME}_redis-data"
   "${PROJECT_NAME}_backend-logs"
)

for volume in "${VOLUMES[@]}"; do
   if docker volume ls -q | grep -q "^${volume}$"; then
       echo "Removing volume: $volume"
       docker volume rm "$volume"
   else
       echo "Volume not found: $volume"
   fi
done

echo "Removing project network..."
NETWORK="${PROJECT_NAME}_anvil-network"
if docker network ls --filter "name=${NETWORK}" -q | grep -q .; then
   docker network rm "$NETWORK"
   echo "Removed network: $NETWORK"
else
   echo "Network not found: $NETWORK"
fi

echo "Cleaning up orphaned resources..."
docker container prune -f
docker image prune -f
docker volume prune -f
docker network prune -f

echo "Removing local data directory..."
if [ -d "./data" ]; then
   rm -rf ./data/*
   echo "Cleared ./data directory"
fi

echo "✅ Full cleanup completed"
echo "Run 'docker-compose up -d --build' to start fresh"
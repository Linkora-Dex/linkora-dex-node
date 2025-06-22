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

echo "🧹 Cleaning Docker volumes for project..."

cd "$(dirname "$0")/.."
PROJECT_PREFIX=$(basename "$(pwd)")

VOLUME_NAMES=(
    "blockscout-db-data"
    "stats-db-data"
    "redis-data"
    "backend-logs"
    "anvil-data"
    "explorer-data"
    "config-data"
)

echo "Stopping containers..."
docker-compose down

echo "Removing volumes..."
for volume_name in "${VOLUME_NAMES[@]}"; do
    volume="${PROJECT_PREFIX}_${volume_name}"
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
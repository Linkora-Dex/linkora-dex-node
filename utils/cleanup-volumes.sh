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
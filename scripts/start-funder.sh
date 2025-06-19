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

echo "Generating wallets..."
python3 /app/scripts/generate-wallets.py

echo "Waiting for Anvil to be ready..."
while ! curl -s http://node-anvil:8545 > /dev/null 2>&1; do
    echo "Waiting for Anvil RPC..."
    sleep 2
done

echo "Anvil is ready, funding wallets..."
python3 /app/scripts/fund-wallets.py

echo "Wallet funding completed successfully!"

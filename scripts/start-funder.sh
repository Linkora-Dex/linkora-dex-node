#!/bin/bash

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

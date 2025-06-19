#!/bin/bash

set -e

mkdir -p /app/data

GENESIS_PARAMS=""
STATE_PARAMS=""
ACCOUNTS_PARAMS="--accounts 0"

if [ -f "/app/data/anvil-state.json" ]; then
    STATE_PARAMS="--load-state /app/data/anvil-state.json"
    echo "Loading existing state from /app/data/anvil-state.json"
else
    GENESIS_PARAMS="--init /app/config/genesis.json"
    echo "No existing state file found, using Genesis file: /app/config/genesis.json"
fi

BLOCK_TIME_PARAM=""
if [ "$BLOCK_TIME" != "0" ]; then
    BLOCK_TIME_PARAM="--block-time $BLOCK_TIME"
    echo "Using fixed block time: $BLOCK_TIME seconds"
else
    echo "Using on-demand mining (no fixed block time)"
fi

echo "Starting Anvil with the following configuration:"
echo "Chain ID: $CHAIN_ID"
echo "Block time: $BLOCK_TIME seconds"
echo "Gas limit: $GAS_LIMIT"
echo "Gas price: $GAS_PRICE"
echo "Host: $HOST"
echo "Port: $PORT"
echo "Accounts: 0 (Genesis only)"

exec anvil \
 --host "$HOST" \
 --port "$PORT" \
 --chain-id "$CHAIN_ID" \
 $BLOCK_TIME_PARAM \
 --gas-limit "$GAS_LIMIT" \
 --gas-price "$GAS_PRICE" \
 $ACCOUNTS_PARAMS \
 $GENESIS_PARAMS \
 $STATE_PARAMS
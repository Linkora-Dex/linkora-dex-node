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

ANVIL_RPC="http://localhost:8545"
GENESIS_ACCOUNT="0x7FbC4CBb5beEBBFCBB8cCCd94025e3aB2e292d26"

echo "Активация Genesis аккаунта: $GENESIS_ACCOUNT"

# Проверить текущий баланс
echo "Проверка баланса..."
BALANCE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$GENESIS_ACCOUNT\",\"latest\"],\"id\":1}" \
  $ANVIL_RPC | jq -r '.result')

echo "Баланс: $BALANCE wei"

# Активировать impersonation
echo "Активация impersonation..."
IMPERSONATE_RESULT=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  --data "{\"jsonrpc\":\"2.0\",\"method\":\"anvil_impersonateAccount\",\"params\":[\"$GENESIS_ACCOUNT\"],\"id\":1}" \
  $ANVIL_RPC)

echo "Результат impersonation: $IMPERSONATE_RESULT"

# Проверить список разблокированных аккаунтов
echo "Проверка разблокированных аккаунтов..."
ACCOUNTS=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' \
  $ANVIL_RPC | jq -r '.result[]')

echo "Разблокированные аккаунты:"
echo "$ACCOUNTS"

# Сравнение без учета регистра
GENESIS_LOWER=$(echo "$GENESIS_ACCOUNT" | tr '[:upper:]' '[:lower:]')
ACCOUNTS_LOWER=$(echo "$ACCOUNTS" | tr '[:upper:]' '[:lower:]')

if echo "$ACCOUNTS_LOWER" | grep -q "$GENESIS_LOWER"; then
    echo "✅ Аккаунт $GENESIS_ACCOUNT успешно активирован"
else
    echo "❌ Ошибка активации аккаунта"
fi

# Тестовая транзакция (перевод самому себе)
echo "Тест транзакции..."
TEST_TX=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_sendTransaction\",\"params\":[{\"from\":\"$GENESIS_ACCOUNT\",\"to\":\"$GENESIS_ACCOUNT\",\"value\":\"0x1\"}],\"id\":1}" \
  $ANVIL_RPC)

echo "Результат тестовой транзакции: $TEST_TX"

# Проверить успешность транзакции
TX_HASH=$(echo "$TEST_TX" | jq -r '.result')
if [ "$TX_HASH" != "null" ] && [ "$TX_HASH" != "" ]; then
    echo "✅ Тестовая транзакция успешна: $TX_HASH"
    echo "✅ Аккаунт полностью функционален"
else
    echo "❌ Ошибка тестовой транзакции"
fi
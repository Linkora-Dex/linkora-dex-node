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

# Загрузка переменных из .env файла
if [ -f ../.env ]; then
    export $(grep -v '^#' ../.env | grep -v '^$' | xargs)
fi

echo $GENESIS_ACCOUNT_ADDRESS
#echo $GENESIS_PRIVATE_KEY

# Использование переменных ENV
#me
python3 transfer.py $GENESIS_ACCOUNT_ADDRESS $GENESIS_PRIVATE_KEY 0x9320D18D37777F6897aaa57Df36251633A5925D2 50000

#deployer
python3 transfer.py $GENESIS_ACCOUNT_ADDRESS $GENESIS_PRIVATE_KEY 0xbA5C24084c98A42974f324F377c87Ad44900648E 800

#keeper
python3 transfer.py $GENESIS_ACCOUNT_ADDRESS $GENESIS_PRIVATE_KEY 0x3a683E750b98A372f7d7638532afe8877fE3FF2D 800

#User1
python3 transfer.py $GENESIS_ACCOUNT_ADDRESS $GENESIS_PRIVATE_KEY 0xF6fDc7a68C9622296dd0321cbdB2bE9a0fa607C7 800

#User2
python3 transfer.py $GENESIS_ACCOUNT_ADDRESS $GENESIS_PRIVATE_KEY 0x34eecc923Dfb84744F31829Ea94D3E1ed944B01b 800
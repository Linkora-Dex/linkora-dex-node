#!/bin/bash

# Загрузка переменных из .env файла
if [ -f ../.env ]; then
    export $(grep -v '^#' ../.env | grep -v '^$' | xargs)
fi

echo $GENESIS_PRIVATE_KEY

# Использование переменных ENV
#me
#python3 transfer.py $GENESIS_ACCOUNT $GENESIS_PRIVATE_KEY 0x9320D18D37777F6897aaa57Df36251633A5925D2 10000

#deployer
#python3 transfer.py $GENESIS_ACCOUNT $GENESIS_PRIVATE_KEY 0xbA5C24084c98A42974f324F377c87Ad44900648E 200

#keeper
#python3 transfer.py $GENESIS_ACCOUNT $GENESIS_PRIVATE_KEY 0x3a683E750b98A372f7d7638532afe8877fE3FF2D 200

#User1
#python3 transfer.py $GENESIS_ACCOUNT $GENESIS_PRIVATE_KEY 0xF6fDc7a68C9622296dd0321cbdB2bE9a0fa607C7 200

#User2
#python3 transfer.py $GENESIS_ACCOUNT $GENESIS_PRIVATE_KEY 0x34eecc923Dfb84744F31829Ea94D3E1ed944B01b 200
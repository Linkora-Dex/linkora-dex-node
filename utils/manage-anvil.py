#!/usr/bin/env python3

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

import json
import sys
import requests
from web3 import Web3


class AnvilManager:
    def __init__(self, rpc_url="http://localhost:8545"):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        self.rpc_url = rpc_url

    def check_connection(self):
        try:
            return self.w3.is_connected()
        except:
            return False

    def get_network_info(self):
        if not self.check_connection():
            return None

        return {
            'connected': True,
            'chain_id': self.w3.eth.chain_id,
            'block_number': self.w3.eth.block_number,
            'gas_price': self.w3.eth.gas_price,
            'accounts_count': len(self.w3.eth.accounts)
        }

    def get_wallets_info(self):
        try:
            with open('/app/config/wallets.json', 'r') as f:
                wallets = json.load(f)
        except:
            return None

        wallet_info = []
        for wallet in wallets[:10]:
            balance = self.w3.eth.get_balance(wallet['address'])
            balance_eth = self.w3.from_wei(balance, 'ether')
            wallet_info.append({
                'address': wallet['address'],
                'balance_eth': str(balance_eth),
                'type': wallet['type']
            })

        return wallet_info

    def mine_blocks(self, count=1):
        for _ in range(count):
            try:
                response = requests.post(self.rpc_url, json={
                    "jsonrpc": "2.0",
                    "method": "evm_mine",
                    "params": [],
                    "id": 1
                })
                if response.status_code != 200:
                    return False
            except:
                return False
        return True

    def set_block_time(self, seconds):
        try:
            response = requests.post(self.rpc_url, json={
                "jsonrpc": "2.0",
                "method": "evm_setIntervalMining",
                "params": [seconds * 1000],
                "id": 1
            })
            return response.status_code == 200
        except:
            return False

    def snapshot(self):
        try:
            response = requests.post(self.rpc_url, json={
                "jsonrpc": "2.0",
                "method": "evm_snapshot",
                "params": [],
                "id": 1
            })
            if response.status_code == 200:
                return response.json().get('result')
        except:
            pass
        return None

    def revert_snapshot(self, snapshot_id):
        try:
            response = requests.post(self.rpc_url, json={
                "jsonrpc": "2.0",
                "method": "evm_revert",
                "params": [snapshot_id],
                "id": 1
            })
            return response.status_code == 200
        except:
            return False


def main():
    manager = AnvilManager()

    if len(sys.argv) < 2:
        print("Usage: python3 manage-anvil.py <command>")
        print("Commands:")
        print("  status - show network status")
        print("  wallets - show wallet balances")
        print("  mine [count] - mine blocks")
        print("  blocktime <seconds> - set block time")
        print("  snapshot - create snapshot")
        print("  revert <snapshot_id> - revert to snapshot")
        return

    command = sys.argv[1]

    if command == "status":
        info = manager.get_network_info()
        if info:
            print(json.dumps(info, indent=2))
        else:
            print("Cannot connect to Anvil")

    elif command == "wallets":
        wallets = manager.get_wallets_info()
        if wallets:
            print("Top 10 wallets:")
            for wallet in wallets:
                print(f"{wallet['address']}: {wallet['balance_eth']} ETH ({wallet['type']})")
        else:
            print("Cannot load wallet information")

    elif command == "mine":
        count = int(sys.argv[2]) if len(sys.argv) > 2 else 1
        if manager.mine_blocks(count):
            print(f"Mined {count} blocks")
        else:
            print("Failed to mine blocks")

    elif command == "blocktime":
        if len(sys.argv) < 3:
            print("Usage: blocktime <seconds>")
            return
        seconds = int(sys.argv[2])
        if manager.set_block_time(seconds):
            print(f"Block time set to {seconds} seconds")
        else:
            print("Failed to set block time")

    elif command == "snapshot":
        snapshot_id = manager.snapshot()
        if snapshot_id:
            print(f"Snapshot created: {snapshot_id}")
        else:
            print("Failed to create snapshot")

    elif command == "revert":
        if len(sys.argv) < 3:
            print("Usage: revert <snapshot_id>")
            return
        snapshot_id = sys.argv[2]
        if manager.revert_snapshot(snapshot_id):
            print(f"Reverted to snapshot: {snapshot_id}")
        else:
            print("Failed to revert snapshot")

    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
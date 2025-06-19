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
import os
from datetime import datetime
from mnemonic import Mnemonic
from eth_account import Account
from web3 import Web3


def generate_wallet_from_mnemonic(mnemonic_phrase, account_index=0):
    Account.enable_unaudited_hdwallet_features()
    account = Account.from_mnemonic(mnemonic_phrase, account_path=f"m/44'/60'/0'/0/{account_index}")
    return {
        'address': account.address,
        'private_key': account.key.hex(),
        'mnemonic': mnemonic_phrase,
        'index': account_index
    }


def generate_random_mnemonic():
    mnemo = Mnemonic("english")
    return mnemo.generate(strength=128)


def wei_to_ether(wei):
    return Web3.from_wei(wei, 'ether')


def ether_to_wei(ether):
    return Web3.to_wei(ether, 'ether')


def backup_existing_file(filepath):
    if os.path.exists(filepath):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = f"{filepath}.backup_{timestamp}"
        os.rename(filepath, backup_path)
        print(f"Backed up existing file: {backup_path}")


def load_existing_wallets(filepath):
    if os.path.exists(filepath):
        try:
            with open(filepath, 'r') as f:
                return json.load(f)
        except:
            return []
    return []


def main():
    output_dir = '/app/config'
    os.makedirs(output_dir, exist_ok=True)

    wallets_file = f'{output_dir}/wallets.json'
    existing_wallets = load_existing_wallets(wallets_file)

    if existing_wallets:
        print(f"Found {len(existing_wallets)} existing wallets")
        backup_existing_file(wallets_file)

    wallets = []
    balance_configs = [
        {'count': 5, 'balance': ether_to_wei(0.5), 'type': 'high'},
        {'count': 15, 'balance': ether_to_wei(0.1), 'type': 'medium'},
        {'count': 30, 'balance': ether_to_wei(0.05), 'type': 'low'}
    ]

    wallet_index = len(existing_wallets)

    for config in balance_configs:
        for i in range(config['count']):
            mnemonic = generate_random_mnemonic()
            wallet = generate_wallet_from_mnemonic(mnemonic, 0)
            wallet['balance'] = str(config['balance'])
            wallet['balance_ether'] = str(wei_to_ether(config['balance']))
            wallet['type'] = config['type']
            wallet['wallet_id'] = wallet_index
            wallets.append(wallet)
            wallet_index += 1

    all_wallets = existing_wallets + wallets

    with open(wallets_file, 'w') as f:
        json.dump(all_wallets, f, indent=2)

    accounts_for_anvil = []
    for wallet in all_wallets:
        accounts_for_anvil.append({
            'address': wallet['address'],
            'balance': wallet['balance']
        })

    genesis_file = f'{output_dir}/genesis-accounts.json'
    backup_existing_file(genesis_file)
    with open(genesis_file, 'w') as f:
        json.dump(accounts_for_anvil, f, indent=2)

    private_keys = [wallet['private_key'] for wallet in all_wallets]
    keys_file = f'{output_dir}/private-keys.txt'
    backup_existing_file(keys_file)
    with open(keys_file, 'w') as f:
        for key in private_keys:
            f.write(f"{key}\n")

    metamask_import = []
    for wallet in all_wallets:
        metamask_import.append({
            'mnemonic': wallet['mnemonic'],
            'address': wallet['address'],
            'private_key': wallet['private_key'],
            'balance_ether': wallet['balance_ether'],
            'type': wallet['type']
        })

    metamask_file = f'{output_dir}/metamask-wallets.json'
    backup_existing_file(metamask_file)
    with open(metamask_file, 'w') as f:
        json.dump(metamask_import, f, indent=2)

    summary = {
        'total_wallets': len(all_wallets),
        'existing_wallets': len(existing_wallets),
        'new_wallets': len(wallets),
        'high_balance': {'count': len([w for w in all_wallets if w['type'] == 'high']), 'balance_each': '0.5 ETH'},
        'medium_balance': {'count': len([w for w in all_wallets if w['type'] == 'medium']), 'balance_each': '0.1 ETH'},
        'low_balance': {'count': len([w for w in all_wallets if w['type'] == 'low']), 'balance_each': '0.05 ETH'},
        'total_eth': str(wei_to_ether(sum(int(w['balance']) for w in all_wallets))),
        'chain_id': '31337',
        'network_name': 'Anvil Local'
    }

    summary_file = f'{output_dir}/wallet-summary.json'
    backup_existing_file(summary_file)
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)

    print(f"Generated {len(wallets)} new wallets")
    print(f"Total wallets: {len(all_wallets)} (existing: {len(existing_wallets)}, new: {len(wallets)})")
    print(f"High balance wallets: {len([w for w in all_wallets if w['type'] == 'high'])}")
    print(f"Medium balance wallets: {len([w for w in all_wallets if w['type'] == 'medium'])}")
    print(f"Low balance wallets: {len([w for w in all_wallets if w['type'] == 'low'])}")
    print(f"Total ETH distributed: {summary['total_eth']}")
    print("Files updated:")
    print("- /app/config/wallets.json")
    print("- /app/config/genesis-accounts.json")
    print("- /app/config/private-keys.txt")
    print("- /app/config/metamask-wallets.json")
    print("- /app/config/wallet-summary.json")


if __name__ == "__main__":
    main()
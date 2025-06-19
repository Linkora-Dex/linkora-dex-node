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


def generate_metamask_config():
    try:
        with open('/app/config/metamask-wallets.json', 'r') as f:
            wallets = json.load(f)
    except FileNotFoundError:
        print("Wallets file not found. Run the container first.")
        return

    config = {
        "network": {
            "name": "Anvil Local Network",
            "rpc_url": "http://localhost:8545",
            "chain_id": 31337,
            "chain_id_hex": "0x7A69",
            "currency_symbol": "ETH",
            "currency_name": "Ethereum"
        },
        "auto_add_script": """
// Автоматическое добавление сети Anvil в MetaMask
// Выполнить в консоли браузера
await window.ethereum.request({
  method: 'wallet_addEthereumChain',
  params: [{
    chainId: '0x7A69',
    chainName: 'Anvil Local Network',
    nativeCurrency: {
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrls: ['http://localhost:8545'],
    blockExplorerUrls: null
  }]
});
        """,
        "sample_wallets": []
    }

    # Добавить первые 10 кошельков для демонстрации
    for i, wallet in enumerate(wallets[:10]):
        config["sample_wallets"].append({
            "wallet_number": i + 1,
            "address": wallet["address"],
            "private_key": wallet["private_key"],
            "mnemonic": wallet["mnemonic"],
            "balance_eth": wallet["balance_ether"],
            "type": wallet["type"],
            "import_instructions": {
                "method_1_mnemonic": f"Import Account → Seed Phrase → {wallet['mnemonic']}",
                "method_2_private_key": f"Import Account → Private Key → {wallet['private_key']}"
            }
        })

    return config


def print_quick_setup():
    config = generate_metamask_config()
    if not config:
        return

    print("=" * 60)
    print("METAMASK SETUP FOR ANVIL LOCAL NETWORK")
    print("=" * 60)

    print("\n1. NETWORK CONFIGURATION:")
    print(f"   Network Name: {config['network']['name']}")
    print(f"   RPC URL: {config['network']['rpc_url']}")
    print(f"   Chain ID: {config['network']['chain_id']}")
    print(f"   Currency: {config['network']['currency_symbol']}")

    print("\n2. AUTO-ADD NETWORK (execute in browser console):")
    print(config['auto_add_script'])

    print("\n3. SAMPLE WALLETS FOR TESTING:")
    print("   (Import any of these wallets to MetaMask)")

    for wallet in config['sample_wallets'][:5]:
        print(f"\n   Wallet #{wallet['wallet_number']} ({wallet['type']} balance):")
        print(f"   Address: {wallet['address']}")
        print(f"   Balance: {wallet['balance_eth']} ETH")
        print(f"   Private Key: {wallet['private_key']}")
        print(f"   Mnemonic: {wallet['mnemonic']}")

    print(f"\n   ... and {len(config['sample_wallets']) - 5} more wallets available")

    print("\n4. VERIFICATION STEPS:")
    print("   a) Add network to MetaMask")
    print("   b) Import one of the wallets above")
    print("   c) Check that balance matches expected amount")
    print("   d) Try sending a small transaction")

    print("\n5. TROUBLESHOOTING:")
    print("   - If RPC not accessible: check 'docker-compose ps'")
    print("   - If balance is 0: run 'make wallets' to verify funding")
    print("   - If transactions fail: check gas settings")

    return config


def export_for_import(count=10):
    try:
        with open('/app/config/metamask-wallets.json', 'r') as f:
            wallets = json.load(f)
    except FileNotFoundError:
        print("Wallets file not found")
        return

    export_data = {
        "network_info": {
            "rpc_url": "http://localhost:8545",
            "chain_id": 31337,
            "network_name": "Anvil Local Network"
        },
        "wallets_for_import": []
    }

    for i, wallet in enumerate(wallets[:count]):
        export_data["wallets_for_import"].append({
            "id": i + 1,
            "address": wallet["address"],
            "private_key": wallet["private_key"],
            "mnemonic": wallet["mnemonic"],
            "balance": wallet["balance_ether"],
            "type": wallet["type"]
        })

    with open('/app/config/metamask-import.json', 'w') as f:
        json.dump(export_data, f, indent=2)

    print(f"Created /app/config/metamask-import.json with {count} wallets")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 metamask-setup.py <command>")
        print("Commands:")
        print("  setup - show MetaMask setup instructions")
        print("  export [count] - export wallets for import (default: 10)")
        return

    command = sys.argv[1]

    if command == "setup":
        config = print_quick_setup()
        if config:
            with open('/app/config/metamask-config.json', 'w') as f:
                json.dump(config, f, indent=2)
            print(f"\nFull configuration saved to: /app/config/metamask-config.json")

    elif command == "export":
        count = int(sys.argv[2]) if len(sys.argv) > 2 else 10
        export_for_import(count)

    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
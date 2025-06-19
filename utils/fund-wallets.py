#!/usr/bin/env python3

import json
import time
from web3 import Web3
from eth_account import Account
import os

wallets_path = '/app/config/wallets.json'
web3_url = 'http://node-anvil:8545'

from dotenv import load_dotenv

load_dotenv("../.env")

GENESIS_ACCOUNT = os.getenv('GENESIS_ACCOUNT')
GENESIS_PRIVATE_KEY = os.getenv('GENESIS_PRIVATE_KEY')


def generate_wallets():
    wallets = []
    for i in range(10):
        account = Account.create()
        wallet = {
            'address': account.address,
            'private_key': account.key.hex(),
            'balance': str(int(1e18)),
            'type': 'medium' if i < 5 else 'low'
        }
        wallets.append(wallet)
    return wallets


def save_wallets(wallets):
    with open(wallets_path, 'w') as f:
        json.dump(wallets, f, indent=2)
    print(f"Generated and saved {len(wallets)} wallets to {wallets_path}")


def wait_for_anvil(w3, max_attempts=30):
    for i in range(max_attempts):
        try:
            if w3.is_connected() and w3.eth.block_number >= 0:
                return True
        except:
            pass
        print(f"Waiting for Anvil... attempt {i + 1}/{max_attempts}")
        time.sleep(2)
    return False


def fund_wallets():
    w3 = Web3(Web3.HTTPProvider(web3_url))

    if not wait_for_anvil(w3):
        print("Cannot connect to Anvil after 60 seconds")
        return False

    print("Connected to Anvil")

    wallets = generate_wallets()
    save_wallets(wallets)

    genesis_balance = w3.eth.get_balance(GENESIS_ACCOUNT)
    total_needed = sum(int(wallet['balance']) for wallet in wallets)

    print(f"Genesis account balance: {w3.from_wei(genesis_balance, 'ether')} ETH")
    print(f"Total ETH needed: {w3.from_wei(total_needed, 'ether')} ETH")

    if genesis_balance < total_needed:
        print("Insufficient balance in genesis account")
        return False

    funded_count = 0
    failed_count = 0

    for wallet in wallets:
        target_address = wallet['address']
        amount_to_send = int(wallet['balance'])

        try:
            nonce = w3.eth.get_transaction_count(GENESIS_ACCOUNT)
            gas_price = w3.eth.gas_price

            transaction = {
                'to': target_address,
                'value': amount_to_send,
                'gas': 21000,
                'gasPrice': gas_price,
                'nonce': nonce,
                'chainId': w3.eth.chain_id
            }

            signed_txn = w3.eth.account.sign_transaction(transaction, private_key=GENESIS_PRIVATE_KEY)
            tx_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)

            receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)

            if receipt.status == 1:
                funded_count += 1
                print(f"Funded {target_address}: {w3.from_wei(amount_to_send, 'ether')} ETH")
            else:
                failed_count += 1
                print(f"Failed to fund {target_address}")

        except Exception as e:
            failed_count += 1
            print(f"Error funding {target_address}: {str(e)}")

    print(f"Funding complete: {funded_count} successful, {failed_count} failed")

    verification_count = 0
    for wallet in wallets[:5]:
        balance = w3.eth.get_balance(wallet['address'])
        expected = int(wallet['balance'])
        if balance >= expected:
            verification_count += 1
        print(f"Wallet {wallet['address']}: {w3.from_wei(balance, 'ether')} ETH")

    return verification_count >= 3


if __name__ == "__main__":
    success = fund_wallets()
    exit(0 if success else 1)

#!/usr/bin/env python3

import sys
from web3 import Web3

web3_url = 'http://localhost:8545'


def transfer_funds(from_address, from_private_key, to_address, amount_eth):
    w3 = Web3(Web3.HTTPProvider(web3_url))

    if not w3.is_connected():
        print("❌ Cannot connect to Anvil")
        return False

    try:
        amount_wei = w3.to_wei(amount_eth, 'ether')
        from_balance = w3.eth.get_balance(from_address)
        gas_price = w3.eth.gas_price
        gas_cost = 21000 * gas_price

        print(f"From: {from_address}")
        print(f"To: {to_address}")
        print(f"Amount: {amount_eth} ETH")
        print(f"Current balance: {w3.from_wei(from_balance, 'ether')} ETH")
        print(f"Gas cost: {w3.from_wei(gas_cost, 'ether')} ETH")

        if from_balance < (amount_wei + gas_cost):
            print("❌ Insufficient balance")
            return False

        nonce = w3.eth.get_transaction_count(from_address)

        transaction = {
            'to': to_address,
            'value': amount_wei,
            'gas': 21000,
            'gasPrice': gas_price,
            'nonce': nonce,
            'chainId': w3.eth.chain_id
        }

        signed_txn = w3.eth.account.sign_transaction(transaction, private_key=from_private_key)
        tx_hash = w3.eth.send_raw_transaction(signed_txn.raw_transaction)

        print(f"Transaction hash: {tx_hash.hex()}")

        receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)

        if receipt.status == 1:
            new_balance = w3.eth.get_balance(from_address)
            to_balance = w3.eth.get_balance(to_address)
            print(f"✅ Transfer successful")
            print(f"New balance (from): {w3.from_wei(new_balance, 'ether')} ETH")
            print(f"New balance (to): {w3.from_wei(to_balance, 'ether')} ETH")
            return True
        else:
            print("❌ Transaction failed")
            return False

    except Exception as e:
        print(f"❌ Error: {e}")
        return False


def main():
    if len(sys.argv) != 5:
        print("Usage: python3 transfer.py <from_address> <private_key> <to_address> <amount_eth>")
        print("Example: python3 transfer.py 0x123... 0xabc... 0x456... 1.5")
        sys.exit(1)

    from_address = sys.argv[1]
    from_private_key = sys.argv[2]
    to_address = sys.argv[3]
    amount_eth = float(sys.argv[4])

    success = transfer_funds(from_address, from_private_key, to_address, amount_eth)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
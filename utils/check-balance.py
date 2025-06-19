#!/usr/bin/env python3

from web3 import Web3


def check_balance():
    rpc_url = "http://localhost:8545"
    account = "0x7FbC4CBb5beEBBFCBB8cCCd94025e3aB2e292d26"

    try:
        w3 = Web3(Web3.HTTPProvider(rpc_url))

        if not w3.is_connected():
            print(f"❌ Failed to connect to {rpc_url}")
            return

        balance_wei = w3.eth.get_balance(account)
        balance_eth = w3.from_wei(balance_wei, 'ether')

        print(f"Account: {account}")
        print(f"Balance: {balance_eth:,.0f} ETH")
        print(f"Balance (wei): {balance_wei:,}")
        print(f"Balance (hex): {hex(balance_wei)}")

    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    check_balance()
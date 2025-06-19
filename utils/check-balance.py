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
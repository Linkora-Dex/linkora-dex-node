import os
from dotenv import load_dotenv
from eth_keys import keys
from web3 import Web3


class EthereumKeysProcessor:
    def __init__(self, env_path='../.env'):
        self.env_path = env_path
        self.private_keys = []

    def load_private_keys(self):
        load_dotenv(self.env_path)
        keys_data = []
        for i in ['GENESIS_PRIVATE_KEY', 'ANVIL_DEPLOYER_PRIVATE_KEY', 'ANVIL_KEEPER_PRIVATE_KEY', 'USER1_PRIVATE_KEY', 'USER2_PRIVATE_KEY']:
            original_key = os.environ[i]
            key = original_key
            if key.startswith('0x'):
                key = key[2:]
            key = key.zfill(64)
            keys_data.append([i, '0x' + key, original_key])
        self.private_keys = keys_data
        return keys_data

    def process_with_eth_keys(self):
        results = {}
        for item in self.private_keys:
            private_key = item[1]
            pk = keys.PrivateKey(bytes.fromhex(private_key[2:]))
            public_key = pk.public_key
            address = public_key.to_checksum_address()
            results[private_key] = {'key_name': item[0], 'original_key': item[2], 'private_key': private_key, 'public_key': '0x' + public_key.to_hex(),
                                    'address': address}
        return results

    def process_with_web3(self):
        results = {}
        w3 = Web3()
        for item in self.private_keys:
            private_key = item[1]
            account = w3.eth.account.from_key(private_key)
            results[private_key] = {'key_name': item[0], 'original_key': item[2], 'private_key': private_key,
                                    'public_key': '0x' + account._key_obj.public_key.to_hex(), 'address': account.address}
        return results

    def get_both_results(self):
        self.load_private_keys()
        return {'eth_keys_results': self.process_with_eth_keys(), 'web3_results': self.process_with_web3(), 'total_keys_processed': len(self.private_keys)}


if __name__ == "__main__":
    processor = EthereumKeysProcessor()
    results = processor.get_both_results()

    print("ETH-KEYS Results:")
    for pk, data in results['eth_keys_results'].items():
        print(f"Key: {data['key_name']}")
        print(f"Original: {data['original_key']}")
        print(f"Normalized: {pk}")
        print(f"Private: {data['private_key']}")
        print(f"Public: {data['public_key']}")
        print(f"Address: {data['address']}")
        print("-" * 50)

    print("\nWEB3 Results:")
    for pk, data in results['web3_results'].items():
        print(f"Key: {data['key_name']}")
        print(f"Original: {data['original_key']}")
        print(f"Normalized: {pk}")
        print(f"Private: {data['private_key']}")
        print(f"Public: {data['public_key']}")
        print(f"Address: {data['address']}")
        print("-" * 50)
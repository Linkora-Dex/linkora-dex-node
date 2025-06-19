# Anvil DevNet: Full-featured Ethereum development environment

## Project Architecture

Anvil DevNet represents a comprehensive infrastructure for developing and testing Ethereum applications, including blockchain node, databases, web interfaces and automation services.

### System Components

**Core Infrastructure**
- node-anvil - Ethereum node with Chain ID 31337
- node-blockscout-db - PostgreSQL database for blockchain data indexing
- node-stats-db - PostgreSQL database for statistics
- node-redis - Redis cache for performance optimization
- node-backend - Blockscout backend API service
- node-frontend - Blockscout web interface

**Auxiliary Services**
- node-sig-provider - function signature provider
- node-visualizer - smart contract visualization
- node-stats - statistics collection and processing service

## Repository Structure

```
anvil-devnet/
├── anvil-core/                # Core Ethereum node and settings
├── anvil-explorer/            # Blockscout explorer integration
├── anvil-database/           # PostgreSQL and Redis configurations
├── anvil-automation/         # Automation scripts and utilities
├── anvil-monitoring/         # Monitoring and logging systems
└── anvil-contracts/          # Demonstration smart contracts
```

## URL endpoints and service access

### Core Web Interfaces

**Blockscout Frontend**
- Main page: http://localhost:3000
- Block search: http://localhost:3000/blocks
- Transaction search: http://localhost:3000/txs
- Address view: http://localhost:3000/address/{address}
- Contract verification: http://localhost:3000/verify-smart-contract

### Blockchain RPC endpoints

**Ethereum JSON-RPC**
- HTTP RPC: http://localhost:8545
- WebSocket RPC: ws://localhost:8546

### Blockscout API endpoints

**Backend API**
- Base URL: http://localhost:4000
- REST API v2: http://localhost:4000/api/v2
- Documentation: http://localhost:4000/api-docs

**Core endpoints**
```bash
# Address information
GET http://localhost:4000/api/v2/addresses/{address}

# Block list
GET http://localhost:4000/api/v2/blocks

# Block transactions
GET http://localhost:4000/api/v2/blocks/{block_number}/transactions

# Transaction information
GET http://localhost:4000/api/v2/transactions/{tx_hash}

# Contract source code
GET http://localhost:4000/api/v2/smart-contracts/{address}

# General statistics
GET http://localhost:4000/api/v2/stats
```

### Internal Services

**Signature Provider**
- API: http://localhost:8083
- Functions: contract function signature decoding

**Visualizer**
- API: http://localhost:9002
- Functions: smart contract architecture visualization

**Stats Service**
- API: http://localhost:9001
- Functions: network statistics and analytics

### Databases

**PostgreSQL (Blockscout)**
- Connection: localhost:7432
- Database: from POSTGRES_DB variable
- User: from POSTGRES_USER variable

**PostgreSQL (Stats)**
- Connection: localhost:7433
- Database: stats
- User: stats

**Redis**
- Connection: internal network (port not exposed)

## Network Configuration

### Blockchain Parameters
- Network Name: Anvil Local
- RPC URL: http://localhost:8545
- WebSocket URL: ws://localhost:8546
- Chain ID: 31337
- Block Time: 0 seconds (instant mining)
- Gas Limit: 30,000,000
- Gas Price: 1 Gwei

### Pre-installed Accounts
System creates standard Anvil accounts through deterministic mnemonic for reproducible results between runs

**Anvil standard accounts (10 pieces)**
- Balance: 10,000 ETH each
- Mnemonic: fixed for consistency

## System Deployment

### Requirements
- Docker Engine 20.10+
- Docker Compose v2.0+
- Free ports: 8545, 3000, 4000, 7432, 7433, 8083, 9001, 9002
- Minimum 4GB RAM and 10GB disk space

### Full infrastructure launch
```bash
git clone https://github.com/your-org/anvil-devnet
cd anvil-devnet
docker-compose up -d
```

### Staged service launch
```bash
# Database launch
docker-compose up -d node-blockscout-db node-stats-db node-redis

# Wait for database readiness (30-60 seconds)
docker-compose logs -f node-blockscout-db node-redis

# Anvil node launch
docker-compose up -d node-anvil

# Auxiliary services launch
docker-compose up -d node-sig-provider node-visualizer

# Blockscout backend launch
docker-compose up -d node-backend

# Statistics and frontend launch
docker-compose up -d node-stats node-frontend
```

## Usage with Development Tools

### MetaMask setup
```json
{
  "networkName": "Anvil Local",
  "rpcUrl": "http://localhost:8545", 
  "chainId": "31337",
  "currencySymbol": "ETH",
  "blockExplorerUrl": "http://localhost:3000"
}
```

### Foundry integration
```bash
# foundry.toml setup
[profile.anvil]
src = "src"
out = "out" 
libs = ["lib"]
rpc_url = "http://localhost:8545"
chain_id = 31337
```

### Hardhat configuration
```javascript
networks: {
  anvil: {
    url: "http://localhost:8545",
    chainId: 31337,
    accounts: [/* private keys */]
  }
}
```

## API Interaction

### Ethereum JSON-RPC
```bash
# Node status check
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545

# Get address balance
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x...","latest"],"id":1}' \
  http://localhost:8545
```

### Blockscout API
```bash
# Address information
curl "http://localhost:4000/api/v2/addresses/0x..."

# Block transaction list
curl "http://localhost:4000/api/v2/blocks/latest/transactions"

# Network statistics
curl "http://localhost:4000/api/v2/stats"
```

## Contract Deployment

### Container connection
```bash
# Connect to anvil-node container
docker-compose exec node-anvil bash

# Deploy via Foundry
forge create src/Contract.sol:Contract \
  --private-key /* private keys */ \
  --rpc-url http://localhost:8545
```


## System Monitoring

### Service status
```bash
# All services status
docker-compose ps

# Specific service logs
docker-compose logs -f node-backend

# Database connection check
docker-compose exec node-blockscout-db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\l"
docker-compose exec node-redis redis-cli ping
```

### Health checks
```bash
# Blockscout backend check
curl http://localhost:4000/api/v2/stats

# Anvil node check
curl -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' \
  http://localhost:8545

# Stats service check
curl http://localhost:9001/health

# Signature provider check
curl http://localhost:8083/health
```

## Configuration Files

### Environment variables (.env)
```env
# Blockscout database
POSTGRES_DB=blockscout
POSTGRES_USER=blockscout
POSTGRES_PASSWORD=your_password

# Network
CHAIN_ID=31337
BLOCKSCOUT_PORT=4000

# Blockscout settings
SECRET_KEY_BASE=RMgI4C1HSkxsEjdhtGMfwAHfyT6CKWXOgzCboJflfSm4jeAlic52io05KB6mqzc5
```

### Port configuration
```yaml
node-anvil: 8545
node-frontend: 3000
node-backend: 4000
node-blockscout-db: 7432
node-stats-db: 7433
node-sig-provider: 8083
node-visualizer: 9002
node-stats: 9001
```

### Port changes via .env
```env
BLOCKSCOUT_PORT=4000
```

## Troubleshooting

### Common Problems
**Blockscout not indexing blocks**
- Check node-anvil connection status
- Ensure PostgreSQL database is ready for connections
- Check node-backend logs for RPC errors

**Frontend not loading**
- Check node-backend status via health check
- Ensure node-stats is running and accessible
- Check NEXT_PUBLIC_* environment variables

**Databases not starting**
- Check ports 7432 and 7433 availability
- Ensure correct environment variables for passwords
- Check Docker volumes access rights

### Diagnostic Commands
```bash
# Check network interaction between containers
docker-compose exec node-frontend ping node-backend
docker-compose exec node-backend ping node-anvil

# Check ports and connections
docker-compose port node-anvil 8545
docker-compose port node-frontend 3000

# Full system restart with data cleanup
docker-compose down -v
docker-compose up -d
```

### Logs and Debugging
```bash
# Blockscout backend logs
docker-compose logs -f node-backend

# Anvil node logs
docker-compose logs -f node-anvil

# Frontend logs
docker-compose logs -f node-frontend

# All services logs
docker-compose logs -f
```

## Volumes and Data

### Persistent Data
- blockscout-db-data - PostgreSQL Blockscout data
- stats-db-data - PostgreSQL statistics data
- redis-data - Redis cache data
- backend-logs - Blockscout backend logs
- anvil-data - Anvil node data
- config-data - configuration files

### Data Cleanup
```bash
# Stop services with volume removal
docker-compose down -v

# Remove only specific volume
docker volume rm anvil-devnet_blockscout-db-data
```

## Security Limitations

Anvil DevNet is intended exclusively for local development

**Do not use in production**
- Databases have no encryption
- No authentication in web interfaces
- Deterministic account generation
- Open ports without access restrictions

**Security Recommendations**
- Isolate from external networks
- Do not use real funds
- Regularly clean generated data
- Do not commit secret keys to repository

## System Requirements

**Minimum Requirements**
- CPU: 2 cores
- RAM: 4GB
- Disk: 10GB free space
- Network: local without restrictions

**Recommended Requirements**
- CPU: 4+ cores
- RAM: 8GB
- Disk: 20GB SSD
- Network: Gigabit connection for synchronization

## Quick Start

### Minimal Command
```bash
docker-compose up -d
```

### Readiness Check
```bash
# Wait for all services startup (2-3 minutes)
docker-compose ps

# Check interface availability
curl http://localhost:8545
curl http://localhost:3000
curl http://localhost:4000/api/v2/stats
```

Anvil DevNet provides a full-featured Ethereum development environment with integrated Blockscout 
explorer, statistics system and all necessary services for efficient DeFi application and smart 
contract development

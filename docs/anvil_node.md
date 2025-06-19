**Main System Components**

**1. Anvil Node (Local Development)**
- Uses Foundry Anvil for Ethereum network emulation
- GitHub: https://github.com/foundry-rs/foundry
- Dockerfile.anvil contains Foundry installation via curl

**2. Blockscout Backend**
- Docker image: `blockscout/blockscout:latest`
- GitHub: https://github.com/blockscout/blockscout
- Elixir application for blockchain indexing

**3. Blockscout Frontend**
- Docker image: `ghcr.io/blockscout/frontend:latest`
- GitHub: https://github.com/blockscout/frontend
- Next.js application

**4. Blockscout Statistics**
- Docker image: `ghcr.io/blockscout/stats:latest`
- GitHub: https://github.com/blockscout/blockscout-rs (stats module)

**5. Signature Provider**
- Docker image: `ghcr.io/blockscout/sig-provider:latest`
- GitHub: https://github.com/blockscout/blockscout-rs (sig-provider module)

**6. Visualizer**
- Docker image: `ghcr.io/blockscout/visualizer:latest`
- GitHub: https://github.com/blockscout/visualizer
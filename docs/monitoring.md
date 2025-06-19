# Anvil Diagnostic Commands

## System Status

### Containers
```bash
docker-compose ps
docker-compose logs --tail=20 anvil-node
docker-compose logs --tail=20 backend
docker-compose logs --tail=20 stats
docker-compose logs --tail=20 frontend
```

### Container Access
```bash
docker exec -it anvil-demo-anvil-node-1 /bin/sh
docker exec -it anvil-demo-backend-1 /bin/sh
docker exec -it anvil-demo-frontend-1 /bin/sh
docker exec -it anvil-demo-stats-1 /bin/sh
```

## Anvil State Check

### Configuration Files
```bash
docker-compose exec anvil-node ls -la /app/data/
docker-compose exec anvil-node cat /app/data/anvil-state.json
docker-compose exec anvil-node cat /app/config/genesis.json
docker-compose exec anvil-node env | grep -E "(CHAIN_ID|HOST|PORT|BLOCK_TIME)"
```

### RPC Checks
```bash
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://localhost:8545 | jq
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8545 | jq
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545 | jq
```

### Balance Check
```bash
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","latest"],"id":1}' http://localhost:8545 | jq
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x7FbC4CBb5beEBBFCBB8cCCd94025e3aB2e292d26","latest"],"id":1}' http://localhost:8545 | jq
```

### Account Unlock
```bash
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"anvil_impersonateAccount","params":["0x7FbC4CBb5beEBBFCBB8cCCd94025e3aB2e292d26"],"id":1}' http://localhost:8545
```

## API endpoints

```bash
curl -s http://localhost:4000/api/v2/stats | jq
curl -s http://localhost:9001/stats | jq
curl -s http://localhost:8083/
curl -s http://localhost:9002/
curl -s http://localhost:3000/
```

## Database

### Connection
```bash
docker exec -it anvil-demo-blockscout-db-1 psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
docker exec -it anvil-demo-stats-db-1 psql -U stats -d stats
docker exec -it anvil-demo-redis-1 redis-cli
```

### Analysis
```bash
docker exec anvil-demo-blockscout-db-1 psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "\dt"
docker exec anvil-demo-stats-db-1 psql -U stats -d stats -c "\dt"
docker exec anvil-demo-blockscout-db-1 psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT COUNT(*) FROM blocks;"
```

## Network and Resources

### Network Checks
```bash
docker exec anvil-demo-backend-1 ping -c 1 anvil-node
docker exec anvil-demo-stats-1 ping -c 1 backend
docker exec anvil-demo-frontend-1 ping -c 1 backend
netstat -tlnp | grep -E "(8545|4000|3000|9001|8083|9002)"
```

### Resource Monitoring
```bash
docker stats --no-stream
docker system df
docker volume ls | grep anvil-demo
CONTAINER_ID=$(docker-compose ps -q anvil-node)
docker stats $CONTAINER_ID --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
```

## Diagnostic Sequence

1. Check logs `docker-compose logs anvil-node`
2. Check state files `docker-compose exec anvil-node ls -la /app/data/`
3. Get accounts via RPC eth_accounts
4. Check balances of deployer and genesis accounts
5. Unlock genesis account if necessary
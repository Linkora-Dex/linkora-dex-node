.PHONY: help start stop status logs wallets mine deploy clean backup restore

help:
	@echo "Linkora DEX Node Management Commands:"
	@echo ""
	@echo "  make start    - Start Anvil node"
	@echo "  make stop     - Stop all services"
	@echo "  make status   - Show network status"
	@echo "  make logs     - Show Anvil logs"
	@echo "  make wallets  - Show generated wallets"
	@echo "  make mine     - Mine 5 blocks manually"
	@echo "  make deploy   - Deploy demo contracts"
	@echo "  make backup   - Create backup of current state"
	@echo "  make restore  - List and restore from backups"
	@echo "  make clean    - Clean all data and restart"
	@echo "  make shell    - Connect to Anvil container"

start:
	@echo "Starting Anvil node..."
	docker-compose up -d node-anvil
	@echo "Waiting for node to start..."
	@sleep 15
	@make status

stop:
	@echo "Stopping all services..."
	docker-compose down

restart:
	@echo "Restarting Anvil (preserving data)..."
	docker-compose restart node-anvil
	@sleep 10
	@make status

status:
	@echo "Network Status:"
	@docker-compose exec node-anvil python3 /app/scripts/manage-anvil.py status 2>/dev/null || echo "Anvil not running"

logs:
	docker-compose logs -f node-anvil

wallets:
	@echo "Wallet Information:"
	@docker-compose exec node-anvil python3 /app/scripts/manage-anvil.py wallets 2>/dev/null || echo "Cannot get wallet info"

mine:
	@echo "Mining 5 blocks..."
	@docker-compose exec node-anvil python3 /app/scripts/manage-anvil.py mine 5

deploy:
	@echo "Deployment instructions:"
	@echo "1. Run: make shell"
	@echo "2. Install Foundry: curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup"
	@echo "3. Initialize project: forge init --no-git /app/contracts-project"
	@echo "4. Copy contracts: cp /app/contracts/*.sol /app/contracts-project/src/"
	@echo "5. Compile: cd /app/contracts-project && forge build"
	@echo "6. Deploy tokens using forge create commands from README"

backup:
	@echo "Creating backup..."
	@docker-compose exec node-anvil python3 /app/scripts/manage-persistence.py backup

restore:
	@echo "Available backups:"
	@docker-compose exec node-anvil python3 /app/scripts/manage-persistence.py list
	@echo ""
	@echo "To restore: docker-compose exec node-anvil python3 /app/scripts/manage-persistence.py restore <backup_name>"

clean:
	@echo "Cleaning all data..."
	docker-compose down -v
	docker-compose build --no-cache
	@make start

shell:
	docker-compose exec node-anvil bash

setup:
	@echo "Setting up Linkora DEX Node environment..."
	@if [ ! -f .env ]; then echo "Creating .env file..."; cp .env.example .env 2>/dev/null || true; fi
	@make start
	@echo ""
	@echo "Setup complete! Anvil is running on http://localhost:8545"
	@echo "Run 'make wallets' to see generated accounts"
	@echo "Run 'make help' for more commands"
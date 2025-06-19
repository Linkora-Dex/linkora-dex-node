#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

force_kill_ports() {
    local ports=("6379" "7432" "7433" "4000" "3000" "8083" "9001" "9002" "8545" "8546")
    log_info "Принудительное освобождение портов..."

    for port in "${ports[@]}"; do
        local pids=$(lsof -ti:$port 2>/dev/null)
        if [ ! -z "$pids" ]; then
            log_warning "Освобождение порта $port (PID: $pids)"
            echo "$pids" | xargs -r kill -9 2>/dev/null || true
            sleep 0.5
            local remaining=$(lsof -ti:$port 2>/dev/null)
            if [ ! -z "$remaining" ]; then
                log_warning "Принудительное завершение процессов на порту $port"
                echo "$remaining" | xargs -r sudo kill -9 2>/dev/null || true
            fi
        fi
    done

    pkill -f "redis-server" 2>/dev/null || true
    systemctl is-active --quiet redis-server && sudo systemctl stop redis-server 2>/dev/null || true
    systemctl is-active --quiet redis && sudo systemctl stop redis 2>/dev/null || true

    for port in "${ports[@]}"; do
        if lsof -ti:$port >/dev/null 2>&1; then
            log_error "Порт $port остается занятым"
            return 1
        fi
    done

    log_success "Все порты освобождены"
    return 0
}

cleanup_docker_aggressive() {
    log_info "Агрессивная очистка Docker..."

    docker-compose down -v --remove-orphans 2>/dev/null || true

    local containers=$(docker ps -aq --filter "name=linkora-dex-node" 2>/dev/null)
    # Удаляет только контейнеры с именем "linkora-dex-node"

    if [ ! -z "$containers" ]; then
        log_info "Удаление контейнеров проекта"
        echo "$containers" | xargs -r docker rm -f 2>/dev/null || true
    fi

    local volumes=$(docker volume ls -q | grep -E "(linkora-dex-node|anvil|blockscout)" 2>/dev/null)
    # Удаляет только volumes с именами linkora-dex-node, anvil-demo, blockscout

    if [ ! -z "$volumes" ]; then
        log_info "Удаление volumes проекта"
        echo "$volumes" | xargs -r docker volume rm -f 2>/dev/null || true
    fi



    log_success "Docker очищен агрессивно"
}

setup_volumes_optimized() {
    log_info "Оптимизированная настройка volumes..."

    local project_volumes=(
        "linkora-dex-node_blockscout-db-data"
        "linkora-dex-node_stats-db-data"
        "linkora-dex-node_redis-data"
        "linkora-dex-node_backend-logs"
        "linkora-dex-node_config-data"
        "linkora-dex-node_anvil-data"
        "linkora-dex-node_explorer-data"
    )

    for volume in "${project_volumes[@]}"; do
        docker volume create "$volume" >/dev/null 2>&1 || true
    done

    docker run --rm -v linkora-dex-node_blockscout-db-data:/data postgres:15-alpine sh -c "rm -rf /data/* && chown -R 999:999 /data && chmod 700 /data" 2>/dev/null || true
    docker run --rm -v linkora-dex-node_stats-db-data:/data postgres:15-alpine sh -c "rm -rf /data/* && chown -R 999:999 /data && chmod 700 /data" 2>/dev/null || true

    log_success "Volumes настроены"
}

wait_for_anvil() {
    log_info "Ожидание запуска Anvil..."
    local max_wait=120
    local count=0

    while [ $count -lt $max_wait ]; do
        if curl -s -m 2 http://localhost:8545 >/dev/null 2>&1; then
            log_success "Anvil запущен"
            return 0
        fi

        local anvil_status=$(docker-compose ps node-anvil --format "{{.State}}" 2>/dev/null)
        if [ "$anvil_status" = "restarting" ]; then
            log_warning "Anvil перезапускается, проверяем логи..."
            docker-compose logs --tail=5 node-anvil
            docker-compose restart node-anvil
        fi

        sleep 2
        count=$((count + 2))
    done

    log_error "Anvil не запустился за ${max_wait}с"
    return 1
}

check_services_fast() {
    log_info "Быстрая проверка критичных сервисов..."

    local critical_services=("node-anvil" "node-blockscout-db" "node-redis")
    local failed_services=()

    for service in "${critical_services[@]}"; do
        local status=$(docker-compose ps "$service" --format "{{.State}}" 2>/dev/null)
        if [ "$status" != "running" ]; then
            failed_services+=("$service")
            log_error "$service: $status"
        else
            log_success "$service: работает"
        fi
    done

    if [ ${#failed_services[@]} -eq 0 ]; then
        log_success "Критичные сервисы запущены"
        return 0
    else
        log_error "Не работают сервисы: ${failed_services[*]}"
        return 1
    fi
}

fix_anvil_issues() {
    log_info "Исправление проблем Anvil..."

    mkdir -p ./config
    if [ ! -f ./config/genesis.json ]; then
        log_info "Создание базового genesis.json"
        cat > ./config/genesis.json << 'EOF'
{
  "alloc": {
    "0x7FbC4CBb5beEBBFCBB8cCCd94025e3aB2e292d26": {
      "balance": "0xc9f2c9cd04674edea40000000"
    }
  }
}
EOF
    fi

    if [ ! -f ./.env ]; then
        log_info "Создание .env файла"
        cat > ./.env << 'EOF'
CHAIN_ID=31337
BLOCK_TIME=0
GAS_LIMIT=30000000
GAS_PRICE=1000000000
ANVIL_PORT=8545
ANVIL_WS_PORT=8546
BLOCKSCOUT_PORT=4000
ANVIL_HOST=0.0.0.0
POSTGRES_DB=blockscout
POSTGRES_USER=blockscout
POSTGRES_PASSWORD=password
RUST_LOG=info
EOF
    fi

    log_success "Конфигурация Anvil исправлена"
}

main() {
    log_info "Запуск автоматического исправления с полной автоматизацией..."

    if ! force_kill_ports; then
        log_warning "Некоторые порты остались занятыми, продолжаем..."
    fi

    cleanup_docker_aggressive
    fix_anvil_issues
    setup_volumes_optimized

    log_info "Запуск Docker Compose..."
    docker-compose up -d --build --force-recreate

    if [ $? -ne 0 ]; then
        log_error "Ошибка Docker Compose, повторная попытка..."
        docker-compose down
        sleep 5
        docker-compose up -d --build
    fi

    if wait_for_anvil; then
        log_success "Anvil успешно запущен"

        log_info "Запуск остальных сервисов..."
        docker-compose up -d node-backend node-stats node-frontend

        sleep 20

        if check_services_fast; then
            log_success "==== УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО ===="
            log_info "Доступные сервисы"
            log_info "- Anvil RPC: http://localhost:8545"
            log_info "- Blockscout: http://localhost:3000"
            log_info "- Backend API: http://localhost:4000"

            log_info "Проверка доступности"
            curl -s http://localhost:8545 >/dev/null && log_success "✓ Anvil отвечает" || log_warning "✗ Anvil недоступен"
            curl -s http://localhost:3000 >/dev/null && log_success "✓ Frontend отвечает" || log_warning "✗ Frontend недоступен"
        else
            log_error "Некоторые сервисы не запустились"
            docker-compose logs --tail=10
        fi
    else
        log_error "Anvil не запустился, проверяем логи"
        docker-compose logs node-anvil
        exit 1
    fi
}

main "$@"
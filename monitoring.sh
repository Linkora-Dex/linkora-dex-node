#!/bin/bash

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

CONTAINER_NAME="node-anvil"
CONTAINER_ID=$(docker-compose ps -q $CONTAINER_NAME)

if [ -z "$CONTAINER_ID" ]; then
    echo "Container $CONTAINER_NAME не найден или не запущен"
    echo "Запустите: docker-compose up -d $CONTAINER_NAME"
    exit 1
fi

echo "=== Ресурсы контейнера ==="
STATS=$(docker stats $CONTAINER_ID --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}")
IFS=',' read -r CPU_PERC MEM_USAGE MEM_PERC NET_IO BLOCK_IO <<< "$STATS"

echo "CPU: $CPU_PERC | Memory: $MEM_USAGE ($MEM_PERC) | Network: $NET_IO | Block I/O: $BLOCK_IO"

echo -e "\n=== Размеры ==="
IMAGE_ID=$(docker inspect $CONTAINER_ID --format='{{.Image}}')
IMAGE_SIZE=$(docker inspect $IMAGE_ID --format='{{.Size}}' 2>/dev/null)
echo "Размер базового образа: $(echo $IMAGE_SIZE | numfmt --to=iec)"

CONTAINER_SIZE_RW=$(docker system df -v | grep $CONTAINER_ID | awk '{print $3}' | head -1)
if [ -n "$CONTAINER_SIZE_RW" ]; then
    echo "Размер слоя контейнера: $CONTAINER_SIZE_RW"
else
    echo "Размер слоя контейнера: минимальный (контейнер не изменял файловую систему)"
fi

echo -e "\n=== Использование диска ==="
APP_DATA_SIZE=$(docker exec $CONTAINER_ID du -sh /app/data 2>/dev/null | cut -f1)
TOTAL_CONTAINER_SIZE=$(docker exec $CONTAINER_ID du -sh / 2>/dev/null | cut -f1)
echo "Данные приложения (/app/data): $APP_DATA_SIZE"
echo "Общий размер контейнера: $TOTAL_CONTAINER_SIZE"

echo -e "\n=== Процессы и память ==="
echo "Топ 5 процессов по потреблению памяти:"
docker exec $CONTAINER_ID ps aux --sort=-%mem --no-headers | head -5 | awk '{printf "%s: %s%% CPU, %s%% MEM, %s\n", $11, $3, $4, $1}'

echo -e "\n=== Системные ресурсы внутри контейнера ==="
CONTAINER_MEM_INFO=$(docker exec $CONTAINER_ID cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)" | awk '{print $1 " " $2 " " $3}')
echo "$CONTAINER_MEM_INFO"

echo -e "\n=== Лимиты контейнера ==="
MEM_LIMIT=$(docker inspect $CONTAINER_ID --format='{{.HostConfig.Memory}}')
if [ "$MEM_LIMIT" != "0" ]; then
    echo "Лимит памяти: $(echo $MEM_LIMIT | numfmt --to=iec)"
else
    echo "Лимит памяти: не установлен (использует всю доступную память хоста)"
fi

CPU_LIMIT=$(docker inspect $CONTAINER_ID --format='{{.HostConfig.CpuQuota}}')
if [ "$CPU_LIMIT" != "0" ] && [ "$CPU_LIMIT" != "-1" ]; then
    echo "Лимит CPU: $CPU_LIMIT microseconds"
else
    echo "Лимит CPU: не установлен"
fi

echo -e "\n=== Uptime контейнера ==="
STARTED_AT=$(docker inspect $CONTAINER_ID --format='{{.State.StartedAt}}')
echo "Запущен: $STARTED_AT"
UPTIME=$(docker exec $CONTAINER_ID uptime -p 2>/dev/null || echo "недоступно")
echo "Время работы: $UPTIME"

HOST_DISK_USAGE=$(df -h / | tail -1 | awk '{print $3 " из " $2 " (" $5 ")"}')

echo -e "\n=== Сводка ==="
echo "Хост система: $HOST_DISK_USAGE заполненности"
echo "Контейнер потребляет: $MEM_USAGE RAM, $CPU_PERC CPU, $TOTAL_CONTAINER_SIZE дискового пространства"
echo "Приложение использует: $APP_DATA_SIZE для данных"
echo "Текущее потребление памяти: $MEM_USAGE ($MEM_PERC от доступной)"

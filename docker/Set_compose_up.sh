#!/bin/bash

set -e  # 一旦有錯誤就停止腳本執行

echo "🔼 正在依序啟動 docker-compose services..."

compose_files=(
  "docker-compose-init.yaml"
  "docker-compose-db.yaml"
  "docker-compose-quiz-component.yaml"
  "docker-compose-commercial-district-metrotaipei.yaml"
  "docker-compose-commercial-district.yaml"
#   "docker-compose-market-map.yaml"
  "docker-compose.yaml"
)

for file in "${compose_files[@]}"; do
  echo "🚀 啟動 $file ..."
  docker compose -f "$file" up -d
done

echo "✅ 所有服務已依序啟動完成。"
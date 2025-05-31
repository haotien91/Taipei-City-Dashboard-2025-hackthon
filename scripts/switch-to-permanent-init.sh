#!/bin/bash

# 切換到包含商圈活化配置的永久初始化文件
echo "🔄 切換到永久初始化配置..."

# 備份原始 .env 文件
if [ -f ".env" ]; then
    cp .env .env.backup
    echo "✅ 已備份原始 .env 文件為 .env.backup"
fi

# 更新 .env 文件中的 MANAGER_SAMPLE_FILE
if [ -f ".env" ]; then
    # 檢查是否已有 MANAGER_SAMPLE_FILE 設定
    if grep -q "MANAGER_SAMPLE_FILE" .env; then
        # 更新現有設定
        sed -i.bak 's/MANAGER_SAMPLE_FILE=.*/MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql/' .env
        echo "✅ 已更新 .env 中的 MANAGER_SAMPLE_FILE 設定"
    else
        # 添加新設定
        echo "MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql" >> .env
        echo "✅ 已新增 MANAGER_SAMPLE_FILE 設定到 .env"
    fi
else
    echo "⚠️  未找到 .env 文件，請手動設定 MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql"
fi

echo ""
echo "🎉 配置更新完成！"
echo ""
echo "📋 後續步驟："
echo "  1. 重啟容器以應用新配置："
echo "     docker-compose -f docker/docker-compose-init.yaml up dashboard-be-init-manager"
echo ""
echo "  2. 或者如果要完全重新初始化："
echo "     docker-compose -f docker/docker-compose-db.yaml down"
echo "     docker volume rm postgres_manager_data"
echo "     docker-compose -f docker/docker-compose-db.yaml up -d"
echo "     docker-compose -f docker/docker-compose-init.yaml up"
echo ""
echo "🚀 現在系統啟動時將自動包含商圈活化配置！"

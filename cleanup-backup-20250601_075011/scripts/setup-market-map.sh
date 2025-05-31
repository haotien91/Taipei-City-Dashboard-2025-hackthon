#!/bin/bash

# 市集活動地圖配置部署腳本
# 功能：為"市集活動分佈"組件添加地圖顯示功能
# 作者: Taipei City Dashboard Team
# 日期: 2024-12-08

set -e  # 任何命令失敗就退出

echo "🗺️ 開始部署市集活動地圖配置..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：輸出彩色訊息
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 Docker 是否運行
check_docker() {
    print_status "檢查 Docker 狀態..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker 未運行，請先啟動 Docker"
        exit 1
    fi
    print_success "Docker 狀態正常"
}

# 檢查必要檔案是否存在
check_files() {
    print_status "檢查必要檔案..."
    
    if [ ! -f "db-sample-data/market-events-map-init.sql" ]; then
        print_error "找不到 market-events-map-init.sql 檔案"
        exit 1
    fi
    
    if [ ! -f "Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson" ]; then
        print_error "找不到 market_events_taipei.geojson 檔案"
        exit 1
    fi
    
    if [ ! -f "docker/docker-compose-market-map.yaml" ]; then
        print_error "找不到 docker-compose-market-map.yaml 檔案"
        exit 1
    fi
    
    print_success "所有必要檔案都存在"
}

# 檢查資料庫容器是否運行
check_database() {
    print_status "檢查資料庫容器狀態..."
    
    if ! docker ps | grep -q "postgres-manager"; then
        print_error "postgres-manager 容器未運行"
        print_warning "請先執行: docker-compose -f docker/docker-compose-db.yaml up -d"
        exit 1
    fi
    
    print_success "資料庫容器運行正常"
}

# 執行地圖配置
deploy_market_map() {
    print_status "開始部署市集活動地圖配置..."
    
    # 執行地圖配置 Docker Compose
    docker-compose -f docker/docker-compose-market-map.yaml up market-map-init
    
    if [ $? -eq 0 ]; then
        print_success "市集活動地圖配置已成功部署到資料庫"
    else
        print_error "部署失敗"
        exit 1
    fi
}

# 驗證部署結果
verify_deployment() {
    print_status "驗證部署結果..."
    
    # 檢查地圖配置是否創建成功
    MAP_CONFIG_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM component_maps WHERE index = 'market_events_taipei';" | tr -d ' ')
    
    if [ "$MAP_CONFIG_COUNT" = "1" ]; then
        print_success "✅ 地圖配置創建成功"
    else
        print_error "❌ 地圖配置創建失敗"
        exit 1
    fi
    
    # 檢查組件關聯是否設置成功
    MAP_CONFIG_IDS=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT map_config_ids FROM query_charts WHERE index = 'commercial_district_density' AND city = 'taipei';" | tr -d ' ')
    
    if [ "$MAP_CONFIG_IDS" != "{}" ] && [ "$MAP_CONFIG_IDS" != "NULL" ]; then
        print_success "✅ 組件地圖關聯設置成功"
    else
        print_error "❌ 組件地圖關聯設置失敗"
        exit 1
    fi
}

# 重啟後端服務
restart_backend() {
    print_status "重啟後端服務..."
    
    if docker ps | grep -q "dashboard-be"; then
        docker restart dashboard-be
        print_success "後端服務重啟完成"
        
        # 等待服務啟動
        print_status "等待後端服務啟動..."
        sleep 5
        
        # 檢查服務狀態
        if docker ps | grep -q "dashboard-be"; then
            print_success "後端服務運行正常"
        else
            print_warning "後端服務可能尚未完全啟動，請稍後檢查"
        fi
    else
        print_warning "未找到運行中的 dashboard-be 容器"
        print_status "請手動啟動後端服務: docker-compose -f docker/docker-compose.yaml up -d dashboard-be"
    fi
}

# 顯示完成訊息
show_completion_message() {
    echo ""
    echo "🎉 市集活動地圖配置部署完成！"
    echo ""
    echo "📋 部署摘要:"
    echo "  • 地圖配置名稱: 市集活動分佈點"
    echo "  • 圖層類型: circle (紅色圓點)"
    echo "  • 資料來源: market_events_taipei.geojson"
    echo "  • 市集數量: 18個台北市集活動"
    echo "  • 已關聯組件: 市集活動分佈 (commercial_district_density)"
    echo ""
    echo "🗺️ 地圖功能特色:"
    echo "  • 📍 紅色圓點標示: 每個市集位置以紅色圓點顯示"
    echo "  • 🔍 縮放響應: 地圖縮放時圓點大小自動調整"
    echo "  • 💬 彈出資訊: 點擊圓點顯示市集詳細資訊"
    echo "  • 🏙️ 行政區分佈: 覆蓋台北市12個行政區"
    echo "  • 📅 活動時間: 顯示開始和結束日期"
    echo ""
    echo "📊 市集分佈概況:"
    echo "  • 中山區: 4個市集 (圓山花博、安森町等)"
    echo "  • 大安區: 4個市集 (忠孝敦化、大安森林公園等)"
    echo "  • 信義區: 3個市集 (風格酒食、南村等)"
    echo "  • 萬華區: 2個市集 (龍山文創相關)"
    echo "  • 其他區域: 5個市集"
    echo ""
    echo "🌐 如何查看:"
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 登入系統"
    echo "  3. 點擊左側選單「地圖檢視」"
    echo "  4. 在組件列表中找到「市集活動分佈」"
    echo "  5. 點擊展開組件，地圖上將顯示紅色圓點"
    echo "  6. 點擊任一紅點查看市集詳細資訊"
    echo ""
    echo "🎯 地圖樣式:"
    echo "  • 圓點顏色: #FF6B6B (紅色)"
    echo "  • 邊框顏色: #FFFFFF (白色)"
    echo "  • 透明度: 80%"
    echo "  • 大小範圍: 4-12px (依縮放級別調整)"
    echo ""
    echo "🔧 如果遇到問題:"
    echo "  • 檢查容器狀態: docker ps"
    echo "  • 查看後端日誌: docker logs dashboard-be"
    echo "  • 重新部署: ./scripts/setup-market-map.sh"
    echo "  • 清除瀏覽器快取並重新整理頁面"
    echo ""
}

# 主執行流程
main() {
    echo "=================================================="
    echo "  台北城市儀表板 - 市集活動地圖配置工具         "
    echo "           🗺️ 添加地圖視覺化功能                "
    echo "=================================================="
    echo ""
    
    check_docker
    check_files
    check_database
    deploy_market_map
    verify_deployment
    restart_backend
    show_completion_message
    
    print_success "🚀 市集活動地圖配置完成！現在可以在地圖檢視中看到市集位置"
}

# 執行主函數
main "$@" 
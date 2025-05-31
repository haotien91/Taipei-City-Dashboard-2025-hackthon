#!/bin/bash

# 商圈活化儀表板完整部署腳本 (含假資料)
# 作者: Taipei City Dashboard Team
# 版本: 2.1 - 模組化版本 (支援刷新模式)
# 日期: 2024-03-21
# 特色: 模組化部署 + 假資料生成 + 支援重複執行

set -e  # 任何命令失敗就退出

echo "🚀 開始部署商圈活化儀表板 (模組化 + 刷新模式)..."

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

# 檢查必要的容器是否運行
check_containers() {
    print_status "檢查必要容器狀態..."
    
    # 檢查 postgres-manager 容器
    if ! docker ps | grep -q "postgres-manager"; then
        print_error "postgres-manager 容器未運行"
        print_warning "請先執行: docker-compose -f docker/docker-compose-db.yaml up -d"
        exit 1
    fi
    
    # 檢查 postgres-data 容器
    if ! docker ps | grep -q "postgres-data"; then
        print_error "postgres-data 容器未運行"
        print_warning "請先執行: docker-compose -f docker/docker-compose-db.yaml up -d"
        exit 1
    fi
    
    # 檢查 dashboard-be 容器
    if ! docker ps | grep -q "dashboard-be"; then
        print_warning "dashboard-be 容器未運行，稍後將自動重啟"
    fi
    
    print_success "容器狀態檢查完成"
}

# 創建基礎儀表板
create_base_dashboard() {
    print_status "創建基礎商圈活化儀表板..."
    
    # 執行基礎儀表板創建
    docker-compose -f docker/docker-compose-commercial-district.yaml up
    
    if [ $? -eq 0 ]; then
        print_success "基礎儀表板創建成功"
    else
        print_error "基礎儀表板創建失敗"
        exit 1
    fi
}

# 部署模組化組件
deploy_components() {
    print_status "開始部署模組化組件..."
    
    # 給予腳本執行權限
    chmod +x scripts/modules/*.sh
    
    # 部署商圈人流分析組件
    print_status "部署商圈人流分析組件..."
    ./scripts/modules/commercial-district-flow.sh
    
    if [ $? -eq 0 ]; then
        print_success "商圈人流分析組件部署成功"
    else
        print_error "商圈人流分析組件部署失敗"
        exit 1
    fi
}

# 驗證部署結果
verify_deployment() {
    print_status "驗證部署結果..."
    
    # 檢查儀表板是否創建成功
    DASHBOARD_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM dashboards WHERE index = 'commercial_district';" | tr -d ' ')
    
    if [ "$DASHBOARD_COUNT" = "1" ]; then
        print_success "✅ 儀表板創建成功"
    else
        print_error "❌ 儀表板創建失敗"
        exit 1
    fi
    
    # 檢查組件是否創建成功
    COMPONENT_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM components WHERE index = 'commercial_district_flow';" | tr -d ' ')
    
    if [ "$COMPONENT_COUNT" = "1" ]; then
        print_success "✅ 組件創建成功"
    else
        print_error "❌ 組件創建失敗"
        exit 1
    fi
    
    # 檢查假資料是否插入成功
    DATA_COUNT=$(docker exec postgres-data psql -U postgres -d dashboard -t -c "SELECT COUNT(*) FROM commercial_district_flow_data;" | tr -d ' ')
    
    if [ "$DATA_COUNT" -gt "0" ]; then
        print_success "✅ 假資料插入成功 ($DATA_COUNT 筆)"
    else
        print_error "❌ 假資料插入失敗"
        exit 1
    fi
    
    # 檢查 components 欄位是否正確設置
    COMPONENTS_ARRAY=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT components FROM dashboards WHERE index = 'commercial_district';" | tr -d ' ')
    
    if [ "$COMPONENTS_ARRAY" != "{}" ]; then
        print_success "✅ 組件關聯設置成功"
    else
        print_error "❌ 組件關聯設置失敗"
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
    echo "🎉 商圈活化儀表板部署完成！"
    echo ""
    echo "📋 部署摘要:"
    echo "  • 儀表板名稱: 商圈活化"
    echo "  • 組件數量: 1 (商圈人流分析)"
    echo "  • 權限群組: taipei"
    echo "  • 圖標: store"
    echo "  • 🔄 刷新模式: 支援重複執行，自動更新資料"
    echo "  • 假資料: $(docker exec postgres-data psql -U postgres -d dashboard -t -c "SELECT COUNT(*) FROM commercial_district_flow_data;" | tr -d ' ') 筆商圈人流記錄"
    echo ""
    echo "📊 假資料內容:"
    echo "  • 商圈: 西門町、信義區、東區、士林夜市等 8 個熱門商圈"
    echo "  • 時段: 08:00-24:00 分 8 個時段"
    echo "  • 資料期間: 最近 7 天"
    echo "  • 人流類型: 進入、離開、停留"
    echo ""
    echo "🌐 如何查看:"
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 登入系統"
    echo "  3. 在左側選單的「臺北儀表板」區塊中找到「商圈活化」"
    echo "  4. 點擊進入即可看到豐富的人流分析圖表"
    echo "  5. 如果看不到，請強制刷新頁面 (Ctrl+Shift+R 或 Cmd+Shift+R)"
    echo ""
    echo "🔧 模組化優勢:"
    echo "  • 可單獨部署各個組件"
    echo "  • 易於添加新的分析模組"
    echo "  • 假資料自動生成"
    echo "  • 完整的錯誤檢查"
    echo "  • ✨ 支援刷新模式，避免重複記錄"
    echo ""
    echo "🔄 刷新模式優勢:"
    echo "  • ✅ 可以安全地多次執行此腳本"
    echo "  • ✅ 自動更新現有配置，不會產生重複記錄"
    echo "  • ✅ 適合開發測試階段頻繁更新配置"
    echo "  • ✅ 模組化組件也支援刷新更新"
    echo ""
    echo "🚀 後續擴展:"
    echo "  • 可使用 scripts/modules/create-component.sh 創建新組件"
    echo "  • 參考 scripts/modules/commercial-district-flow.sh 的模式"
    echo "  • 所有組件都會自動整合到商圈活化儀表板"
    echo "  • 💡 此腳本支援多次執行，不會產生重複資料"
    echo ""
}

# 主執行流程
main() {
    echo "=================================================="
    echo "  台北城市儀表板 - 商圈活化模組部署工具 v2.1    "
    echo "           (模組化 + 假資料 + 刷新模式版本)           "
    echo "=================================================="
    echo ""
    
    check_docker
    check_containers
    create_base_dashboard
    deploy_components
    verify_deployment
    restart_backend
    show_completion_message
    
    print_success "🚀 模組化部署完成！可重複執行以更新配置"
}

# 執行主函數
main "$@" 
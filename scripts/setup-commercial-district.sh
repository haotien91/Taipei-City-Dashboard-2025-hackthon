#!/bin/bash

# 商圈活化儀表板自動化部署腳本
# 作者: Taipei City Dashboard Team
# 版本: 1.1 - 基礎版本 (支援刷新模式)
# 日期: 2024-03-21
# 特色: 支援重複執行，自動刷新資料而不重複新增

set -e  # 任何命令失敗就退出

echo "🚀 開始部署商圈活化儀表板 (刷新模式)..."

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
    
    # 檢查 dashboard-be 容器
    if ! docker ps | grep -q "dashboard-be"; then
        print_warning "dashboard-be 容器未運行，稍後將自動重啟"
    fi
    
    print_success "容器狀態檢查完成"
}

# 執行商圈活化初始化
deploy_commercial_district() {
    print_status "開始部署商圈活化儀表板..."
    
    # 執行初始化 Docker Compose
    docker-compose -f docker/docker-compose-commercial-district.yaml up
    
    if [ $? -eq 0 ]; then
        print_success "商圈活化儀表板配置已成功部署到資料庫"
    else
        print_error "部署失敗"
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
    echo "  • 組件數量: 2 (商圈人流分析 + 市集活動分佈)"
    echo "  • 權限群組: taipei"
    echo "  • 圖標: store"
    echo "  • 🔄 刷新模式: 支援重複執行，自動更新資料"
    echo ""
    echo "📊 功能特色:"
    echo "  • 📈 人流分析: 顯示商圈人流變化趨勢"
    echo "  • 🗺️ 行政區圖: 台北市12行政區商圈密度視覺化"
    echo "  • 📊 商店數量統計: 各區商店分布情況"
    echo "  • 💰 平均營業額指標: 各區商業活力評估"
    echo "  • ✨ 智慧更新: 避免重複記錄，安全重複執行"
    echo ""
    echo "🔄 刷新模式優勢:"
    echo "  • ✅ 可以安全地多次執行此腳本"
    echo "  • ✅ 自動更新現有配置，不會產生重複記錄"
    echo "  • ✅ 保持資料庫整潔，避免垃圾資料累積"
    echo "  • ✅ 適合開發測試階段頻繁更新配置"
    echo ""
    echo "🌐 如何查看:"
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 登入系統"
    echo "  3. 在左側選單的「臺北儀表板」區塊中找到「商圈活化」"
    echo "  4. 點擊進入即可看到人流分析和密度分布圖表"
    echo "  5. 如果看不到，請強制刷新頁面 (Ctrl+Shift+R 或 Cmd+Shift+R)"
    echo ""
    echo "🎯 示範數據內容:"
    echo "  📊 人流分析:"
    echo "    • 商圈人流量: 1000人"
    echo "    • 商圈店家數: 50家"
    echo ""
    echo "  🏙️ 密度分布 (台北市12行政區):"
    echo "    • 信義區: 380家店鋪，平均營業額150"
    echo "    • 中山區: 450家店鋪，平均營業額135"
    echo "    • 大安區: 420家店鋪，平均營業額140"
    echo "    • 其他區域: 各具特色的商業分布"
    echo ""
    echo "🔧 如果遇到問題:"
    echo "  • 檢查容器狀態: docker ps"
    echo "  • 查看後端日誌: docker logs dashboard-be"
    echo "  • 重新部署: ./scripts/setup-commercial-district.sh"
    echo "  • 💡 此腳本支援多次執行，不會產生重複資料"
    echo ""
}

# 主執行流程
main() {
    echo "=================================================="
    echo "  台北城市儀表板 - 商圈活化模組部署工具        "
    echo "                (基礎版本 v1.1)                  "
    echo "              🔄 支援刷新模式執行                "
    echo "=================================================="
    echo ""
    
    check_docker
    check_containers
    deploy_commercial_district
    verify_deployment
    restart_backend
    show_completion_message
    
    print_success "🚀 基礎版本部署完成！可重複執行以更新配置"
}

# 執行主函數
main "$@" 
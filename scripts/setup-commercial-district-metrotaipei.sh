#!/bin/bash

# 雙北商圈活化儀表板自動化部署腳本
# 作者: Taipei City Dashboard Team
# 版本: 1.1 - 雙北版本 (支援刷新模式)
# 日期: 2024-03-21
# 適用範圍: 台北市 + 新北市
# 特色: 支援重複執行，自動刷新資料而不重複新增

set -e  # 任何命令失敗就退出

echo "🚀 開始部署雙北商圈活化儀表板 (刷新模式)..."

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

# 執行雙北商圈活化初始化
deploy_commercial_district_metrotaipei() {
    print_status "開始部署雙北商圈活化儀表板..."
    
    # 檢查初始化檔案是否存在
    if [ ! -f "db-sample-data/commercial-district-metrotaipei-init.sql" ]; then
        print_error "找不到雙北商圈活化初始化檔案: db-sample-data/commercial-district-metrotaipei-init.sql"
        exit 1
    fi
    
    # 檢查 Docker Compose 檔案是否存在
    if [ ! -f "docker/docker-compose-commercial-district-metrotaipei.yaml" ]; then
        print_error "找不到雙北商圈活化 Docker Compose 檔案: docker/docker-compose-commercial-district-metrotaipei.yaml"
        exit 1
    fi
    
    # 執行雙北版本的初始化 Docker Compose
    print_status "執行雙北商圈活化配置..."
    docker-compose -f docker/docker-compose-commercial-district-metrotaipei.yaml up
    
    if [ $? -eq 0 ]; then
        print_success "雙北商圈活化儀表板配置已成功部署到資料庫"
    else
        print_error "部署失敗"
        exit 1
    fi
}

# 驗證部署結果
verify_deployment() {
    print_status "驗證雙北版本部署結果..."
    
    # 檢查儀表板是否創建成功
    DASHBOARD_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM dashboards WHERE index = 'commercial_district_metrotaipei';" | tr -d ' ')
    
    if [ "$DASHBOARD_COUNT" = "1" ]; then
        print_success "✅ 雙北儀表板創建成功"
    else
        print_error "❌ 雙北儀表板創建失敗"
        exit 1
    fi
    
    # 檢查人流分析組件是否創建成功
    FLOW_COMPONENT_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM components WHERE index = 'commercial_district_flow_metrotaipei';" | tr -d ' ')
    
    if [ "$FLOW_COMPONENT_COUNT" = "1" ]; then
        print_success "✅ 雙北人流分析組件創建成功"
    else
        print_error "❌ 雙北人流分析組件創建失敗"
        exit 1
    fi
    
    # 檢查密度分析組件是否創建成功
    DENSITY_COMPONENT_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM components WHERE index = 'commercial_district_density_metrotaipei';" | tr -d ' ')
    
    if [ "$DENSITY_COMPONENT_COUNT" = "1" ]; then
        print_success "✅ 雙北密度分析組件創建成功"
    else
        print_error "❌ 雙北密度分析組件創建失敗"
        exit 1
    fi
    
    # 檢查人流分析的城市切換功能 (雙北 + 台北市版本)
    FLOW_METROTAIPEI_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM query_charts WHERE index = 'commercial_district_flow_metrotaipei' AND city = 'metrotaipei';" | tr -d ' ')
    FLOW_TAIPEI_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM query_charts WHERE index = 'commercial_district_flow_metrotaipei' AND city = 'taipei';" | tr -d ' ')
    
    if [ "$FLOW_METROTAIPEI_COUNT" = "1" ] && [ "$FLOW_TAIPEI_COUNT" = "1" ]; then
        print_success "✅ 人流分析城市切換功能設置成功 (雙北 + 台北市)"
    else
        print_error "❌ 人流分析城市切換功能設置失敗"
        exit 1
    fi
    
    # 檢查密度分析的城市切換功能 (雙北 + 台北市版本)
    DENSITY_METROTAIPEI_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM query_charts WHERE index = 'commercial_district_density_metrotaipei' AND city = 'metrotaipei';" | tr -d ' ')
    DENSITY_TAIPEI_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM query_charts WHERE index = 'commercial_district_density_metrotaipei' AND city = 'taipei';" | tr -d ' ')
    
    if [ "$DENSITY_METROTAIPEI_COUNT" = "1" ] && [ "$DENSITY_TAIPEI_COUNT" = "1" ]; then
        print_success "✅ 密度分析城市切換功能設置成功 (雙北 + 台北市)"
    else
        print_error "❌ 密度分析城市切換功能設置失敗"
        exit 1
    fi
    
    # 檢查 components 欄位是否正確設置
    COMPONENTS_ARRAY=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT components FROM dashboards WHERE index = 'commercial_district_metrotaipei';" | tr -d ' ')
    
    if [ "$COMPONENTS_ARRAY" != "{}" ]; then
        print_success "✅ 雙北組件關聯設置成功"
    else
        print_error "❌ 雙北組件關聯設置失敗"
        exit 1
    fi
    
    # 檢查群組權限是否正確
    GROUP_ASSIGNMENT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM dashboard_groups dg JOIN dashboards d ON dg.dashboard_id = d.id JOIN groups g ON dg.group_id = g.id WHERE d.index = 'commercial_district_metrotaipei' AND g.name = 'metrotaipei';" | tr -d ' ')
    
    if [ "$GROUP_ASSIGNMENT" = "1" ]; then
        print_success "✅ 雙北群組權限設置成功"
    else
        print_error "❌ 雙北群組權限設置失敗"
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
    echo "🎉 雙北商圈活化儀表板部署完成！"
    echo ""
    echo "📋 部署摘要:"
    echo "  • 儀表板名稱: 商圈活化 (雙北版本)"
    echo "  • 組件數量: 2 (雙北商圈人流分析 + 雙北商圈密度分布)"
    echo "  • 權限群組: metrotaipei"
    echo "  • 圖標: store"
    echo "  • 涵蓋範圍: 台北市12區 + 新北市12主要區域"
    echo "  • 🔄 刷新模式: 支援重複執行，自動更新資料"
    echo ""
    echo "📊 功能特色:"
    echo "  • 🏙️ 跨市人流分析: 台北市 vs 新北市商圈對比"
    echo "  • 🗺️ 雙北行政區圖: 24個行政區商圈密度視覺化"
    echo "  • 📈 商店數量統計: 各區商店分布情況"
    echo "  • 💰 平均營業額指標: 各區商業活力評估"
    echo "  • 🔄 城市切換功能: 雙北 ⇄ 台北市 資料切換"
    echo "  • ✨ 智慧更新: 避免重複記錄，安全重複執行"
    echo ""
    echo "🔄 刷新模式優勢:"
    echo "  • ✅ 可以安全地多次執行此腳本"
    echo "  • ✅ 自動更新現有配置，不會產生重複記錄"
    echo "  • ✅ 保持資料庫整潔，避免垃圾資料累積"
    echo "  • ✅ 適合開發測試階段頻繁更新配置"
    echo ""
    echo "🔄 城市切換功能詳情:"
    echo "  • 人流分析圖表支援「雙北」與「台北市」資料切換"
    echo "  • 密度分布圖表支援「雙北24區」與「台北市12區」切換"
    echo "  • 雙北模式: 顯示台北市+新北市綜合數據"
    echo "  • 台北市模式: 僅顯示台北市數據，更聚焦分析"
    echo ""
    echo "🌐 如何查看:"
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 登入系統"
    echo "  3. 在左側選單的「雙北儀表板示範」區塊中找到「商圈活化」"
    echo "  4. 點擊圖表右上角的城市切換按鈕 📍"
    echo "  5. 選擇「雙北」或「台北市」查看不同範圍的資料"
    echo "  6. 如果看不到，請強制刷新頁面 (Ctrl+Shift+R 或 Cmd+Shift+R)"
    echo ""
    echo "🎯 示範數據內容:"
    echo "  📊 雙北模式:"
    echo "    • 台北市: 信義區、中山區、大安區等12區"
    echo "    • 新北市: 板橋區、新莊區、中和區等12區"
    echo "    • 人流對比: 台北1200人 vs 新北800人"
    echo "    • 店家對比: 台北60家 vs 新北45家"
    echo ""
    echo "  🏙️ 台北市模式:"
    echo "    • 聚焦台北市12行政區詳細數據"
    echo "    • 熱門商圈: 西門町、信義區、東區、士林夜市"
    echo "    • 人流分析: 信義區1200人領先，士林夜市600人"
    echo "    • 營業額分析: 信義區180最高，士林夜市90"
    echo ""
    echo "🔧 如果遇到問題:"
    echo "  • 檢查容器狀態: docker ps"
    echo "  • 查看後端日誌: docker logs dashboard-be"
    echo "  • 重新部署: ./scripts/setup-commercial-district-metrotaipei.sh"
    echo "  • 如果切換按鈕不顯示，請確認後端服務已重啟"
    echo "  • 💡 此腳本支援多次執行，不會產生重複資料"
    echo ""
}

# 主執行流程
main() {
    echo "=================================================="
    echo "  台北城市儀表板 - 雙北商圈活化模組部署工具    "
    echo "               (雙北儀表板示範版本)               "
    echo "              🔄 支援刷新模式執行                "
    echo "=================================================="
    echo ""
    
    check_docker
    check_containers
    deploy_commercial_district_metrotaipei
    verify_deployment
    restart_backend
    show_completion_message
    
    print_success "🚀 雙北版本部署完成！可重複執行以更新配置"
}

# 執行主函數
main "$@" 
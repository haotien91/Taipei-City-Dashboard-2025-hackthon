#!/bin/bash

# 測試永久商圈活化配置解決方案
# 目的：驗證系統重新初始化後是否還能保持商圈活化配置

set -e

echo "🧪 開始測試永久商圈活化配置解決方案..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 檢查當前配置
check_current_config() {
    print_status "檢查當前商圈活化配置..."
    
    # 檢查儀表板
    DASHBOARDS=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM dashboards WHERE index LIKE '%commercial%';" | tr -d ' ')
    echo "  📊 商圈活化儀表板數量: $DASHBOARDS"
    
    # 檢查組件
    COMPONENTS=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM components WHERE index LIKE '%commercial%';" | tr -d ' ')
    echo "  🧩 商圈活化組件數量: $COMPONENTS"
    
    # 檢查動態地圖
    MAPS=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM component_maps WHERE index LIKE '%market_events%';" | tr -d ' ')
    echo "  🗺️ 動態地圖配置數量: $MAPS"
    
    # 檢查查詢配置
    QUERIES=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT COUNT(*) FROM query_charts WHERE index LIKE '%commercial_district_density%';" | tr -d ' ')
    echo "  📋 查詢圖表配置數量: $QUERIES"
    
    if [ "$DASHBOARDS" -ge "2" ] && [ "$COMPONENTS" -ge "4" ] && [ "$MAPS" -ge "2" ] && [ "$QUERIES" -ge "3" ]; then
        print_success "✅ 當前配置完整"
        return 0
    else
        print_error "❌ 當前配置不完整"
        return 1
    fi
}

# 測試重新初始化
test_reinitialize() {
    print_status "測試重新初始化資料庫..."
    print_warning "這將重置資料庫並重新載入配置"
    
    read -p "是否繼續測試重新初始化？(y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        print_status "跳過重新初始化測試"
        return 0
    fi
    
    print_status "重新初始化資料庫管理器..."
    docker-compose -f docker/docker-compose-init.yaml up dashboard-be-init-manager
    
    if [ $? -eq 0 ]; then
        print_success "資料庫重新初始化完成"
        
        # 等待服務啟動
        sleep 5
        
        # 檢查配置是否保留
        print_status "檢查重新初始化後的配置..."
        if check_current_config; then
            print_success "🎉 測試通過！商圈活化配置在重新初始化後保持完整"
        else
            print_error "❌ 測試失敗！重新初始化後配置丟失"
            return 1
        fi
    else
        print_error "重新初始化失敗"
        return 1
    fi
}

# 檢查環境變數設定
check_env_config() {
    print_status "檢查環境變數設定..."
    
    if grep -q "MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql" .env; then
        print_success "✅ 環境變數設定正確"
    else
        print_error "❌ 環境變數設定錯誤或缺失"
        print_status "預期: MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql"
        print_status "當前: $(grep MANAGER_SAMPLE_FILE .env || echo '未設定')"
        return 1
    fi
}

# 檢查永久初始化文件
check_permanent_file() {
    print_status "檢查永久初始化文件..."
    
    if [ -f "db-sample-data/dashboardmanager-permanent.sql" ]; then
        COMMERCIAL_COUNT=$(grep -c "commercial" db-sample-data/dashboardmanager-permanent.sql)
        MAP_COUNT=$(grep -c "market_events" db-sample-data/dashboardmanager-permanent.sql)
        
        echo "  📄 文件存在: ✅"
        echo "  🏪 商圈配置項目: $COMMERCIAL_COUNT 個"
        echo "  🗺️ 地圖配置項目: $MAP_COUNT 個"
        
        if [ "$COMMERCIAL_COUNT" -ge "10" ] && [ "$MAP_COUNT" -ge "2" ]; then
            print_success "✅ 永久初始化文件內容完整"
        else
            print_error "❌ 永久初始化文件內容不完整"
            return 1
        fi
    else
        print_error "❌ 找不到永久初始化文件"
        return 1
    fi
}

# 顯示測試結果
show_test_results() {
    echo ""
    echo "🧪 測試結果摘要："
    echo ""
    echo "✅ 檢查項目："
    echo "  • 環境變數設定"
    echo "  • 永久初始化文件"
    echo "  • 當前配置完整性"
    if [[ $test_reinit == true ]]; then
        echo "  • 重新初始化後配置保持"
    fi
    echo ""
    echo "🎯 解決方案效果："
    echo "  • 🔒 商圈活化配置已永久化"
    echo "  • 🚀 系統啟動時自動載入"
    echo "  • 🛡️ 不再需要手動執行腳本"
    echo "  • 🔄 支援重複初始化"
    echo ""
    print_success "🎉 永久解決方案測試完成！"
}

# 顯示使用指南
show_usage_guide() {
    echo ""
    echo "📖 使用指南："
    echo ""
    echo "🔄 日常使用："
    echo "  • 系統啟動時會自動載入商圈活化配置"
    echo "  • 不需要手動執行任何腳本"
    echo "  • 所有功能都會正常運作"
    echo ""
    echo "🚀 如果需要更新配置："
    echo "  1. 執行商圈活化腳本："
    echo "     ./scripts/setup-commercial-district-with-dynamic.sh"
    echo ""
    echo "  2. 重新生成永久配置："
    echo "     ./scripts/create-permanent-init.sh"
    echo "     ./scripts/switch-to-permanent-init.sh"
    echo ""
    echo "🔧 恢復原始配置："
    echo "  1. 恢復原始環境變數："
    echo "     cp .env.backup .env"
    echo ""
    echo "  2. 重新初始化："
    echo "     docker-compose -f docker/docker-compose-init.yaml up dashboard-be-init-manager"
    echo ""
}

# 主執行流程
main() {
    echo "=================================================="
    echo "    商圈活化配置永久化解決方案測試工具         "
    echo "  🧪 驗證系統重啟後是否還能保持配置           "
    echo "=================================================="
    echo ""
    
    # 執行檢查
    check_env_config || exit 1
    check_permanent_file || exit 1
    check_current_config || exit 1
    
    # 詢問是否測試重新初始化
    test_reinit=false
    echo ""
    print_status "是否要測試重新初始化？這將驗證配置是否真的永久化"
    read -p "執行重新初始化測試？(y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        test_reinit=true
        test_reinitialize
    fi
    
    show_test_results
    show_usage_guide
}

# 執行主函數
main "$@" 
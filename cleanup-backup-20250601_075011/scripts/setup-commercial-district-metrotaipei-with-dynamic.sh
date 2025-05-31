#!/bin/bash

# 雙北商圈活化儀表板自動化部署腳本 (含動態地圖保護)
# 作者: Taipei City Dashboard Team
# 版本: 2.0 - 增強版本 (保護動態地圖功能)
# 適用範圍: 台北市 + 新北市
# 目的：執行基礎雙北商圈設置後自動恢復動態地圖功能

set -e  # 任何命令失敗就退出

echo "🚀 開始部署雙北商圈活化儀表板 (含動態地圖保護)..."

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

# 檢查腳本是否存在
check_scripts() {
    print_status "檢查必要腳本..."
    
    if [ ! -f "scripts/setup-commercial-district-metrotaipei.sh" ]; then
        print_error "找不到基礎設置腳本: scripts/setup-commercial-district-metrotaipei.sh"
        exit 1
    fi
    
    if [ ! -f "scripts/restore-dynamic-map-config.sh" ]; then
        print_error "找不到動態配置恢復腳本: scripts/restore-dynamic-map-config.sh"
        exit 1
    fi
    
    print_success "腳本檢查完成"
}

# 執行基礎雙北商圈設置
execute_basic_setup() {
    print_status "步驟 1/2：執行基礎雙北商圈活化設置..."
    echo "=================================================="
    
    ./scripts/setup-commercial-district-metrotaipei.sh
    
    if [ $? -eq 0 ]; then
        print_success "基礎雙北商圈活化設置完成"
    else
        print_error "基礎設置失敗"
        exit 1
    fi
    
    echo ""
    print_warning "基礎設置已完成，但動態地圖功能已被覆蓋"
    print_status "正在準備恢復動態地圖功能..."
    sleep 2
}

# 恢復動態地圖功能
restore_dynamic_maps() {
    print_status "步驟 2/2：恢復動態地圖功能..."
    echo "=================================================="
    
    ./scripts/restore-dynamic-map-config.sh
    
    if [ $? -eq 0 ]; then
        print_success "動態地圖功能恢復完成"
    else
        print_error "動態地圖功能恢復失敗"
        exit 1
    fi
}

# 最終驗證
final_verification() {
    print_status "最終驗證..."
    
    # 檢查雙北組件是否有動態地圖配置
    METRO_MAP_ID=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT map_config_ids[1] FROM public.query_charts WHERE index = 'commercial_district_density_metrotaipei' AND city = 'metrotaipei';" 2>/dev/null | tr -d ' ')
    
    if [ ! -z "$METRO_MAP_ID" ] && [ "$METRO_MAP_ID" != "NULL" ]; then
        print_success "✅ 雙北市集動態地圖功能已就緒"
    else
        print_warning "⚠️ 雙北市集動態地圖配置可能有問題"
    fi
    
    # 檢查台北版本的雙北組件
    TAIPEI_METRO_MAP_ID=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT map_config_ids[1] FROM public.query_charts WHERE index = 'commercial_district_density_metrotaipei' AND city = 'taipei';" 2>/dev/null | tr -d ' ')
    
    if [ ! -z "$TAIPEI_METRO_MAP_ID" ] && [ "$TAIPEI_METRO_MAP_ID" != "NULL" ]; then
        print_success "✅ 台北版本動態地圖功能已就緒"
    else
        print_warning "⚠️ 台北版本動態地圖配置可能有問題"
    fi
    
    # 檢查 GeoJSON 檔案
    if [ -f "Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson" ]; then
        FEATURE_COUNT=$(jq '.features | length' Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson 2>/dev/null || echo "0")
        if [ "$FEATURE_COUNT" -gt "0" ]; then
            print_success "✅ 雙北市集 GeoJSON 檔案正常 ($FEATURE_COUNT 個活動)"
        else
            print_warning "⚠️ 雙北市集 GeoJSON 檔案可能有問題"
        fi
    else
        print_warning "⚠️ 雙北市集 GeoJSON 檔案不存在"
    fi
    
    if [ -f "Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson" ]; then
        TAIPEI_FEATURE_COUNT=$(jq '.features | length' Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson 2>/dev/null || echo "0")
        if [ "$TAIPEI_FEATURE_COUNT" -gt "0" ]; then
            print_success "✅ 台北市集 GeoJSON 檔案正常 ($TAIPEI_FEATURE_COUNT 個活動)"
        else
            print_warning "⚠️ 台北市集 GeoJSON 檔案可能有問題"
        fi
    else
        print_warning "⚠️ 台北市集 GeoJSON 檔案不存在"
    fi
}

# 顯示完成訊息
show_completion_message() {
    echo ""
    echo "🎉 雙北商圈活化儀表板部署完成 (含動態地圖功能)！"
    echo ""
    echo "📋 部署摘要:"
    echo "  • ✅ 雙北商圈活化儀表板已部署"
    echo "  • ✅ 動態地圖功能已恢復並保護"
    echo "  • ✅ 市集活動圓點支援動態顏色變化"
    echo "  • ✅ 支援城市切換 (雙北 ↔ 台北市)"
    echo "  • ✅ 支援重複執行，自動更新配置"
    echo ""
    echo "🎨 動態地圖功能特色:"
    echo "  • 🔵 藍色圓點: 尚未開始的活動"
    echo "  • 🟢 綠色圓點: 正在進行的活動"
    echo "  • 🟡 黃色圓點: 活動剩2個禮拜結束"
    echo "  • 🟠 橘色圓點: 活動剩1個禮拜結束"
    echo "  • 🔴 紅色圓點: 活動剩3天結束"
    echo "  • ⚪ 白色邊框: 增強視覺效果"
    echo "  • 📏 縮放響應: 隨地圖縮放調整大小"
    echo "  • 🔄 城市切換: 雙北/台北市資料切換"
    echo ""
    echo "📊 包含組件:"
    echo "  • 雙北商圈人流分析: 跨市人流比較"
    echo "  • 雙北市集活動分佈: 動態顏色地圖視覺化"
    echo "  • 行政區圖表: 雙北24區商圈統計"
    echo "  • 城市切換功能: 雙北 ↔ 台北市"
    echo ""
    echo "🌐 如何查看:"
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 強制刷新頁面 (Ctrl+Shift+R 或 Cmd+Shift+R)"
    echo "  3. 登入系統"
    echo "  4. 在左側選單「雙北儀表板示範」找到「商圈活化」"
    echo "  5. 切換到「地圖檢視」查看動態地圖"
    echo "  6. 展開「雙北市集活動分佈」組件"
    echo "  7. 點擊圖表右上角 📍 切換城市"
    echo "  8. 點擊圓點查看活動詳細資訊"
    echo ""
    echo "🔄 城市切換功能:"
    echo "  • 雙北模式: 顯示台北市+新北市所有市集活動"
    echo "  • 台北市模式: 僅顯示台北市市集活動"
    echo "  • 動態切換: 即時更新地圖資料與統計"
    echo ""
    echo "🔄 優勢特色:"
    echo "  • ✅ 一鍵部署: 無需手動執行多個腳本"
    echo "  • ✅ 自動保護: 動態功能不會被覆蓋"
    echo "  • ✅ 智慧恢復: 自動恢復所有動態配置"
    echo "  • ✅ 完整驗證: 確保所有功能正常運作"
    echo "  • ✅ 跨市支援: 雙北資料統一管理"
    echo ""
    echo "🔧 如果遇到問題:"
    echo "  • 檢查容器狀態: docker ps"
    echo "  • 查看後端日誌: docker logs dashboard-be"
    echo "  • 重新執行: ./scripts/setup-commercial-district-metrotaipei-with-dynamic.sh"
    echo "  • 單獨恢復動態功能: ./scripts/restore-dynamic-map-config.sh"
    echo ""
    print_success "🚀 雙北版本部署完成！現在可以享受動態市集地圖了！"
}

# 主執行流程
main() {
    echo "=================================================="
    echo "  台北城市儀表板 - 雙北商圈活化模組部署工具    "
    echo "           (v2.0 - 含動態地圖保護)             "
    echo "              🎨 自動保護動態功能                "
    echo "             🏙️ 支援雙北城市切換               "
    echo "=================================================="
    echo ""
    
    check_scripts
    execute_basic_setup
    restore_dynamic_maps
    final_verification
    show_completion_message
}

# 執行主函數
main "$@" 
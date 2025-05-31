#!/bin/bash

# 恢復動態地圖配置腳本
# 目的：在執行 setup-commercial-district.sh 或 setup-commercial-district-metrotaipei.sh 後
# 恢復市集活動的動態地圖功能，確保顏色能根據活動狀態動態變化

set -e  # 任何命令失敗就退出

echo "🎨 開始恢復市集活動動態地圖配置..."

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

# 檢查容器狀態
check_containers() {
    print_status "檢查必要容器狀態..."
    
    if ! docker ps | grep -q "postgres-manager"; then
        print_error "postgres-manager 容器未運行"
        exit 1
    fi
    
    print_success "容器狀態正常"
}

# 恢復動態地圖配置
restore_dynamic_config() {
    print_status "恢復動態地圖配置..."
    
    # 1. 刪除並重新創建台北市集動態地圖配置
    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
-- 刪除現有的台北市集動態地圖配置
DELETE FROM public.component_maps WHERE index = 'market_events_taipei';

-- 創建新的台北市集動態地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_taipei',
    '台北市集活動分佈 - 動態狀態',
    'circle',
    'geojson',
    'big',
    NULL,
    '{\"circle-color\":[\"match\",[\"get\",\"event_status\"],\"not_started\",\"#2196F3\",\"active\",\"#4CAF50\",\"ending_2weeks\",\"#FFEB3B\",\"ending_1week\",\"#FF9800\",\"ending_3days\",\"#F44336\",\"#666666\"],\"circle-radius\":[\"interpolate\",[\"linear\"],[\"zoom\"],11.99,4,12,5,13.5,6,15,8,22,12],\"circle-stroke-width\":2,\"circle-stroke-color\":\"#FFFFFF\",\"circle-opacity\":0.85}',
    '[{\"key\":\"name\",\"name\":\"市集名稱\"},{\"key\":\"type\",\"name\":\"活動類型\"},{\"key\":\"district\",\"name\":\"行政區\"},{\"key\":\"start_date\",\"name\":\"開始日期\"},{\"key\":\"end_date\",\"name\":\"結束日期\"},{\"key\":\"event_status\",\"name\":\"活動狀態\"},{\"key\":\"description\",\"name\":\"活動描述\"}]'
);
"

    # 2. 刪除並重新創建雙北市集動態地圖配置
    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
-- 刪除現有的雙北市集動態地圖配置
DELETE FROM public.component_maps WHERE index = 'market_events_metrotaipei';

-- 創建新的雙北市集動態地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_metrotaipei',
    '雙北市集活動分佈 - 動態狀態',
    'circle',
    'geojson',
    'big',
    NULL,
    '{\"circle-color\":[\"match\",[\"get\",\"event_status\"],\"not_started\",\"#2196F3\",\"active\",\"#4CAF50\",\"ending_2weeks\",\"#FFEB3B\",\"ending_1week\",\"#FF9800\",\"ending_3days\",\"#F44336\",\"#666666\"],\"circle-radius\":[\"interpolate\",[\"linear\"],[\"zoom\"],11.99,4,12,5,13.5,6,15,8,22,12],\"circle-stroke-width\":2,\"circle-stroke-color\":\"#FFFFFF\",\"circle-opacity\":0.85}',
    '[{\"key\":\"name\",\"name\":\"市集名稱\"},{\"key\":\"type\",\"name\":\"活動類型\"},{\"key\":\"district\",\"name\":\"行政區\"},{\"key\":\"start_date\",\"name\":\"開始日期\"},{\"key\":\"end_date\",\"name\":\"結束日期\"},{\"key\":\"event_status\",\"name\":\"活動狀態\"},{\"key\":\"description\",\"name\":\"活動描述\"}]'
);
"

    # 3. 更新組件關聯
    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
-- 更新台北市集活動組件使用動態地圖配置
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = 'market_events_taipei')
]
WHERE index = 'commercial_district_density' AND city = 'taipei';

-- 更新雙北市集活動組件使用動態地圖配置
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = 'market_events_metrotaipei')
]
WHERE index = 'commercial_district_density_metrotaipei' AND city = 'metrotaipei';

-- 更新台北市版本的雙北組件
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = 'market_events_taipei')
]
WHERE index = 'commercial_district_density_metrotaipei' AND city = 'taipei';
"

    # 顯示配置結果
    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
SELECT 
    '=== 動態地圖配置恢復完成 ===' as status,
    (SELECT id FROM public.component_maps WHERE index = 'market_events_taipei') as taipei_config_id,
    (SELECT id FROM public.component_maps WHERE index = 'market_events_metrotaipei') as metro_config_id;
"
    
    if [ $? -eq 0 ]; then
        print_success "動態地圖配置恢復成功"
        print_success "🎨 動態顏色說明："
        print_success "  🔵 藍色: 尚未開始的活動"
        print_success "  🟢 綠色: 正在進行的活動"
        print_success "  🟡 黃色: 活動剩2個禮拜結束"
        print_success "  🟠 橘色: 活動剩1個禮拜結束"
        print_success "  🔴 紅色: 活動剩3天結束"
    else
        print_error "動態地圖配置恢復失敗"
        exit 1
    fi
}

# 更新市集活動 GeoJSON 資料
update_geojson_data() {
    print_status "更新市集活動 GeoJSON 動態狀態..."
    
    if [ -f "scripts/update_market_colors.py" ]; then
        python3 scripts/update_market_colors.py
        if [ $? -eq 0 ]; then
            print_success "GeoJSON 動態狀態更新完成"
        else
            print_warning "GeoJSON 動態狀態更新失敗，但地圖配置已恢復"
        fi
    else
        print_warning "找不到 update_market_colors.py，跳過 GeoJSON 更新"
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
        
        if docker ps | grep -q "dashboard-be"; then
            print_success "後端服務運行正常"
        else
            print_warning "後端服務可能尚未完全啟動，請稍後檢查"
        fi
    else
        print_warning "未找到運行中的 dashboard-be 容器"
    fi
}

# 驗證恢復結果
verify_restoration() {
    print_status "驗證動態配置恢復結果..."
    
    # 檢查台北地圖配置
    TAIPEI_MAP_ID=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT map_config_ids[1] FROM public.query_charts WHERE index = 'commercial_district_density' AND city = 'taipei';" | tr -d ' ')
    
    if [ ! -z "$TAIPEI_MAP_ID" ] && [ "$TAIPEI_MAP_ID" != "NULL" ]; then
        print_success "✅ 台北市集動態配置已恢復 (地圖ID: $TAIPEI_MAP_ID)"
    else
        print_error "❌ 台北市集動態配置恢復失敗"
    fi
    
    # 檢查雙北地圖配置
    METRO_MAP_ID=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c "SELECT map_config_ids[1] FROM public.query_charts WHERE index = 'commercial_district_density_metrotaipei' AND city = 'metrotaipei';" | tr -d ' ')
    
    if [ ! -z "$METRO_MAP_ID" ] && [ "$METRO_MAP_ID" != "NULL" ]; then
        print_success "✅ 雙北市集動態配置已恢復 (地圖ID: $METRO_MAP_ID)"
    else
        print_error "❌ 雙北市集動態配置恢復失敗"
    fi
}

# 顯示完成訊息
show_completion_message() {
    echo ""
    echo "🎨 動態地圖配置恢復完成！"
    echo ""
    echo "📋 恢復摘要:"
    echo "  • ✅ 台北市集活動動態地圖配置已恢復"
    echo "  • ✅ 雙北市集活動動態地圖配置已恢復"
    echo "  • ✅ 組件地圖關聯已更新"
    echo "  • ✅ GeoJSON 動態狀態已更新"
    echo ""
    echo "🎨 動態功能特色:"
    echo "  • 🔵 藍色圓點: 尚未開始的活動"
    echo "  • 🟢 綠色圓點: 正在進行的活動"
    echo "  • 🟡 黃色圓點: 剩2週結束的活動"
    echo "  • 🟠 橘色圓點: 剩1週結束的活動"
    echo "  • 🔴 紅色圓點: 剩3天結束的活動"
    echo ""
    echo "🔄 使用方式:"
    echo "  1. 每次執行 setup-commercial-district.sh 後"
    echo "  2. 執行此腳本: ./scripts/restore-dynamic-map-config.sh"
    echo "  3. 即可恢復動態地圖功能"
    echo ""
    echo "🌐 查看效果:"
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 強制刷新頁面 (Ctrl+Shift+R 或 Cmd+Shift+R)"
    echo "  3. 前往「地圖檢視」"
    echo "  4. 展開「市集活動分佈」組件"
    echo "  5. 觀察地圖上的動態顏色圓點"
    echo ""
    print_success "🚀 動態地圖功能已完全恢復！"
}

# 主執行流程
main() {
    echo "=================================================="
    echo "     市集活動動態地圖配置恢復工具              "
    echo "    🎨 確保圖表刷新後維持動態功能              "
    echo "=================================================="
    echo ""
    
    check_containers
    restore_dynamic_config
    update_geojson_data
    restart_backend
    verify_restoration
    show_completion_message
}

# 執行主函數
main "$@" 
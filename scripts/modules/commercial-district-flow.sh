#!/bin/bash

# 商圈人流分析組件部署腳本
# 包含假資料創建和組件配置

# 載入模組化框架
source "$(dirname "$0")/create-component.sh"

# 商圈人流分析配置
COMPONENT_INDEX="commercial_district_flow"
COMPONENT_NAME="商圈人流分析"
COMPONENT_COLORS="{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}"
COMPONENT_TYPES="{ColumnChart,LineChart,HeatmapChart}"
COMPONENT_UNIT="人"
QUERY_TYPE="three_d"
SHORT_DESC="顯示商圈即時人流分析"
LONG_DESC="此圖表呈現各大商圈的即時人流分析，包括時段分布、熱點區域、人流趨勢等關鍵指標。透過即時數據監控，協助商家了解客流變化，政府優化交通規劃，投資者評估商圈潛力。"
USE_CASE="適用於商圈經營分析、時段規劃、活動策劃與投資評估。商家可據此調整營業時間與促銷策略；政府可優化公共設施配置與交通管制；投資者可評估不同商圈的發展潛力與商業價值。"

# 創建假資料表的 SQL
TABLE_SCHEMA="
CREATE TABLE commercial_district_flow_data (
    id SERIAL PRIMARY KEY,
    district_name VARCHAR(50) NOT NULL,
    time_period VARCHAR(20) NOT NULL,
    flow_count INTEGER NOT NULL,
    flow_type VARCHAR(20) NOT NULL,
    date_recorded DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_commercial_flow_district ON commercial_district_flow_data(district_name);
CREATE INDEX idx_commercial_flow_time ON commercial_district_flow_data(time_period);
CREATE INDEX idx_commercial_flow_date ON commercial_district_flow_data(date_recorded);
"

# 生成假資料的函數
generate_mock_data() {
    echo "📊 生成商圈人流假資料..."
    
    # 商圈列表
    local districts=("西門町" "信義區" "東區" "士林夜市" "饒河夜市" "永康街" "師大夜市" "公館商圈")
    
    # 時段列表
    local time_periods=("08:00-10:00" "10:00-12:00" "12:00-14:00" "14:00-16:00" "16:00-18:00" "18:00-20:00" "20:00-22:00" "22:00-24:00")
    
    # 人流類型
    local flow_types=("進入" "離開" "停留")
    
    local insert_sql="INSERT INTO commercial_district_flow_data (district_name, time_period, flow_count, flow_type, date_recorded) VALUES "
    local values=()
    
    # 生成最近7天的數據 (修復 macOS date 兼容性)
    for day in {0..6}; do
        # macOS 與 Linux 的 date 命令語法不同
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS 使用 -v 參數
            local date_offset=$(date -v-${day}d +%Y-%m-%d)
        else
            # Linux 使用 -d 參數
            local date_offset=$(date -d "$day days ago" +%Y-%m-%d)
        fi
        
        for district in "${districts[@]}"; do
            for time_period in "${time_periods[@]}"; do
                for flow_type in "${flow_types[@]}"; do
                    # 根據時段和商圈生成不同範圍的人流數據
                    local base_flow=500
                    case "$time_period" in
                        "12:00-14:00"|"18:00-20:00"|"20:00-22:00") base_flow=1200 ;;
                        "10:00-12:00"|"14:00-16:00"|"16:00-18:00") base_flow=800 ;;
                        "08:00-10:00"|"22:00-24:00") base_flow=300 ;;
                    esac
                    
                    # 商圈熱度調整
                    case "$district" in
                        "西門町"|"信義區"|"東區") base_flow=$((base_flow * 150 / 100)) ;;
                        "士林夜市"|"饒河夜市") base_flow=$((base_flow * 120 / 100)) ;;
                    esac
                    
                    # 添加隨機變化 (±30%)
                    local random_factor=$(( (RANDOM % 60) - 30 ))
                    local flow_count=$((base_flow + (base_flow * random_factor / 100)))
                    
                    # 確保最小值
                    [ $flow_count -lt 50 ] && flow_count=50
                    
                    values+=("('$district', '$time_period', $flow_count, '$flow_type', '$date_offset')")
                done
            done
        done
    done
    
    # 組合完整的 INSERT 語句
    local full_insert_sql="$insert_sql $(IFS=','; echo "${values[*]}");"
    
    insert_mock_data "commercial_district_flow_data" "$full_insert_sql"
}

# 查詢 SQL
QUERY_SQL="
SELECT 
    district_name as x_axis,
    time_period as y_axis,
    AVG(flow_count)::INTEGER as data
FROM commercial_district_flow_data 
WHERE date_recorded >= CURRENT_DATE - INTERVAL '7 days'
    AND flow_type = '進入'
GROUP BY district_name, time_period
ORDER BY 
    CASE time_period
        WHEN '08:00-10:00' THEN 1
        WHEN '10:00-12:00' THEN 2
        WHEN '12:00-14:00' THEN 3
        WHEN '14:00-16:00' THEN 4
        WHEN '16:00-18:00' THEN 5
        WHEN '18:00-20:00' THEN 6
        WHEN '20:00-22:00' THEN 7
        WHEN '22:00-24:00' THEN 8
    END,
    district_name
"

# 主執行函數
deploy_commercial_flow_component() {
    echo "🏪 開始部署商圈人流分析組件..."
    echo "======================================="
    
    # 1. 創建假資料表
    echo "📊 步驟 1: 創建資料表"
    create_mock_data_table "commercial_district_flow_data" "$TABLE_SCHEMA"
    
    # 2. 生成假資料
    echo ""
    echo "📈 步驟 2: 生成假資料"
    generate_mock_data
    
    # 3. 創建組件
    echo ""
    echo "🔧 步驟 3: 創建組件"
    create_component \
        "$COMPONENT_INDEX" \
        "$COMPONENT_NAME" \
        "$COMPONENT_COLORS" \
        "$COMPONENT_TYPES" \
        "$COMPONENT_UNIT" \
        "$QUERY_SQL" \
        "$QUERY_TYPE" \
        "$SHORT_DESC" \
        "$LONG_DESC" \
        "$USE_CASE" \
        "taipei"
    
    # 4. 添加到儀表板
    echo ""
    echo "🔗 步驟 4: 添加到商圈活化儀表板"
    add_component_to_dashboard "commercial_district" "$COMPONENT_INDEX"
    
    echo ""
    echo "🎉 商圈人流分析組件部署完成！"
    echo "======================================="
    echo "📋 組件資訊:"
    echo "  • 組件名稱: $COMPONENT_NAME"
    echo "  • 資料表: commercial_district_flow_data" 
    echo "  • 資料筆數: $(docker exec postgres-data psql -U postgres -d dashboard -t -c "SELECT COUNT(*) FROM commercial_district_flow_data;" | tr -d ' ')"
    echo "  • 圖表類型: 柱狀圖、線圖、熱力圖"
    echo "  • 更新頻率: 10分鐘"
    echo ""
}

# 如果直接執行此腳本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deploy_commercial_flow_component
fi 
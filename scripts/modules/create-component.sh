#!/bin/bash

# 模組化組件創建腳本框架
# 用途：統一創建儀表板組件的流程

# 函數：創建單一組件
create_component() {
    local COMPONENT_INDEX="$1"
    local COMPONENT_NAME="$2"
    local COMPONENT_COLORS="$3"
    local COMPONENT_TYPES="$4"
    local COMPONENT_UNIT="$5"
    local QUERY_SQL="$6"
    local QUERY_TYPE="$7"
    local SHORT_DESC="$8"
    local LONG_DESC="$9"
    local USE_CASE="${10}"
    local CITY="${11:-taipei}"
    
    echo "🔧 創建組件: $COMPONENT_NAME"
    
    # 創建臨時 SQL 文件
    local TEMP_SQL="/tmp/${COMPONENT_INDEX}_init.sql"
    
    cat > "$TEMP_SQL" << EOF
-- 組件創建: $COMPONENT_NAME
-- 自動生成時間: $(date)

-- 1. 新增圖表配置
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    '$COMPONENT_INDEX',
    '$COMPONENT_COLORS',
    '$COMPONENT_TYPES',
    '$COMPONENT_UNIT'
) ON CONFLICT (index) DO UPDATE SET
    color = EXCLUDED.color,
    types = EXCLUDED.types,
    unit = EXCLUDED.unit;

-- 2. 新增組件
INSERT INTO public.components (id, index, name)
VALUES (
    (SELECT COALESCE(MAX(id), 0) + 1 FROM public.components),
    '$COMPONENT_INDEX',
    '$COMPONENT_NAME'
) ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name;

-- 3. 新增查詢配置
INSERT INTO public.query_charts (
    index,
    history_config,
    map_config_ids,
    map_filter,
    time_from,
    time_to,
    update_freq,
    update_freq_unit,
    source,
    short_desc,
    long_desc,
    use_case,
    links,
    contributors,
    created_at,
    updated_at,
    query_type,
    query_chart,
    query_history,
    city
)
VALUES (
    '$COMPONENT_INDEX',
    NULL,
    '{}',
    '{}',
    'current',
    NULL,
    10,
    'minute',
    '商業處',
    '$SHORT_DESC',
    '$LONG_DESC',
    '$USE_CASE',
    '{}',
    '{doit}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '$QUERY_TYPE',
    '$QUERY_SQL',
    NULL,
    '$CITY'
) ON CONFLICT (index, city) DO UPDATE SET
    short_desc = EXCLUDED.short_desc,
    long_desc = EXCLUDED.long_desc,
    use_case = EXCLUDED.use_case,
    query_chart = EXCLUDED.query_chart,
    updated_at = CURRENT_TIMESTAMP;

-- 完成訊息
DO \$\$
BEGIN
    RAISE NOTICE '✅ 組件創建完成: $COMPONENT_NAME';
END \$\$;
EOF

    # 執行 SQL
    docker exec postgres-manager psql -U postgres -d dashboardmanager -f "$TEMP_SQL"
    
    if [ $? -eq 0 ]; then
        echo "✅ 組件 '$COMPONENT_NAME' 創建成功"
        rm "$TEMP_SQL"
        return 0
    else
        echo "❌ 組件 '$COMPONENT_NAME' 創建失敗"
        return 1
    fi
}

# 函數：將組件添加到儀表板
add_component_to_dashboard() {
    local DASHBOARD_INDEX="$1"
    local COMPONENT_INDEX="$2"
    
    echo "🔗 將組件添加到儀表板: $DASHBOARD_INDEX"
    
    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
        UPDATE public.dashboards 
        SET components = components || (SELECT ARRAY[id::integer] FROM public.components WHERE index = '$COMPONENT_INDEX')
        WHERE index = '$DASHBOARD_INDEX' 
        AND NOT (components @> (SELECT ARRAY[id::integer] FROM public.components WHERE index = '$COMPONENT_INDEX'));
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ 組件已添加到儀表板"
        return 0
    else
        echo "❌ 組件添加失敗"
        return 1
    fi
}

# 函數：創建假資料表
create_mock_data_table() {
    local TABLE_NAME="$1"
    local TABLE_SCHEMA="$2"
    
    echo "📊 創建假資料表: $TABLE_NAME"
    
    docker exec postgres-data psql -U postgres -d dashboard -c "
        DROP TABLE IF EXISTS $TABLE_NAME CASCADE;
        $TABLE_SCHEMA
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ 資料表 '$TABLE_NAME' 創建成功"
        return 0
    else
        echo "❌ 資料表 '$TABLE_NAME' 創建失敗"
        return 1
    fi
}

# 函數：插入假資料
insert_mock_data() {
    local TABLE_NAME="$1"
    local INSERT_SQL="$2"
    
    echo "📈 插入假資料到: $TABLE_NAME"
    
    docker exec postgres-data psql -U postgres -d dashboard -c "$INSERT_SQL"
    
    if [ $? -eq 0 ]; then
        echo "✅ 假資料插入成功"
        return 0
    else
        echo "❌ 假資料插入失敗"
        return 1
    fi
} 
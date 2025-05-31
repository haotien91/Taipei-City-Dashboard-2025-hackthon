-- 商圈活化儀表板初始化配置
-- 創建時間：2024-03-21
-- 目的：為台北城市儀表板添加"商圈活化"功能模組

-- 1. 新增儀表板配置
INSERT INTO public.dashboards (index, name, components, icon, updated_at, created_at)
VALUES (
    'commercial_district',
    '商圈活化',
    '{}',
    'store',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- 2. 新增儀表板與群組關聯（分配給台北市群組）
INSERT INTO public.dashboard_groups (dashboard_id, group_id)
VALUES (
    (SELECT id FROM public.dashboards WHERE index = 'commercial_district'),
    (SELECT id FROM public.groups WHERE name = 'taipei')
);

-- 3. 新增圖表配置
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'commercial_district_flow',
    '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}',
    '{ColumnChart,LineChart,HeatmapChart}',
    '人'
);

-- 4. 新增組件
INSERT INTO public.components (id, index, name)
VALUES (
    (SELECT COALESCE(MAX(id), 0) + 1 FROM public.components),
    'commercial_district_flow',
    '商圈人流分析'
);

-- 5. 新增查詢配置
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
    'commercial_district_flow',
    NULL,
    '{}',
    '{}',
    'current',
    NULL,
    10,
    'minute',
    '商業處',
    '顯示商圈人流分析',
    '此圖表呈現商圈人流分析，包括各時段人流變化、熱門時段分析等資訊。透過即時數據監控，協助商家了解客流趨勢，優化營運策略。',
    '可用於商圈經營分析、活動規劃與商業決策參考。適合店家評估最佳營業時段、政府規劃商圈活動時機，以及投資者評估商圈發展潛力。',
    '{}',
    '{doit}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT ''商圈'' as x_axis, ''人流量'' as y_axis, 1000 as data UNION ALL SELECT ''商圈'' as x_axis, ''店家數'' as y_axis, 50 as data',
    NULL,
    'taipei'
);

-- 6. 自動更新儀表板的 components 欄位
-- 此步驟將新創建的組件 ID 加入到儀表板配置中
UPDATE public.dashboards 
SET components = ARRAY[(SELECT id FROM public.components WHERE index = 'commercial_district_flow')]
WHERE index = 'commercial_district';

-- 完成訊息
DO $$
BEGIN
    RAISE NOTICE '=== 商圈活化儀表板初始化完成 ===';
    RAISE NOTICE '儀表板名稱: 商圈活化';
    RAISE NOTICE '組件數量: 1 (商圈人流分析)';
    RAISE NOTICE '群組權限: taipei';
    RAISE NOTICE '請重啟後端服務以載入新配置';
END $$; 
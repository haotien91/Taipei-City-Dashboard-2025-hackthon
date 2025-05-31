-- 商圈活化儀表板初始化配置
-- 創建時間：2024-03-21
-- 目的：為台北城市儀表板添加"商圈活化"功能模組
-- 更新模式：支援刷新更新，避免重複新增

-- 1. 新增/更新儀表板配置
INSERT INTO public.dashboards (index, name, components, icon, updated_at, created_at)
VALUES (
    'commercial_district',
    '商圈活化',
    '{}',
    'store',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name,
    icon = EXCLUDED.icon,
    updated_at = CURRENT_TIMESTAMP;

-- 2. 新增/更新儀表板與群組關聯（分配給台北市群組）
INSERT INTO public.dashboard_groups (dashboard_id, group_id)
VALUES (
    (SELECT id FROM public.dashboards WHERE index = 'commercial_district'),
    (SELECT id FROM public.groups WHERE name = 'taipei')
)
ON CONFLICT (dashboard_id, group_id) DO NOTHING;

-- 3. 新增/更新圖表配置
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'commercial_district_flow',
    '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}',
    '{ColumnChart,LineChart,HeatmapChart}',
    '人'
)
ON CONFLICT (index) DO UPDATE SET
    color = EXCLUDED.color,
    types = EXCLUDED.types,
    unit = EXCLUDED.unit;

-- 4. 新增/更新商圈密度行政區圖表配置
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'commercial_district_density',
    '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}',
    '{DistrictChart}',
    '個'
)
ON CONFLICT (index) DO UPDATE SET
    color = EXCLUDED.color,
    types = EXCLUDED.types,
    unit = EXCLUDED.unit;

-- 5. 新增/更新組件
INSERT INTO public.components (index, name)
VALUES (
    'commercial_district_flow',
    '商圈人流分析'
)
ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name;

-- 6. 新增/更新商圈密度組件
INSERT INTO public.components (index, name)
VALUES (
    'commercial_district_density',
    '商圈密度分布'
)
ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name;

-- 7. 刪除現有查詢配置，避免重複
DELETE FROM public.query_charts WHERE index = 'commercial_district_flow';
DELETE FROM public.query_charts WHERE index = 'commercial_district_density';

-- 8. 新增查詢配置
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

-- 9. 新增商圈密度行政區查詢配置
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
    'commercial_district_density',
    NULL,
    '{}',
    '{}',
    'static',
    NULL,
    NULL,
    NULL,
    '商業處',
    '顯示各行政區商圈密度分布',
    '此圖表呈現台北市各行政區的商圈密度分布，包括商店數量、商圈規模等指標。透過行政區視覺化，協助了解各區商業發展狀況，為商圈活化政策提供數據支撐。',
    '可用於商圈政策制定、投資評估與區域發展規劃。適合政府部門評估商圈發展潛力、投資者選址參考，以及商業顧問進行市場分析。',
    '{}',
    '{doit}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT x_axis, y_axis, data FROM (VALUES 
        (''北投區'', ''商店數量'', 120),
        (''士林區'', ''商店數量'', 280),
        (''內湖區'', ''商店數量'', 220),
        (''南港區'', ''商店數量'', 150),
        (''松山區'', ''商店數量'', 320),
        (''信義區'', ''商店數量'', 380),
        (''中山區'', ''商店數量'', 450),
        (''大同區'', ''商店數量'', 180),
        (''中正區'', ''商店數量'', 290),
        (''萬華區'', ''商店數量'', 200),
        (''大安區'', ''商店數量'', 420),
        (''文山區'', ''商店數量'', 160),
        (''北投區'', ''平均營業額'', 85),
        (''士林區'', ''平均營業額'', 95),
        (''內湖區'', ''平均營業額'', 110),
        (''南港區'', ''平均營業額'', 88),
        (''松山區'', ''平均營業額'', 125),
        (''信義區'', ''平均營業額'', 150),
        (''中山區'', ''平均營業額'', 135),
        (''大同區'', ''平均營業額'', 75),
        (''中正區'', ''平均營業額'', 105),
        (''萬華區'', ''平均營業額'', 80),
        (''大安區'', ''平均營業額'', 140),
        (''文山區'', ''平均營業額'', 70)
    ) AS t(x_axis, y_axis, data)',
    NULL,
    'taipei'
);

-- 10. 自動更新儀表板的 components 欄位
-- 此步驟將新創建的組件 ID 加入到儀表板配置中
UPDATE public.dashboards 
SET components = ARRAY[
    (SELECT id FROM public.components WHERE index = 'commercial_district_flow'),
    (SELECT id FROM public.components WHERE index = 'commercial_district_density')
]
WHERE index = 'commercial_district';

-- 完成訊息
DO $$
BEGIN
    RAISE NOTICE '=== 商圈活化儀表板初始化完成 ===';
    RAISE NOTICE '儀表板名稱: 商圈活化';
    RAISE NOTICE '組件數量: 2 (商圈人流分析 + 商圈密度分布)';
    RAISE NOTICE '群組權限: taipei';
    RAISE NOTICE '新增功能: 行政區圖 (商圈密度分布)';
    RAISE NOTICE '🔄 更新模式: 支援刷新更新，避免重複新增';
    RAISE NOTICE '請重啟後端服務以載入新配置';
END $$; 
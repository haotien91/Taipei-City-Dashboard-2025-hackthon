-- 雙北商圈活化儀表板初始化配置
-- 創建時間：2024-03-21
-- 目的：為雙北儀表板示範添加"商圈活化"功能模組
-- 適用範圍：台北市 + 新北市
-- 更新模式：支援刷新更新，避免重複新增

-- 1. 新增/更新儀表板配置 (雙北版本)
INSERT INTO public.dashboards (index, name, components, icon, updated_at, created_at)
VALUES (
    'commercial_district_metrotaipei',
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

-- 2. 新增/更新儀表板與群組關聯（分配給雙北群組）
INSERT INTO public.dashboard_groups (dashboard_id, group_id)
VALUES (
    (SELECT id FROM public.dashboards WHERE index = 'commercial_district_metrotaipei'),
    (SELECT id FROM public.groups WHERE name = 'metrotaipei')
)
ON CONFLICT (dashboard_id, group_id) DO NOTHING;

-- 3. 新增/更新圖表配置 - 人流分析
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'commercial_district_flow_metrotaipei',
    '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}',
    '{ColumnChart,LineChart,HeatmapChart}',
    '人'
)
ON CONFLICT (index) DO UPDATE SET
    color = EXCLUDED.color,
    types = EXCLUDED.types,
    unit = EXCLUDED.unit;

-- 4. 新增/更新商圈密度行政區圖表配置 (雙北版本)
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'commercial_district_density_metrotaipei',
    '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}',
    '{DistrictChart}',
    '個'
)
ON CONFLICT (index) DO UPDATE SET
    color = EXCLUDED.color,
    types = EXCLUDED.types,
    unit = EXCLUDED.unit;

-- 5. 新增/更新組件 - 人流分析
INSERT INTO public.components (index, name)
VALUES (
    'commercial_district_flow_metrotaipei',
    '雙北商圈人流分析'
)
ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name;

-- 6. 新增/更新組件 - 商圈密度
INSERT INTO public.components (index, name)
VALUES (
    'commercial_district_density_metrotaipei',
    '雙北商圈密度分布'
)
ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name;

-- 7. 新增/更新圖表配置 - 商圈排行榜
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'commercial_district_ranking_metrotaipei',
    '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}',
    '{CommercialDistrictRanking}',
    '個'
)
ON CONFLICT (index) DO UPDATE SET
    color = EXCLUDED.color,
    types = EXCLUDED.types,
    unit = EXCLUDED.unit;

-- 8. 新增/更新組件 - 商圈排行榜
INSERT INTO public.components (index, name)
VALUES (
    'commercial_district_ranking_metrotaipei',
    '雙北商圈排行榜'
)
ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name;

-- 9. 刪除現有查詢配置，避免重複
DELETE FROM public.query_charts WHERE index = 'commercial_district_flow_metrotaipei';
DELETE FROM public.query_charts WHERE index = 'commercial_district_density_metrotaipei';
DELETE FROM public.query_charts WHERE index = 'commercial_district_ranking_metrotaipei';

-- 10. 新增查詢配置 - 人流分析 (雙北版本)
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
    'commercial_district_flow_metrotaipei',
    NULL,
    '{}',
    '{}',
    'current',
    NULL,
    10,
    'minute',
    '商業處',
    '顯示雙北商圈人流分析',
    '此圖表呈現雙北地區商圈人流分析，包括台北市與新北市各商圈的人流變化、熱門時段分析等資訊。透過跨市即時數據監控，協助商家了解區域客流趨勢，優化營運策略，促進雙北商圈整體發展。',
    '可用於雙北商圈經營分析、跨市活動規劃與商業決策參考。適合連鎖店家評估雙北展店策略、政府規劃跨市商圈活動，以及投資者評估雙北商圈發展潛力與區域差異。',
    '{}',
    '{doit,ntpc}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT x_axis, y_axis, data FROM (VALUES 
        (''台北商圈'', ''人流量'', 1200),
        (''新北商圈'', ''人流量'', 800),
        (''台北商圈'', ''店家數'', 60),
        (''新北商圈'', ''店家數'', 45),
        (''台北商圈'', ''營業額'', 150),
        (''新北商圈'', ''營業額'', 120)
    ) AS t(x_axis, y_axis, data)',
    NULL,
    'metrotaipei'
);

-- 11. 新增查詢配置 - 人流分析 (台北市版本)
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
    'commercial_district_flow_metrotaipei',
    NULL,
    '{}',
    '{}',
    'current',
    NULL,
    10,
    'minute',
    '商業處',
    '顯示台北市商圈人流分析',
    '此圖表呈現台北市商圈人流分析，包括各商圈的人流變化、熱門時段分析等資訊。透過即時數據監控，協助商家了解客流趨勢，優化營運策略，促進台北市商圈發展。',
    '可用於台北市商圈經營分析、活動規劃與商業決策參考。適合店家評估最佳營業時段、政府規劃商圈活動時機，以及投資者評估商圈發展潛力。',
    '{}',
    '{doit}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT x_axis, y_axis, data FROM (VALUES 
        (''西門町'', ''人流量'', 800),
        (''信義區'', ''人流量'', 1200),
        (''東區'', ''人流量'', 900),
        (''士林夜市'', ''人流量'', 600),
        (''西門町'', ''店家數'', 35),
        (''信義區'', ''店家數'', 60),
        (''東區'', ''店家數'', 45),
        (''士林夜市'', ''店家數'', 25),
        (''西門町'', ''營業額'', 120),
        (''信義區'', ''營業額'', 180),
        (''東區'', ''營業額'', 150),
        (''士林夜市'', ''營業額'', 90)
    ) AS t(x_axis, y_axis, data)',
    NULL,
    'taipei'
);

-- 12. 新增商圈密度行政區查詢配置 (雙北版本)
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
    'commercial_district_density_metrotaipei',
    NULL,
    '{}',
    '{}',
    'static',
    NULL,
    NULL,
    NULL,
    '商業處',
    '顯示雙北各行政區市集活動分佈',
    '此圖表呈現台北市與新北市各行政區的市集活動分佈，包括市集數量、展覽活動等指標。透過雙北行政區視覺化比較，協助了解兩市市集活動差異，為跨市商圈活化政策提供數據支撐。',
    '可用於雙北市集活動政策制定、跨市投資評估與區域發展規劃。適合政府部門評估雙北市集發展潛力差異、投資者進行跨市選址比較，以及商業顧問進行雙北市場分析。',
    '{}',
    '{doit,ntpc}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT x_axis, y_axis, data FROM (VALUES 
        -- 台北市各區
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
        -- 新北市主要區域
        (''板橋區'', ''商店數量'', 350),
        (''新莊區'', ''商店數量'', 280),
        (''中和區'', ''商店數量'', 250),
        (''永和區'', ''商店數量'', 200),
        (''土城區'', ''商店數量'', 180),
        (''樹林區'', ''商店數量'', 150),
        (''三重區'', ''商店數量'', 220),
        (''蘆洲區'', ''商店數量'', 160),
        (''五股區'', ''商店數量'', 120),
        (''泰山區'', ''商店數量'', 90),
        (''林口區'', ''商店數量'', 140),
        (''淡水區'', ''商店數量'', 180)
    ) AS t(x_axis, y_axis, data)',
    NULL,
    'metrotaipei'
);

-- 13. 新增商圈密度行政區查詢配置 (台北市版本)
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
    'commercial_district_density_metrotaipei',
    NULL,
    '{}',
    '{}',
    'static',
    NULL,
    NULL,
    NULL,
    '商業處',
    '顯示台北市各行政區市集活動分佈',
    '此圖表呈現台北市各行政區的市集活動分佈，包括市集數量、展覽活動等指標。透過行政區視覺化，協助了解各區市集活動狀況，為商圈活化政策提供數據支撐。',
    '可用於台北市市集活動政策制定、投資評估與區域發展規劃。適合政府部門評估市集發展潛力、投資者選址參考，以及商業顧問進行市場分析。',
    '{}',
    '{doit}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT x_axis, y_axis, data FROM (VALUES 
        -- 台北市各區 (僅台北市資料)
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
        -- 台北市平均營業額指標
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

-- 14. 新增查詢配置 - 商圈排行榜 (雙北版本)
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
    'commercial_district_ranking_metrotaipei',
    NULL,
    '{}',
    '{}',
    'current',
    NULL,
    0.2,
    'minute',
    '商業處',
    '顯示雙北商圈綜合排行榜',
    '此組件展示雙北地區商圈的綜合排名，包含人流量、商店數量、平均營業額等多維度指標。透過即時數據更新，提供動態的商圈表現評估，協助商家和政策制定者掌握商圈發展趨勢。',
    '適用於商圈競爭力分析、投資決策參考、及商業地產評估。可幫助連鎖企業選址、政府制定商圈振興政策，以及消費者了解熱門商圈動態。',
    '{}',
    '{doit,ntpc}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'three_d',
    'SELECT x_axis, y_axis, data FROM (VALUES 
        (''信義商圈'', ''人流量'', 15000),
        (''西門町商圈'', ''人流量'', 12000),
        (''板橋商圈'', ''人流量'', 10000),
        (''東區商圈'', ''人流量'', 9500),
        (''中和環球商圈'', ''人流量'', 8800),
        (''天母商圈'', ''人流量'', 8500),
        (''三重商圈'', ''人流量'', 8200),
        (''士林夜市商圈'', ''人流量'', 8000),
        
        (''信義商圈'', ''商店數'', 450),
        (''西門町商圈'', ''商店數'', 380),
        (''板橋商圈'', ''商店數'', 320),
        (''東區商圈'', ''商店數'', 300),
        (''中和環球商圈'', ''商店數'', 280),
        (''天母商圈'', ''商店數'', 260),
        (''三重商圈'', ''商店數'', 240),
        (''士林夜市商圈'', ''商店數'', 220),
        
        (''信義商圈'', ''營業額'', 180),
        (''西門町商圈'', ''營業額'', 150),
        (''板橋商圈'', ''營業額'', 130),
        (''東區商圈'', ''營業額'', 145),
        (''中和環球商圈'', ''營業額'', 125),
        (''天母商圈'', ''營業額'', 135),
        (''三重商圈'', ''營業額'', 120),
        (''士林夜市商圈'', ''營業額'', 110)
    ) AS t(x_axis, y_axis, data)',
    NULL,
    'metrotaipei'
);

-- 15. 自動更新儀表板的 components 欄位
-- 此步驟將新創建的組件 ID 加入到儀表板配置中
UPDATE public.dashboards 
SET components = ARRAY[
    (SELECT id FROM public.components WHERE index = 'commercial_district_flow_metrotaipei'),
    (SELECT id FROM public.components WHERE index = 'commercial_district_density_metrotaipei'),
    (SELECT id FROM public.components WHERE index = 'commercial_district_ranking_metrotaipei')
]
WHERE index = 'commercial_district_metrotaipei';

-- 完成訊息
DO $$
BEGIN
    RAISE NOTICE '=== 雙北商圈活化儀表板初始化完成 ===';
    RAISE NOTICE '儀表板名稱: 商圈活化 (雙北版本)';
    RAISE NOTICE '組件數量: 3 (雙北商圈人流分析 + 雙北市集活動分佈 + 雙北商圈排行榜)';
    RAISE NOTICE '群組權限: metrotaipei';
    RAISE NOTICE '涵蓋範圍: 台北市12區 + 新北市12主要區域';
    RAISE NOTICE '新增功能: 跨市行政區圖 (雙北市集活動分佈)';
    RAISE NOTICE '✨ 支援城市切換: 雙北 ↔ 台北市';
    RAISE NOTICE '🔄 更新模式: 支援刷新更新，避免重複新增';
    RAISE NOTICE '請重啟後端服務以載入新配置';
END $$; 
-- 心理測驗組件初始化配置
-- 創建時間：2024-12-19
-- 目的：為台北城市儀表板添加心理測驗功能組件

-- 先清理可能存在的舊數據，確保乾淨安裝
DELETE FROM public.query_charts WHERE index = 'quiz_component';
DELETE FROM public.component_charts WHERE index = 'quiz_component';
DELETE FROM public.components WHERE index = 'quiz_component';

-- 1. 新增圖表配置
INSERT INTO public.component_charts (index, color, types, unit)
VALUES (
    'quiz_component',
    '{#667eea,#764ba2,#9c88ff,#a29bfe,#6c5ce7,#74b9ff}',
    '{QuizChart}',
    '推薦'
);

-- 2. 新增組件
INSERT INTO public.components (id, index, name)
VALUES (
    (SELECT COALESCE(MAX(id), 0) + 1 FROM public.components),
    'quiz_component',
    '台北商圈心理測驗'
);

-- 3. 新增查詢配置 - 台北市
INSERT INTO public.query_charts (
    index, source, short_desc, long_desc, query_type, query_chart, time_from, city, created_at, updated_at,
    history_config, map_config_ids, map_filter, time_to, update_freq, update_freq_unit, 
    use_case, links, contributors
) VALUES (
    'quiz_component', 
    '台北市政府 x 心理學研究', 
    '透過心理測驗，找到最適合你的台北商圈！',
    '這是一個互動式的心理測驗，通過分析你的消費習慣、喜好風格、活動偏好等因素，為你推薦最適合的台北商圈。測驗包含4個問題，根據你的答案會推薦1-3個符合你性格的商圈，並提供詳細的商圈資訊、交通指南、預算參考等實用資訊。',
    'three_d', 
    'SELECT 
        unnest(ARRAY[''個性化推薦'', ''測驗統計'', ''使用情況'']) AS x_axis,
        unnest(ARRAY[''心理測驗'', ''數據分析'', ''用戶體驗'']) AS y_axis,
        unnest(ARRAY[1, 1, 1]) AS data,
        ''psychology'' AS icon', 
    'static', 
    'taipei', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP,
    NULL,
    '{}',
    '{}',
    NULL,
    NULL,
    NULL,
    '適用於遊客規劃行程、在地人探索新商圈、商家了解目標客群。透過性格分析推薦機制，提升商圈媒合效率，增加使用者滿意度，促進商圈經濟活動。',
    '{"https://github.com/tpe-doit/Taipei-City-Dashboard-FE"}',
    '{doit}'
);

-- 4. 新增查詢配置 - 雙北地區
INSERT INTO public.query_charts (
    index, source, short_desc, long_desc, query_type, query_chart, time_from, city, created_at, updated_at,
    history_config, map_config_ids, map_filter, time_to, update_freq, update_freq_unit,
    use_case, links, contributors
) VALUES (
    'quiz_component', 
    '台北市政府 x 心理學研究', 
    '透過心理測驗，找到最適合你的台北商圈！',
    '這是一個互動式的心理測驗，通過分析你的消費習慣、喜好風格、活動偏好等因素，為你推薦最適合的台北商圈。測驗包含4個問題，根據你的答案會推薦1-3個符合你性格的商圈，並提供詳細的商圈資訊、交通指南、預算參考等實用資訊。',
    'three_d', 
    'SELECT 
        unnest(ARRAY[''個性化推薦'', ''測驗統計'', ''使用情況'']) AS x_axis,
        unnest(ARRAY[''心理測驗'', ''數據分析'', ''用戶體驗'']) AS y_axis,
        unnest(ARRAY[1, 1, 1]) AS data,
        ''psychology'' AS icon', 
    'static', 
    'metrotaipei', 
    CURRENT_TIMESTAMP, 
    CURRENT_TIMESTAMP,
    NULL,
    '{}',
    '{}',
    NULL,
    NULL,
    NULL,
    '適用於遊客規劃行程、在地人探索新商圈、商家了解目標客群。透過性格分析推薦機制，提升商圈媒合效率，增加使用者滿意度，促進商圈經濟活動。',
    '{"https://github.com/tpe-doit/Taipei-City-Dashboard-FE"}',
    '{doit}'
);

-- 5. 創建心理測驗專用儀表板
INSERT INTO public.dashboards (index, name, components, icon, updated_at, created_at)
VALUES (
    'quiz_dashboard',
    '商圈探索測驗',
    ARRAY[(SELECT id FROM public.components WHERE index = 'quiz_component')],
    'psychology',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT (index) DO UPDATE SET
    name = EXCLUDED.name,
    components = EXCLUDED.components,
    updated_at = CURRENT_TIMESTAMP;

-- 6. 將心理測驗組件加入現有的商圈活化儀表板
UPDATE public.dashboards 
SET components = components || (SELECT ARRAY[id::integer] FROM public.components WHERE index = 'quiz_component')
WHERE index = 'commercial_district' 
AND NOT (components @> (SELECT ARRAY[id::integer] FROM public.components WHERE index = 'quiz_component'));

-- 7. 如果沒有商圈活化儀表板，則創建一個
INSERT INTO public.dashboards (index, name, components, icon, updated_at, created_at)
VALUES (
    'commercial_district',
    '商圈活化',
    ARRAY[(SELECT id FROM public.components WHERE index = 'quiz_component')],
    'store',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT (index) DO NOTHING;

-- 完成訊息與驗證
DO $$
DECLARE
    component_count INTEGER;
    chart_count INTEGER;
    query_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO component_count FROM public.components WHERE index = 'quiz_component';
    SELECT COUNT(*) INTO chart_count FROM public.component_charts WHERE index = 'quiz_component';
    SELECT COUNT(*) INTO query_count FROM public.query_charts WHERE index = 'quiz_component';
    
    RAISE NOTICE '=== 心理測驗組件初始化完成 ===';
    RAISE NOTICE '組件名稱: 台北商圈心理測驗';
    RAISE NOTICE '組件索引: quiz_component';
    RAISE NOTICE '圖表類型: QuizChart';
    RAISE NOTICE '註冊結果: Components(%), Charts(%), Queries(%)', component_count, chart_count, query_count;
    RAISE NOTICE '支援城市: taipei, metrotaipei';
    RAISE NOTICE '儀表板: 商圈探索測驗, 商圈活化';
    RAISE NOTICE '請重啟 Docker 容器以載入新配置';
    
    IF component_count = 0 OR chart_count = 0 OR query_count = 0 THEN
        RAISE EXCEPTION '組件註冊失敗，請檢查資料庫狀態';
    END IF;
END $$; 
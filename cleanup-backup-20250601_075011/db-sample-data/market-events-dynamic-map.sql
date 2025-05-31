-- 動態顏色市集活動地圖配置
-- 根據活動狀態顯示不同顏色的圓點
-- 創建時間：2025-06-01T02:54:19.620139

-- 新增動態顏色地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_dynamic',
    '市集活動分佈 - 動態狀態',
    'circle',
    'geojson',
    'big',
    NULL,
    '{"circle-color": ["match", ["get", "event_status"], "not_started", "#2196F3", "active", "#4CAF50", "ending_2weeks", "#FFEB3B", "ending_1week", "#FF9800", "ending_3days", "#F44336", "#666666"], "circle-radius": ["interpolate", ["linear"], ["zoom"], 11.99, 4, 12, 5, 13.5, 6, 15, 8, 22, 12], "circle-stroke-width": 2, "circle-stroke-color": "#FFFFFF", "circle-opacity": 0.85}',
    '[{"key": "name", "name": "市集名稱"}, {"key": "type", "name": "活動類型"}, {"key": "district", "name": "行政區"}, {"key": "start_date", "name": "開始日期"}, {"key": "end_date", "name": "結束日期"}, {"key": "event_status", "name": "活動狀態"}, {"key": "description", "name": "活動描述"}]'
) 
ON CONFLICT (index) DO UPDATE SET
    title = EXCLUDED.title,
    type = EXCLUDED.type,
    source = EXCLUDED.source,
    size = EXCLUDED.size,
    icon = EXCLUDED.icon,
    paint = EXCLUDED.paint,
    property = EXCLUDED.property;

-- 為台北市集創建專用地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_taipei_dynamic',
    '台北市集活動分佈 - 動態狀態',
    'circle',
    'geojson',
    'big',
    NULL,
    '{"circle-color": ["match", ["get", "event_status"], "not_started", "#2196F3", "active", "#4CAF50", "ending_2weeks", "#FFEB3B", "ending_1week", "#FF9800", "ending_3days", "#F44336", "#666666"], "circle-radius": ["interpolate", ["linear"], ["zoom"], 11.99, 4, 12, 5, 13.5, 6, 15, 8, 22, 12], "circle-stroke-width": 2, "circle-stroke-color": "#FFFFFF", "circle-opacity": 0.85}',
    '[{"key": "name", "name": "市集名稱"}, {"key": "type", "name": "活動類型"}, {"key": "district", "name": "行政區"}, {"key": "start_date", "name": "開始日期"}, {"key": "end_date", "name": "結束日期"}, {"key": "event_status", "name": "活動狀態"}, {"key": "description", "name": "活動描述"}]'
) 
ON CONFLICT (index) DO UPDATE SET
    title = EXCLUDED.title,
    type = EXCLUDED.type,
    source = EXCLUDED.source,
    size = EXCLUDED.size,
    icon = EXCLUDED.icon,
    paint = EXCLUDED.paint,
    property = EXCLUDED.property;

-- 為雙北市集創建專用地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_metrotaipei_dynamic',
    '雙北市集活動分佈 - 動態狀態',
    'circle',
    'geojson',
    'big',
    NULL,
    '{"circle-color": ["match", ["get", "event_status"], "not_started", "#2196F3", "active", "#4CAF50", "ending_2weeks", "#FFEB3B", "ending_1week", "#FF9800", "ending_3days", "#F44336", "#666666"], "circle-radius": ["interpolate", ["linear"], ["zoom"], 11.99, 4, 12, 5, 13.5, 6, 15, 8, 22, 12], "circle-stroke-width": 2, "circle-stroke-color": "#FFFFFF", "circle-opacity": 0.85}',
    '[{"key": "name", "name": "市集名稱"}, {"key": "type", "name": "活動類型"}, {"key": "district", "name": "行政區"}, {"key": "start_date", "name": "開始日期"}, {"key": "end_date", "name": "結束日期"}, {"key": "event_status", "name": "活動狀態"}, {"key": "description", "name": "活動描述"}]'
) 
ON CONFLICT (index) DO UPDATE SET
    title = EXCLUDED.title,
    type = EXCLUDED.type,
    source = EXCLUDED.source,
    size = EXCLUDED.size,
    icon = EXCLUDED.icon,
    paint = EXCLUDED.paint,
    property = EXCLUDED.property;

-- 更新台北市集活動組件使用動態地圖配置
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = 'market_events_taipei_dynamic')
]
WHERE index = 'commercial_district_density' AND city = 'taipei';

-- 更新雙北市集活動組件使用動態地圖配置
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = 'market_events_metrotaipei_dynamic')
]
WHERE index = 'commercial_district_density_metrotaipei' AND city = 'metrotaipei';

-- 顯示配置結果
DO $$
DECLARE
    taipei_config_id INTEGER;
    metro_config_id INTEGER;
BEGIN
    SELECT id INTO taipei_config_id FROM public.component_maps WHERE index = 'market_events_taipei_dynamic';
    SELECT id INTO metro_config_id FROM public.component_maps WHERE index = 'market_events_metrotaipei_dynamic';
    
    RAISE NOTICE '=== 動態顏色市集地圖配置完成 ===';
    RAISE NOTICE '台北地圖配置ID: %', taipei_config_id;
    RAISE NOTICE '雙北地圖配置ID: %', metro_config_id;
    RAISE NOTICE '';
    RAISE NOTICE '🎨 顏色對應說明:';
    RAISE NOTICE '  🔵 藍色 (#2196F3): 尚未開始的活動';
    RAISE NOTICE '  🟢 綠色 (#4CAF50): 正在進行的活動';
    RAISE NOTICE '  🟡 黃色 (#FFEB3B): 活動剩2個禮拜結束';
    RAISE NOTICE '  🟠 橘色 (#FF9800): 活動剩1個禮拜結束';
    RAISE NOTICE '  🔴 紅色 (#F44336): 活動剩3天結束';
    RAISE NOTICE '';
    RAISE NOTICE '💡 請重啟後端服務並重新整理前端頁面查看效果';
END $$;
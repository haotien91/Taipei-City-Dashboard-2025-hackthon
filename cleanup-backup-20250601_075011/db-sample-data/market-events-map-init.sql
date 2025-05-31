-- 市集活動地圖圖層配置腳本
-- 為"市集活動分佈"組件添加地圖顯示功能
-- 創建時間：2024-12-08

-- 新增地圖配置到 component_maps 表
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_taipei',
    '市集活動分佈點',
    'circle',
    'geojson',
    'big',
    NULL,
    '{
        "circle-color": "#FF6B6B",
        "circle-radius": [
            "interpolate",
            ["linear"],
            ["zoom"],
            11.99,
            4,
            12,
            5,
            13.5,
            6,
            15,
            8,
            22,
            12
        ],
        "circle-stroke-width": 2,
        "circle-stroke-color": "#FFFFFF",
        "circle-opacity": 0.8
    }',
    '[
        {"key": "name", "name": "市集名稱"},
        {"key": "type", "name": "活動類型"},
        {"key": "district", "name": "行政區"},
        {"key": "start_date", "name": "開始日期"},
        {"key": "end_date", "name": "結束日期"},
        {"key": "description", "name": "活動描述"}
    ]'
) 
ON CONFLICT (index) DO UPDATE SET
    title = EXCLUDED.title,
    type = EXCLUDED.type,
    source = EXCLUDED.source,
    size = EXCLUDED.size,
    icon = EXCLUDED.icon,
    paint = EXCLUDED.paint,
    property = EXCLUDED.property;

-- 更新"市集活動分佈"組件的地圖配置
-- 取得剛創建的地圖配置ID
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = 'market_events_taipei')
]
WHERE index = 'commercial_district_density' AND city = 'taipei';

-- 顯示成功訊息
DO $$
DECLARE
    map_config_id INTEGER;
BEGIN
    SELECT id INTO map_config_id FROM public.component_maps WHERE index = 'market_events_taipei';
    
    RAISE NOTICE '=== 市集活動地圖配置完成 ===';
    RAISE NOTICE '地圖配置ID: %', map_config_id;
    RAISE NOTICE '配置名稱: 市集活動分佈點';
    RAISE NOTICE '圖層類型: circle (紅色圓點)';
    RAISE NOTICE '資料來源: market_events_taipei.geojson';
    RAISE NOTICE '已關聯組件: commercial_district_density (taipei)';
    RAISE NOTICE '';
    RAISE NOTICE '🗺️ 地圖功能已啟用！';
    RAISE NOTICE '💡 請重啟後端服務並重新整理前端頁面';
    RAISE NOTICE '📍 現在在地圖檢視中將看到紅色圓點標示各市集位置';
END $$; 
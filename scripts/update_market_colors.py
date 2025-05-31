#!/usr/bin/env python3

import json
import os
from datetime import datetime, timedelta

# 顏色配置
STATUS_COLORS = {
    'not_started': '#2196F3',    # 藍色：尚未開始的活動
    'active': '#4CAF50',         # 綠色：正在進行的活動
    'ending_2weeks': '#FFEB3B',  # 黃色：活動剩2個禮拜結束
    'ending_1week': '#FF9800',   # 橘色：活動剩一個禮拜結束
    'ending_3days': '#F44336'    # 紅色：活動剩3天結束
}

def calculate_event_status(start_date, end_date):
    """計算活動狀態"""
    today = datetime.now().date()
    
    try:
        start = datetime.strptime(start_date, '%Y-%m-%d').date()
        end = datetime.strptime(end_date, '%Y-%m-%d').date()
    except ValueError:
        return 'unknown'
    
    # 尚未開始
    if today < start:
        return 'not_started'
    
    # 已結束
    if today > end:
        return 'ended'
    
    # 計算剩餘天數
    days_left = (end - today).days
    
    # 正在進行中，根據剩餘天數分類
    if days_left <= 3:
        return 'ending_3days'
    elif days_left <= 7:
        return 'ending_1week'
    elif days_left <= 14:
        return 'ending_2weeks'
    else:
        return 'active'

def update_geojson_with_status(input_file, output_file):
    """更新 GeoJSON 檔案，添加狀態資訊"""
    print(f"\n🔄 處理檔案: {input_file}")
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        status_counts = {
            'not_started': 0,
            'active': 0,
            'ending_2weeks': 0,
            'ending_1week': 0,
            'ending_3days': 0,
            'ended': 0,
            'unknown': 0
        }
        
        for feature in data['features']:
            props = feature['properties']
            start_date = props.get('start_date')
            end_date = props.get('end_date')
            
            if start_date and end_date:
                status = calculate_event_status(start_date, end_date)
                props['event_status'] = status
                props['status_color'] = STATUS_COLORS.get(status, '#666666')
                
                status_counts[status] += 1
                updated_count += 1
                
                color_emoji = {
                    'not_started': '🔵',
                    'active': '🟢',
                    'ending_2weeks': '🟡',
                    'ending_1week': '🟠',
                    'ending_3days': '🔴',
                    'ended': '⚫',
                    'unknown': '⚪'
                }.get(status, '⚪')
                
                print(f"  ✅ {props['name']}: {status} {color_emoji} ({STATUS_COLORS.get(status, '#666666')})")
            else:
                print(f"  ⚠️  {props['name']}: 缺少日期資訊")
                status_counts['unknown'] += 1
        
        # 寫入更新後的檔案
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 處理結果:")
        print(f"  更新特徵數: {updated_count}")
        print(f"  🔵 尚未開始: {status_counts['not_started']}")
        print(f"  🟢 正在進行: {status_counts['active']}")
        print(f"  🟡 剩2週結束: {status_counts['ending_2weeks']}")
        print(f"  🟠 剩1週結束: {status_counts['ending_1week']}")
        print(f"  🔴 剩3天結束: {status_counts['ending_3days']}")
        print(f"  ⚫ 已結束: {status_counts['ended']}")
        print(f"  ⚪ 資訊不全: {status_counts['unknown']}")
        
        return status_counts
        
    except Exception as error:
        print(f"❌ 處理檔案錯誤: {error}")
        return None

def create_dynamic_map_sql():
    """創建動態地圖配置 SQL"""
    current_time = datetime.now().isoformat()
    
    paint_config = {
        "circle-color": [
            "match",
            ["get", "event_status"],
            "not_started", "#2196F3",      # 藍色：尚未開始
            "active", "#4CAF50",           # 綠色：正在進行
            "ending_2weeks", "#FFEB3B",    # 黃色：剩2週結束
            "ending_1week", "#FF9800",     # 橘色：剩1週結束
            "ending_3days", "#F44336",     # 紅色：剩3天結束
            "#666666"                      # 灰色：其他狀態
        ],
        "circle-radius": [
            "interpolate",
            ["linear"],
            ["zoom"],
            11.99, 4,
            12, 5,
            13.5, 6,
            15, 8,
            22, 12
        ],
        "circle-stroke-width": 2,
        "circle-stroke-color": "#FFFFFF",
        "circle-opacity": 0.85
    }
    
    property_config = [
        {"key": "name", "name": "市集名稱"},
        {"key": "type", "name": "活動類型"},
        {"key": "district", "name": "行政區"},
        {"key": "start_date", "name": "開始日期"},
        {"key": "end_date", "name": "結束日期"},
        {"key": "event_status", "name": "活動狀態"},
        {"key": "description", "name": "活動描述"}
    ]
    
    return f"""-- 動態顏色市集活動地圖配置
-- 根據活動狀態顯示不同顏色的圓點
-- 創建時間：{current_time}

-- 新增動態顏色地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    'market_events_dynamic',
    '市集活動分佈 - 動態狀態',
    'circle',
    'geojson',
    'big',
    NULL,
    '{json.dumps(paint_config, ensure_ascii=False)}',
    '{json.dumps(property_config, ensure_ascii=False)}'
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
    '{json.dumps(paint_config, ensure_ascii=False)}',
    '{json.dumps(property_config, ensure_ascii=False)}'
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
    '{json.dumps(paint_config, ensure_ascii=False)}',
    '{json.dumps(property_config, ensure_ascii=False)}'
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
END $$;"""

def main():
    print('🎨 台北城市儀表板 - 市集活動動態顏色配置工具')
    print('=' * 60)
    
    files = [
        {
            'input': 'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson',
            'output': 'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson'
        },
        {
            'input': 'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson',
            'output': 'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson'
        }
    ]
    
    total_stats = {
        'not_started': 0,
        'active': 0,
        'ending_2weeks': 0,
        'ending_1week': 0,
        'ending_3days': 0,
        'ended': 0,
        'unknown': 0
    }
    
    # 更新所有 GeoJSON 檔案
    for file_info in files:
        input_file = file_info['input']
        output_file = file_info['output']
        
        if os.path.exists(input_file):
            stats = update_geojson_with_status(input_file, output_file)
            if stats:
                for key in stats:
                    total_stats[key] += stats[key]
        else:
            print(f"⚠️  檔案不存在: {input_file}")
    
    # 創建 SQL 配置檔案
    sql_content = create_dynamic_map_sql()
    sql_file = 'db-sample-data/market-events-dynamic-map.sql'
    
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write(sql_content)
    
    print(f"\n📄 SQL 配置檔案已創建: {sql_file}")
    
    # 顯示總體統計
    print(f"\n🎯 總體統計:")
    print(f"  🔵 尚未開始: {total_stats['not_started']} 個活動")
    print(f"  🟢 正在進行: {total_stats['active']} 個活動")
    print(f"  🟡 剩2週結束: {total_stats['ending_2weeks']} 個活動")
    print(f"  🟠 剩1週結束: {total_stats['ending_1week']} 個活動")
    print(f"  🔴 剩3天結束: {total_stats['ending_3days']} 個活動")
    print(f"  ⚫ 已結束: {total_stats['ended']} 個活動")
    print(f"  ⚪ 資訊不全: {total_stats['unknown']} 個活動")
    
    # 部署說明
    print(f"\n🚀 部署步驟:")
    print(f"  1. 檢查數據庫容器運行:")
    print(f"     docker ps | grep postgres")
    print(f"  2. 執行 SQL 配置:")
    print(f"     docker exec postgres-manager psql -U postgres -d dashboardmanager -f /shared/{sql_file}")
    print(f"  3. 重啟後端服務:")
    print(f"     docker restart dashboard-be")
    print(f"  4. 重新整理前端頁面")
    
    print(f"\n✨ 處理完成！現在地圖上的圓點將根據活動狀態顯示不同顏色:")
    print(f"  📍 每個活動會根據當前日期與活動時間計算狀態")
    print(f"  🎨 顏色會自動反映活動的緊急程度")
    print(f"  🔄 每次載入時都會重新計算最新狀態")

if __name__ == '__main__':
    main() 
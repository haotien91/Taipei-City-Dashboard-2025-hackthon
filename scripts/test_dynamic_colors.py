#!/usr/bin/env python3

import json
import requests
from datetime import datetime

def test_geojson_status():
    """測試 GeoJSON 檔案中的狀態字段"""
    print("🧪 測試 GeoJSON 檔案中的動態狀態...")
    
    files = [
        'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson',
        'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson'
    ]
    
    for file_path in files:
        print(f"\n📁 檢查檔案: {file_path}")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            features = data['features']
            status_summary = {}
            
            for feature in features[:5]:  # 只檢查前5個
                props = feature['properties']
                name = props['name']
                event_status = props.get('event_status', 'missing')
                status_color = props.get('status_color', 'missing')
                start_date = props.get('start_date', 'N/A')
                end_date = props.get('end_date', 'N/A')
                
                if event_status not in status_summary:
                    status_summary[event_status] = 0
                status_summary[event_status] += 1
                
                color_emoji = {
                    'not_started': '🔵',
                    'active': '🟢',
                    'ending_2weeks': '🟡',
                    'ending_1week': '🟠',
                    'ending_3days': '🔴',
                    'ended': '⚫'
                }.get(event_status, '⚪')
                
                print(f"  {color_emoji} {name}")
                print(f"    狀態: {event_status} | 顏色: {status_color}")
                print(f"    日期: {start_date} → {end_date}")
            
            print(f"\n📊 狀態統計 (前5個):")
            for status, count in status_summary.items():
                emoji = {
                    'not_started': '🔵',
                    'active': '🟢',
                    'ending_2weeks': '🟡',
                    'ending_1week': '🟠',
                    'ending_3days': '🔴',
                    'ended': '⚫'
                }.get(status, '⚪')
                print(f"    {emoji} {status}: {count}")
                
        except Exception as e:
            print(f"❌ 錯誤: {e}")

def test_backend_api():
    """測試後端 API 是否響應"""
    print("\n🔗 測試後端 API 連接...")
    
    try:
        response = requests.get('http://localhost:8088/api/v1/health', timeout=5)
        if response.status_code == 200:
            print("✅ 後端 API 響應正常")
        else:
            print(f"⚠️ 後端 API 異常狀態碼: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print("❌ 無法連接到後端 API (localhost:8088)")
    except requests.exceptions.Timeout:
        print("❌ 後端 API 請求超時")
    except Exception as e:
        print(f"❌ 後端 API 測試錯誤: {e}")

def test_map_config():
    """測試地圖配置 API"""
    print("\n🗺️ 測試地圖配置...")
    
    try:
        response = requests.get('http://localhost:8088/api/v1/map-config', timeout=10)
        if response.status_code == 200:
            data = response.json()
            dynamic_configs = [config for config in data if 'dynamic' in config.get('index', '')]
            
            if dynamic_configs:
                print(f"✅ 找到 {len(dynamic_configs)} 個動態地圖配置:")
                for config in dynamic_configs:
                    print(f"  • {config.get('index')}: {config.get('title')}")
            else:
                print("⚠️ 未找到動態地圖配置")
        else:
            print(f"⚠️ 地圖配置 API 狀態碼: {response.status_code}")
    except Exception as e:
        print(f"❌ 地圖配置測試錯誤: {e}")

def show_color_legend():
    """顯示顏色對應說明"""
    print("\n🎨 動態顏色對應說明:")
    print("=" * 50)
    
    colors = [
        ("🔵", "#2196F3", "尚未開始的活動"),
        ("🟢", "#4CAF50", "正在進行的活動"),
        ("🟡", "#FFEB3B", "活動剩2個禮拜結束"),
        ("🟠", "#FF9800", "活動剩1個禮拜結束"),
        ("🔴", "#F44336", "活動剩3天結束")
    ]
    
    for emoji, color_code, description in colors:
        print(f"  {emoji} {color_code}: {description}")

def main():
    print("🎨 台北城市儀表板 - 動態顏色功能測試")
    print("=" * 60)
    print(f"測試時間: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    test_geojson_status()
    test_backend_api()
    test_map_config()
    show_color_legend()
    
    print("\n✨ 測試完成！")
    print("\n📋 使用說明:")
    print("  1. 開啟瀏覽器前往 http://localhost")
    print("  2. 登入系統")
    print("  3. 點擊左側選單「地圖檢視」")
    print("  4. 展開「市集活動分佈」組件")
    print("  5. 觀察地圖上的圓點顏色變化")
    print("  6. 點擊圓點查看詳細活動資訊")
    
    print("\n🔄 顏色會根據以下邏輯自動更新:")
    print("  • 每次載入頁面時重新計算狀態")
    print("  • 基於當前日期與活動開始/結束時間")
    print("  • 圓點顏色即時反映活動緊急程度")

if __name__ == '__main__':
    main() 
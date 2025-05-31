#!/usr/bin/env python3

import json
import os
import requests
import sys

def check_geojson_files():
    """檢查 GeoJSON 檔案是否存在且格式正確"""
    print("🗺️  檢查 GeoJSON 檔案...")
    
    files = [
        'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson',
        'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson'
    ]
    
    for file_path in files:
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                feature_count = len(data.get('features', []))
                print(f"✅ {file_path}")
                print(f"   特徵數量: {feature_count}")
                
                # 檢查前3個特徵的座標
                if feature_count > 0:
                    for i, feature in enumerate(data['features'][:3]):
                        name = feature['properties']['name']
                        coords = feature['geometry']['coordinates']
                        print(f"   [{i+1}] {name}: {coords}")
                
            except json.JSONDecodeError as e:
                print(f"❌ {file_path} - JSON 格式錯誤: {e}")
            except Exception as e:
                print(f"❌ {file_path} - 讀取錯誤: {e}")
        else:
            print(f"❌ 檔案不存在: {file_path}")

def check_backend_status():
    """檢查後端服務狀態"""
    print("\n🔧 檢查後端服務狀態...")
    
    try:
        # 檢查健康狀態
        response = requests.get('http://localhost:8080/api/v1/health', timeout=5)
        if response.status_code == 200:
            print("✅ 後端服務運行正常")
        else:
            print(f"⚠️  後端服務回應異常: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print("❌ 無法連接到後端服務 (localhost:8080)")
    except requests.exceptions.Timeout:
        print("❌ 後端服務回應超時")
    except Exception as e:
        print(f"❌ 後端服務檢查錯誤: {e}")

def check_map_config_api():
    """檢查地圖配置 API"""
    print("\n🗺️  檢查地圖配置 API...")
    
    try:
        # 檢查地圖配置 API
        response = requests.get('http://localhost:8080/api/v1/map-config', timeout=10)
        if response.status_code == 200:
            data = response.json()
            print("✅ 地圖配置 API 運行正常")
            
            # 檢查市集活動相關配置
            market_configs = [config for config in data if 'market_events' in config.get('index', '')]
            print(f"   市集地圖配置數量: {len(market_configs)}")
            
            for config in market_configs:
                print(f"   • {config.get('index')}: {config.get('title')}")
                
        else:
            print(f"⚠️  地圖配置 API 回應異常: {response.status_code}")
    except requests.exceptions.ConnectionError:
        print("❌ 無法連接到地圖配置 API")
    except requests.exceptions.Timeout:
        print("❌ 地圖配置 API 回應超時")
    except Exception as e:
        print(f"❌ 地圖配置 API 檢查錯誤: {e}")

def check_component_api():
    """檢查組件 API"""
    print("\n📊 檢查組件 API...")
    
    try:
        # 檢查台北市集活動組件
        response = requests.get('http://localhost:8080/api/v1/component/commercial_district_density', timeout=10)
        if response.status_code == 200:
            data = response.json()
            print("✅ 台北市集活動組件 API 正常")
            map_config_ids = data.get('map_config_ids', [])
            if map_config_ids:
                print(f"   關聯地圖配置 ID: {map_config_ids}")
            else:
                print("   ⚠️  未關聯地圖配置")
        else:
            print(f"⚠️  台北市集活動組件 API 異常: {response.status_code}")
            
        # 檢查雙北市集活動組件  
        response = requests.get('http://localhost:8080/api/v1/component/commercial_district_density_metrotaipei', timeout=10)
        if response.status_code == 200:
            data = response.json()
            print("✅ 雙北市集活動組件 API 正常")
            map_config_ids = data.get('map_config_ids', [])
            if map_config_ids:
                print(f"   關聯地圖配置 ID: {map_config_ids}")
            else:
                print("   ⚠️  未關聯地圖配置")
        else:
            print(f"⚠️  雙北市集活動組件 API 異常: {response.status_code}")
            
    except requests.exceptions.ConnectionError:
        print("❌ 無法連接到組件 API")
    except requests.exceptions.Timeout:
        print("❌ 組件 API 回應超時")
    except Exception as e:
        print(f"❌ 組件 API 檢查錯誤: {e}")

def check_geojson_accessibility():
    """檢查 GeoJSON 檔案是否可通過 HTTP 存取"""
    print("\n🌐 檢查 GeoJSON 檔案 HTTP 存取...")
    
    files = [
        'market_events_taipei.geojson',
        'market_events_metrotaipei.geojson'
    ]
    
    for filename in files:
        try:
            response = requests.get(f'http://localhost/mapData/{filename}', timeout=10)
            if response.status_code == 200:
                try:
                    data = response.json()
                    feature_count = len(data.get('features', []))
                    print(f"✅ {filename} 可正常存取 ({feature_count} 個特徵)")
                except json.JSONDecodeError:
                    print(f"⚠️  {filename} 可存取但 JSON 格式錯誤")
            else:
                print(f"❌ {filename} HTTP 存取失敗: {response.status_code}")
        except requests.exceptions.ConnectionError:
            print(f"❌ 無法連接到前端服務存取 {filename}")
        except requests.exceptions.Timeout:
            print(f"❌ {filename} 存取超時")
        except Exception as e:
            print(f"❌ {filename} 存取錯誤: {e}")

def print_troubleshooting_tips():
    """列印疑難排解提示"""
    print("\n🔧 疑難排解提示:")
    print("=" * 50)
    print("如果地圖上沒有顯示點位，請檢查:")
    print("1. 🔄 重新整理瀏覽器頁面並清除快取")
    print("2. 🗺️  確認在地圖檢視中選擇了正確的組件")
    print("3. 🔍 地圖縮放級別是否適當 (建議 zoom: 11-14)")
    print("4. 📡 檢查瀏覽器開發者工具的網路請求")
    print("5. 🔴 確認地圖樣式中的圓點顏色是否與背景對比明顯")
    print("6. 📊 檢查組件資料是否正確載入")
    print("7. 🎨 檢查 Mapbox token 是否有效")
    print("")
    print("建議操作:")
    print("• 開啟瀏覽器開發者工具 (F12)")
    print("• 查看 Console 是否有錯誤訊息")
    print("• 查看 Network 是否有失敗的請求")
    print("• 確認 mapData/*.geojson 檔案能正常載入")

def main():
    print("🚀 台北城市儀表板 - 地圖狀態檢查工具")
    print("=" * 50)
    
    check_geojson_files()
    check_backend_status() 
    check_map_config_api()
    check_component_api()
    check_geojson_accessibility()
    print_troubleshooting_tips()
    
    print("\n✨ 檢查完成！")

if __name__ == "__main__":
    main() 
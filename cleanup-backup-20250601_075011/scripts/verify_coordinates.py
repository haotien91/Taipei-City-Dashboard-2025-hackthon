#!/usr/bin/env python3

import json
import os
import sys

# 台北市和新北市的合理座標範圍
VALID_BOUNDS = {
    # 擴大範圍以涵蓋雙北地區
    'min_lat': 24.90,  # 最南（新店、中和）
    'max_lat': 25.30,  # 最北（淡水、北投）
    'min_lng': 121.35, # 最西（林口）
    'max_lng': 121.70  # 最東（南港、汐止）
}

def validate_coordinates(geojson_path):
    print(f"\n🔍 驗證檔案: {geojson_path}")
    
    try:
        with open(geojson_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        features = data.get('features', [])
        valid_count = 0
        invalid_count = 0
        out_of_bounds_points = []
        
        for index, feature in enumerate(features):
            coords = feature['geometry']['coordinates']
            lng = coords[0]
            lat = coords[1]
            name = feature['properties']['name']
            feature_type = feature['properties']['type']
            city = feature['properties'].get('city', '台北市')
            
            # 檢查座標是否在有效範圍內
            if (lat >= VALID_BOUNDS['min_lat'] and lat <= VALID_BOUNDS['max_lat'] and
                lng >= VALID_BOUNDS['min_lng'] and lng <= VALID_BOUNDS['max_lng']):
                valid_count += 1
                print(f"✅ [{index + 1}] {name} ({feature_type}) - {city}")
                print(f"   座標: [{lng}, {lat}]")
            else:
                invalid_count += 1
                issues = []
                
                if lat < VALID_BOUNDS['min_lat']:
                    issues.append('緯度過低')
                if lat > VALID_BOUNDS['max_lat']:
                    issues.append('緯度過高')
                if lng < VALID_BOUNDS['min_lng']:
                    issues.append('經度過低')
                if lng > VALID_BOUNDS['max_lng']:
                    issues.append('經度過高')
                
                out_of_bounds_points.append({
                    'index': index + 1,
                    'name': name,
                    'type': feature_type,
                    'city': city,
                    'coordinates': [lng, lat],
                    'issues': issues
                })
                
                print(f"❌ [{index + 1}] {name} ({feature_type}) - {city}")
                print(f"   座標: [{lng}, {lat}] - {', '.join(issues)}")
        
        print(f"\n📊 驗證結果:")
        print(f"   總點數: {len(features)}")
        print(f"   有效座標: {valid_count}")
        print(f"   無效座標: {invalid_count}")
        
        if out_of_bounds_points:
            print(f"\n⚠️  需要修正的座標:")
            for point in out_of_bounds_points:
                print(f"   • {point['name']} - {', '.join(point['issues'])}")
                
                # 提供建議座標
                suggested_lat = point['coordinates'][1]
                suggested_lng = point['coordinates'][0]
                
                if suggested_lat < VALID_BOUNDS['min_lat']:
                    suggested_lat = VALID_BOUNDS['min_lat'] + 0.01
                if suggested_lat > VALID_BOUNDS['max_lat']:
                    suggested_lat = VALID_BOUNDS['max_lat'] - 0.01
                if suggested_lng < VALID_BOUNDS['min_lng']:
                    suggested_lng = VALID_BOUNDS['min_lng'] + 0.01
                if suggested_lng > VALID_BOUNDS['max_lng']:
                    suggested_lng = VALID_BOUNDS['max_lng'] - 0.01
                
                print(f"     建議座標: [{suggested_lng}, {suggested_lat}]")
        
        return {
            'total': len(features),
            'valid': valid_count,
            'invalid': invalid_count,
            'out_of_bounds': out_of_bounds_points
        }
        
    except Exception as error:
        print(f"❌ 讀取檔案錯誤: {error}")
        return None

def validate_map_bounds():
    print('🗺️  台北城市儀表板 - 座標驗證工具')
    print('=======================================')
    print(f"有效座標範圍:")
    print(f"  緯度: {VALID_BOUNDS['min_lat']} ~ {VALID_BOUNDS['max_lat']}")
    print(f"  經度: {VALID_BOUNDS['min_lng']} ~ {VALID_BOUNDS['max_lng']}")
    
    files = [
        'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson',
        'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson'
    ]
    
    total_stats = {
        'total': 0,
        'valid': 0,
        'invalid': 0,
        'files': 0
    }
    
    for file in files:
        if os.path.exists(file):
            result = validate_coordinates(file)
            if result:
                total_stats['total'] += result['total']
                total_stats['valid'] += result['valid']
                total_stats['invalid'] += result['invalid']
                total_stats['files'] += 1
        else:
            print(f"⚠️  檔案不存在: {file}")
    
    print(f"\n🎯 總體統計:")
    print(f"   檢查檔案: {total_stats['files']}")
    print(f"   總點數: {total_stats['total']}")
    print(f"   有效座標: {total_stats['valid']}")
    print(f"   無效座標: {total_stats['invalid']}")
    
    if total_stats['total'] > 0:
        success_rate = (total_stats['valid'] / total_stats['total']) * 100
        print(f"   成功率: {success_rate:.1f}%")
    
    if total_stats['invalid'] == 0:
        print(f"\n🎉 所有座標都在有效範圍內！地圖應該能正確顯示所有點位。")
    else:
        print(f"\n🔧 建議修正 {total_stats['invalid']} 個無效座標以確保完整顯示。")

if __name__ == "__main__":
    validate_map_bounds() 
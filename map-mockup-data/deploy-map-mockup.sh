#!/bin/bash
# 商圈活化地圖數據部署腳本

set -e

echo "🗺️  開始部署商圈活化地圖數據..."

# 檢查前端專案是否存在
FE_DIR="../Taipei-City-Dashboard-FE"
if [ ! -d "$FE_DIR" ]; then
    echo "❌ 錯誤: 找不到前端專案目錄 $FE_DIR"
    echo "請確保此腳本在正確的位置執行"
    exit 1
fi

# 創建地圖數據目錄（如果不存在）
MAP_DATA_DIR="$FE_DIR/public/mapData"
if [ ! -d "$MAP_DATA_DIR" ]; then
    echo "📁 創建地圖數據目錄..."
    mkdir -p "$MAP_DATA_DIR"
fi

# 複製 GeoJSON 檔案
echo "📋 複製地圖數據檔案..."
cp commercial-districts.geojson "$MAP_DATA_DIR/"
cp traffic-hotspots.geojson "$MAP_DATA_DIR/"
cp traffic-flows.geojson "$MAP_DATA_DIR/"

echo "✅ 地圖數據檔案已複製到: $MAP_DATA_DIR"

# 創建測試組件
TEST_COMPONENT_DIR="$FE_DIR/src/components/test"
mkdir -p "$TEST_COMPONENT_DIR"

echo "🔧 創建測試組件..."
cat > "$TEST_COMPONENT_DIR/CommercialDistrictMap.vue" << 'EOF'
<template>
  <div class="commercial-district-map-test">
    <h2>商圈活化地圖測試</h2>
    <div id="test-map" class="map-container"></div>
    <div class="layer-controls">
      <h3>圖層控制</h3>
      <label v-for="layer in layers" :key="layer.id">
        <input 
          type="checkbox" 
          v-model="layer.visible"
          @change="toggleLayer(layer)"
        />
        {{ layer.name }}
      </label>
    </div>
    <div class="info-panel" v-if="selectedFeature">
      <h3>詳細資訊</h3>
      <pre>{{ JSON.stringify(selectedFeature, null, 2) }}</pre>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import mapboxgl from 'mapbox-gl'

// 設定 Mapbox token (需要替換為實際的 token)
mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN || 'YOUR_MAPBOX_TOKEN'

const map = ref(null)
const selectedFeature = ref(null)
const layers = ref([
  { id: 'commercial-districts', name: '商圈範圍', visible: true, type: 'fill' },
  { id: 'traffic-hotspots', name: '人流熱點', visible: true, type: 'circle' },
  { id: 'traffic-flows', name: '人流動線', visible: false, type: 'arc' }
])

onMounted(() => {
  // 初始化地圖
  map.value = new mapboxgl.Map({
    container: 'test-map',
    style: 'mapbox://styles/mapbox/light-v11',
    center: [121.535, 25.045],
    zoom: 12
  })

  map.value.on('load', () => {
    // 載入商圈範圍
    map.value.addSource('commercial-districts', {
      type: 'geojson',
      data: '/mapData/commercial-districts.geojson'
    })

    map.value.addLayer({
      id: 'commercial-districts',
      type: 'fill',
      source: 'commercial-districts',
      paint: {
        'fill-color': [
          'interpolate',
          ['linear'],
          ['get', 'visitor_count'],
          0, '#FFE4B5',
          30000, '#FFA500',
          50000, '#FF6347',
          70000, '#DC143C'
        ],
        'fill-opacity': 0.7
      }
    })

    // 載入人流熱點
    map.value.addSource('traffic-hotspots', {
      type: 'geojson',
      data: '/mapData/traffic-hotspots.geojson'
    })

    map.value.addLayer({
      id: 'traffic-hotspots',
      type: 'circle',
      source: 'traffic-hotspots',
      paint: {
        'circle-radius': [
          'interpolate',
          ['linear'],
          ['get', 'flow_intensity'],
          0, 5,
          50, 10,
          100, 20
        ],
        'circle-color': [
          'interpolate',
          ['linear'],
          ['get', 'flow_intensity'],
          0, '#00FF00',
          50, '#FFFF00',
          75, '#FFA500',
          100, '#FF0000'
        ],
        'circle-blur': 0.5,
        'circle-opacity': 0.8
      }
    })

    // 設定點擊事件
    map.value.on('click', 'commercial-districts', (e) => {
      selectedFeature.value = e.features[0].properties
    })

    map.value.on('click', 'traffic-hotspots', (e) => {
      selectedFeature.value = e.features[0].properties
    })

    // 設定游標樣式
    map.value.on('mouseenter', 'commercial-districts', () => {
      map.value.getCanvas().style.cursor = 'pointer'
    })

    map.value.on('mouseleave', 'commercial-districts', () => {
      map.value.getCanvas().style.cursor = ''
    })
  })
})

const toggleLayer = (layer) => {
  if (map.value.getLayer(layer.id)) {
    map.value.setLayoutProperty(
      layer.id,
      'visibility',
      layer.visible ? 'visible' : 'none'
    )
  }
}
</script>

<style scoped>
.commercial-district-map-test {
  padding: 20px;
}

.map-container {
  width: 100%;
  height: 600px;
  margin-bottom: 20px;
}

.layer-controls {
  background: #f5f5f5;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.layer-controls label {
  display: block;
  margin: 10px 0;
}

.info-panel {
  background: #f0f0f0;
  padding: 15px;
  border-radius: 8px;
}

.info-panel pre {
  background: white;
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
}
</style>
EOF

# 創建測試路由
echo "🛣️  設定測試路由..."
cat > "$TEST_COMPONENT_DIR/test-route.js" << 'EOF'
// 將此路由添加到 router/index.js

{
  path: '/test/commercial-map',
  name: 'commercial-map-test',
  component: () => import('@/components/test/CommercialDistrictMap.vue'),
  meta: {
    title: '商圈活化地圖測試'
  }
}
EOF

echo "📝 創建 README..."
cat > "./README.md" << 'EOF'
# 商圈活化地圖數據 Mockup

這個目錄包含了台北市商圈活化的地圖數據範例。

## 檔案說明

- `commercial-districts.geojson` - 商圈範圍多邊形數據
- `traffic-hotspots.geojson` - 人流熱點點位數據
- `traffic-flows.geojson` - 人流動線數據
- `MAP-IMPLEMENTATION-GUIDE.md` - 完整實作指南

## 快速開始

1. 執行部署腳本：
   ```bash
   bash deploy-map-mockup.sh
   ```

2. 在前端專案中設定 Mapbox Token：
   - 編輯 `Taipei-City-Dashboard-FE/.env.local`
   - 添加 `VITE_MAPBOX_TOKEN=your_mapbox_token`

3. 啟動前端開發服務器：
   ```bash
   cd ../Taipei-City-Dashboard-FE
   npm run dev
   ```

4. 訪問測試頁面：
   - http://localhost:3000/test/commercial-map

## 數據結構

### 商圈範圍 (Polygon)
- `district_id` - 商圈唯一識別碼
- `name` - 商圈名稱
- `visitor_count` - 訪客數量
- `shop_count` - 商家數量
- `avg_spending` - 平均消費金額

### 人流熱點 (Point)
- `hotspot_id` - 熱點唯一識別碼
- `name` - 地點名稱
- `flow_intensity` - 人流強度 (0-100)
- `current_flow` - 當前人流量
- `peak_flow` - 尖峰人流量

### 人流動線 (LineString)
- `flow_id` - 動線唯一識別碼
- `origin` - 起點名稱
- `destination` - 終點名稱
- `flow_volume` - 人流量
- `transport_mode` - 交通方式

## 整合到正式環境

請參考 `MAP-IMPLEMENTATION-GUIDE.md` 了解如何：
- 設定資料庫結構
- 配置 Airflow 資料管線
- 實作即時數據更新
- 優化地圖效能
EOF

echo "✅ 部署完成！"
echo ""
echo "📋 下一步："
echo "1. 設定 Mapbox Token："
echo "   編輯 $FE_DIR/.env.local"
echo "   添加 VITE_MAPBOX_TOKEN=your_token"
echo ""
echo "2. 添加測試路由到 router/index.js"
echo "   參考 $TEST_COMPONENT_DIR/test-route.js"
echo ""
echo "3. 啟動前端服務："
echo "   cd $FE_DIR"
echo "   npm run dev"
echo ""
echo "4. 訪問測試頁面："
echo "   http://localhost:3000/test/commercial-map"
</rewritten_file> 
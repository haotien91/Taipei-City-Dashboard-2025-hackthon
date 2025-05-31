# 商圈活化地圖數據實作指南

## 1. 前端地圖配置

### A. 在 component_maps 表中的配置

```json
{
  "map_config": [
    {
      "index": "commercial_districts",
      "paint": {
        "fill-color": [
          "interpolate",
          ["linear"],
          ["get", "visitor_count"],
          0,
          "#FFE4B5",
          30000,
          "#FFA500",
          50000,
          "#FF6347",
          70000,
          "#DC143C"
        ],
        "fill-opacity": 0.7
      },
      "property": [
        { "key": "name", "name": "商圈名稱" },
        { "key": "visitor_count", "name": "今日人流" },
        { "key": "shop_count", "name": "商家數量" },
        { "key": "avg_spending", "name": "平均消費" },
        { "key": "peak_hours", "name": "尖峰時段" }
      ],
      "title": "商圈範圍與人流密度",
      "type": "fill",
      "source": "geojson"
    },
    {
      "index": "traffic_hotspots",
      "paint": {
        "circle-radius": [
          "interpolate",
          ["linear"],
          ["get", "flow_intensity"],
          0,
          5,
          50,
          10,
          100,
          20
        ],
        "circle-color": [
          "interpolate",
          ["linear"],
          ["get", "flow_intensity"],
          0,
          "#00FF00",
          50,
          "#FFFF00",
          75,
          "#FFA500",
          100,
          "#FF0000"
        ],
        "circle-blur": 0.5,
        "circle-opacity": 0.8
      },
      "property": [
        { "key": "name", "name": "地點名稱" },
        { "key": "current_flow", "name": "當前人流" },
        { "key": "peak_flow", "name": "尖峰人流" },
        { "key": "type", "name": "地點類型" }
      ],
      "title": "即時人流熱點",
      "type": "circle",
      "icon": "heatmap",
      "source": "geojson"
    },
    {
      "index": "traffic_flows",
      "paint": {
        "arc-color": ["#00BFFF", "#1E90FF"],
        "arc-width": [
          "interpolate",
          ["linear"],
          ["get", "flow_volume"],
          0,
          2,
          5000,
          4,
          10000,
          8,
          15000,
          12
        ],
        "arc-opacity": 0.6,
        "arc-animate": true
      },
      "property": [
        { "key": "origin", "name": "起點" },
        { "key": "destination", "name": "終點" },
        { "key": "flow_volume", "name": "人流量" },
        { "key": "transport_mode", "name": "交通方式" },
        { "key": "avg_duration", "name": "平均時長(分)" }
      ],
      "title": "人流動線",
      "type": "arc",
      "source": "geojson"
    }
  ]
}
```

### B. Vue 組件整合範例

```vue
<template>
  <div class="commercial-district-map">
    <MapComponent
      :config="mapConfig"
      :layers="activeLayers"
      @layer-click="handleLayerClick"
    />
    <div class="map-controls">
      <button
        v-for="layer in availableLayers"
        :key="layer.id"
        :class="{ active: activeLayers.includes(layer.id) }"
        @click="toggleLayer(layer.id)"
      >
        {{ layer.name }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useMapStore } from "@/stores/map";
import { useContentStore } from "@/stores/content";

const mapStore = useMapStore();
const contentStore = useContentStore();

const activeLayers = ref(["commercial_districts"]);
const availableLayers = [
  { id: "commercial_districts", name: "商圈範圍" },
  { id: "traffic_hotspots", name: "人流熱點" },
  { id: "traffic_flows", name: "人流動線" },
];

onMounted(async () => {
  // 載入地圖數據
  await mapStore.loadMapData("commercial_districts");

  // 載入即時數據
  const realtimeData = await contentStore.fetchComponentData(
    "commercial_traffic_realtime"
  );
  if (realtimeData) {
    mapStore.updateLayerData("traffic_hotspots", realtimeData);
  }
});

const toggleLayer = (layerId: string) => {
  const index = activeLayers.value.indexOf(layerId);
  if (index > -1) {
    activeLayers.value.splice(index, 1);
    mapStore.removeLayer(layerId);
  } else {
    activeLayers.value.push(layerId);
    mapStore.addLayer(layerId);
  }
};

const handleLayerClick = (feature: any) => {
  console.log("Clicked feature:", feature.properties);
  // 顯示詳細資訊彈窗
};
</script>
```

## 2. 後端 SQL 查詢範例

### A. 即時人流熱點查詢

```sql
-- 查詢類型: map_legend
-- 用於生成人流熱點的動態數據
SELECT
    l.location_id AS name,
    l.location_name AS name_display,
    'circle' AS type,
    CASE
        WHEN t.flow_intensity > 80 THEN 'high'
        WHEN t.flow_intensity > 50 THEN 'medium'
        ELSE 'low'
    END AS icon,
    t.current_flow AS value
FROM commercial_traffic_realtime t
JOIN commercial_locations l ON t.location_id = l.id
WHERE t.timestamp >= NOW() - INTERVAL '5 minutes'
ORDER BY t.current_flow DESC
LIMIT 50;
```

### B. 商圈人流統計查詢

```sql
-- 查詢類型: three_d
-- 用於生成商圈人流時段分布圖表
SELECT
    d.district_name AS x_axis,
    CASE
        WHEN EXTRACT(hour FROM t.timestamp) BETWEEN 8 AND 12 THEN '上午'
        WHEN EXTRACT(hour FROM t.timestamp) BETWEEN 12 AND 17 THEN '下午'
        WHEN EXTRACT(hour FROM t.timestamp) BETWEEN 17 AND 22 THEN '晚上'
        ELSE '深夜'
    END AS y_axis,
    SUM(t.visitor_count) AS data
FROM commercial_traffic_hourly t
JOIN commercial_districts d ON t.district_id = d.id
WHERE t.date BETWEEN '%s' AND '%s'
GROUP BY d.district_name, y_axis
ORDER BY
    ARRAY_POSITION(ARRAY['西門町', '信義區', '士林夜市', '東門永康']::varchar[], d.district_name),
    ARRAY_POSITION(ARRAY['上午', '下午', '晚上', '深夜']::varchar[], y_axis);
```

### C. 人流動線統計查詢

```sql
-- 查詢類型: time
-- 用於生成人流動線的時序變化
SELECT
    date_trunc('hour', f.timestamp) AS x_axis,
    f.route_name AS y_axis,
    AVG(f.flow_volume) AS data
FROM commercial_traffic_flows f
WHERE f.timestamp BETWEEN '%s' AND '%s'
    AND f.route_id IN ('mrt_to_ximending', 'xinyi_to_101', 'jiantan_to_shilin')
GROUP BY x_axis, y_axis
ORDER BY y_axis, x_axis;
```

## 3. 資料更新流程

### A. Airflow DAG 配置

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import requests
import json

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 6, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'commercial_district_data_pipeline',
    default_args=default_args,
    description='商圈人流數據更新管線',
    schedule_interval='*/10 * * * *',  # 每10分鐘執行一次
    catchup=False
)

def update_traffic_hotspots():
    """更新人流熱點數據"""
    # 從各數據源獲取即時數據
    mrt_data = fetch_mrt_passenger_data()
    youbike_data = fetch_youbike_usage_data()
    mobile_data = fetch_telecom_crowd_data()

    # 整合並轉換為 GeoJSON 格式
    hotspots = transform_to_hotspots(mrt_data, youbike_data, mobile_data)

    # 儲存到資料庫
    save_to_database(hotspots)

    # 更新前端地圖檔案
    update_geojson_file('traffic_hotspots.geojson', hotspots)

def update_traffic_flows():
    """更新人流動線數據"""
    # 分析起訖點數據
    od_data = analyze_origin_destination()

    # 生成動線 GeoJSON
    flows = generate_flow_arcs(od_data)

    # 更新檔案
    update_geojson_file('traffic_flows.geojson', flows)

# 定義任務
task_hotspots = PythonOperator(
    task_id='update_traffic_hotspots',
    python_callable=update_traffic_hotspots,
    dag=dag
)

task_flows = PythonOperator(
    task_id='update_traffic_flows',
    python_callable=update_traffic_flows,
    dag=dag
)

# 設定任務依賴
task_hotspots >> task_flows
```

## 4. 效能優化建議

### A. 地圖數據優化

1. **簡化幾何圖形**：使用 Turf.js 的 `simplify` 功能減少多邊形頂點
2. **分層載入**：根據縮放級別載入不同詳細程度的數據
3. **向量圖磚**：對於大量數據，考慮使用 Mapbox Vector Tiles

### B. 資料庫索引

```sql
-- 為地理查詢建立空間索引
CREATE INDEX idx_commercial_locations_geom ON commercial_locations USING GIST (geom);

-- 為時間查詢建立索引
CREATE INDEX idx_traffic_timestamp ON commercial_traffic_realtime (timestamp DESC);

-- 複合索引優化查詢
CREATE INDEX idx_traffic_district_time ON commercial_traffic_hourly (district_id, date);
```

### C. 前端快取策略

```typescript
// 使用 Pinia 進行狀態管理和快取
export const useCommercialMapStore = defineStore("commercialMap", () => {
  const mapDataCache = new Map();
  const cacheTimeout = 5 * 60 * 1000; // 5分鐘

  const fetchMapData = async (layerId: string) => {
    const cached = mapDataCache.get(layerId);
    if (cached && Date.now() - cached.timestamp < cacheTimeout) {
      return cached.data;
    }

    const data = await api.getMapData(layerId);
    mapDataCache.set(layerId, {
      data,
      timestamp: Date.now(),
    });

    return data;
  };

  return { fetchMapData };
});
```

## 5. 測試與部署

### A. 本地測試

```bash
# 1. 將 GeoJSON 檔案複製到前端專案
cp map-mockup-data/*.geojson Taipei-City-Dashboard-FE/public/mapData/

# 2. 啟動前端開發服務器
cd Taipei-City-Dashboard-FE
npm run dev

# 3. 測試地圖載入
# 訪問 http://localhost:3000/dashboard/commercial-district
```

### B. 資料驗證

```javascript
// 驗證 GeoJSON 格式
const validateGeoJSON = (data) => {
  if (!data.type || data.type !== "FeatureCollection") {
    throw new Error("Invalid GeoJSON: missing FeatureCollection");
  }

  data.features.forEach((feature) => {
    if (!feature.geometry || !feature.properties) {
      throw new Error("Invalid feature structure");
    }
  });

  return true;
};
```

## 6. 擴展功能建議

1. **即時更新**：使用 WebSocket 推送即時人流變化
2. **預測分析**：整合 AI 模型預測未來人流趨勢
3. **互動篩選**：允許用戶篩選特定時段、交通方式的數據
4. **3D 視覺化**：使用 `fill-extrusion` 類型展示建築物高度與人流密度的關係
5. **動態聚合**：根據縮放級別動態聚合熱點數據，避免視覺雜亂

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

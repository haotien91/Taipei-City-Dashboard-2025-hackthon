# 台北城市儀表板 - 前後端串接循序圖

## 商圈活化地圖功能完整交互流程

### 1. 系統初始化與地圖載入流程

```mermaid
sequenceDiagram
    participant User as 使用者
    participant FE as Vue 前端
    participant MapStore as Pinia MapStore
    participant ContentStore as Pinia ContentStore
    participant API as Go Backend API
    participant DB_Manager as dashboardmanager DB
    participant DB_Data as dashboard DB
    participant MapBox as Mapbox GL JS
    participant GeoJSON as GeoJSON Files

    User->>+FE: 訪問商圈活化頁面
    FE->>+MapStore: 初始化地圖狀態
    FE->>+ContentStore: 獲取組件配置

    ContentStore->>+API: GET /api/v1/components/:id/config
    API->>+DB_Manager: 查詢組件配置
    DB_Manager->>DB_Manager: SELECT * FROM components WHERE id = ?
    DB_Manager->>DB_Manager: SELECT * FROM component_maps WHERE component_id = ?
    DB_Manager-->>-API: 返回組件配置與地圖配置
    API-->>-ContentStore: 返回配置數據

    ContentStore->>+MapStore: 設定地圖配置
    MapStore->>+MapBox: 初始化地圖實例
    MapBox-->>-MapStore: 地圖初始化完成

    Note over FE,GeoJSON: 載入靜態地圖數據
    MapStore->>+GeoJSON: 載入商圈範圍數據
    GeoJSON-->>-MapStore: commercial-districts.geojson
    MapStore->>+GeoJSON: 載入人流熱點數據
    GeoJSON-->>-MapStore: traffic-hotspots.geojson
    MapStore->>+GeoJSON: 載入人流動線數據
    GeoJSON-->>-MapStore: traffic-flows.geojson

    MapStore->>MapBox: 添加數據源與圖層
    MapBox-->>FE: 地圖渲染完成
    FE-->>-User: 顯示基礎地圖
```

### 2. 動態數據載入與圖表渲染流程

```mermaid
sequenceDiagram
    participant User as 使用者
    participant FE as Vue 前端
    participant ContentStore as Pinia ContentStore
    participant API as Go Backend API
    participant DB_Data as dashboard DB
    participant Chart as ApexCharts

    User->>+FE: 查看商圈統計圖表
    FE->>+ContentStore: 請求圖表數據

    ContentStore->>+API: GET /api/v1/component/:id/chart?timefrom=&timeto=
    API->>+DB_Data: 執行 SQL 查詢

    Note over API,DB_Data: 根據 query_type 執行不同查詢
    alt query_type = "three_d"
        DB_Data->>DB_Data: 商圈人流時段分布查詢
        Note right of DB_Data: SELECT district_name AS x_axis,<br/>time_period AS y_axis,<br/>SUM(visitor_count) AS data<br/>FROM commercial_traffic_hourly<br/>WHERE date BETWEEN '%s' AND '%s'
    else query_type = "two_d"
        DB_Data->>DB_Data: 商圈排行查詢
        Note right of DB_Data: SELECT name AS x_axis,<br/>visitor_count AS data<br/>FROM commercial_districts<br/>ORDER BY visitor_count DESC
    else query_type = "time"
        DB_Data->>DB_Data: 時序趨勢查詢
        Note right of DB_Data: SELECT date_trunc('hour', timestamp) AS x_axis,<br/>location_name AS y_axis,<br/>AVG(flow_volume) AS data<br/>FROM traffic_flows<br/>WHERE timestamp BETWEEN '%s' AND '%s'
    end

    DB_Data-->>-API: 返回查詢結果
    API->>API: 根據 query_type 格式化數據
    API-->>-ContentStore: 返回格式化的圖表數據

    ContentStore->>+Chart: 渲染圖表
    Chart-->>-FE: 圖表渲染完成
    FE-->>-User: 顯示統計圖表
```

### 3. 即時數據更新流程

```mermaid
sequenceDiagram
    participant Airflow as Apache Airflow
    participant DataSource as 外部數據源
    participant ETL as ETL Pipeline
    participant DB_Data as dashboard DB
    participant API as Go Backend API
    participant FE as Vue 前端
    participant MapBox as Mapbox GL JS
    participant WS as WebSocket

    Note over Airflow: 每10分鐘執行一次
    Airflow->>+ETL: 觸發數據更新任務

    par 並行獲取多源數據
        ETL->>+DataSource: 獲取捷運人流數據
        DataSource-->>-ETL: TDX API 數據
    and
        ETL->>+DataSource: 獲取 YouBike 使用數據
        DataSource-->>-ETL: YouBike API 數據
    and
        ETL->>+DataSource: 獲取電信人流數據
        DataSource-->>-ETL: 電信基站數據
    end

    ETL->>ETL: 數據清洗與轉換
    ETL->>ETL: 生成人流熱點 GeoJSON
    ETL->>+DB_Data: 更新即時數據表
    DB_Data-->>-ETL: 更新完成

    ETL->>+API: 通知數據更新
    API->>+WS: 廣播更新事件
    WS->>+FE: 推送數據更新通知

    FE->>+API: GET /api/v1/component/:id/chart (獲取最新數據)
    API->>+DB_Data: 查詢最新數據
    DB_Data-->>-API: 返回最新數據
    API-->>-FE: 返回更新數據

    FE->>+MapBox: 更新地圖數據源
    MapBox-->>-FE: 地圖重新渲染

    ETL-->>-Airflow: 任務完成
```

### 4. 用戶交互與篩選流程

```mermaid
sequenceDiagram
    participant User as 使用者
    participant FE as Vue 前端
    participant MapStore as Pinia MapStore
    participant API as Go Backend API
    participant DB_Data as dashboard DB
    participant MapBox as Mapbox GL JS

    User->>+FE: 點擊商圈區域
    FE->>+MapBox: 獲取點擊要素
    MapBox-->>-FE: 返回要素屬性
    FE->>FE: 顯示詳細資訊彈窗
    FE-->>User: 顯示商圈詳細資訊

    User->>+FE: 調整時間範圍篩選器
    FE->>+MapStore: 更新篩選條件
    MapStore->>+API: GET /component/:id/chart?timefrom=NEW_START&timeto=NEW_END

    API->>+DB_Data: 執行帶時間篩選的查詢
    Note right of DB_Data: 使用 %s 占位符<br/>WHERE timestamp BETWEEN<br/>'2024-06-01 08:00:00' AND<br/>'2024-06-01 18:00:00'
    DB_Data-->>-API: 返回篩選後數據

    API-->>-MapStore: 返回更新數據
    MapStore->>+MapBox: 更新圖層樣式

    Note over MapBox: 動態更新顏色映射
    MapBox->>MapBox: 更新 fill-color 表達式
    MapBox->>MapBox: 更新 circle-radius 表達式
    MapBox-->>-FE: 地圖視覺更新完成

    FE-->>-User: 顯示篩選後的地圖
```

### 5. 圖層控制與視覺化切換流程

```mermaid
sequenceDiagram
    participant User as 使用者
    participant FE as Vue 前端
    participant LayerControl as 圖層控制組件
    participant MapStore as Pinia MapStore
    participant MapBox as Mapbox GL JS

    User->>+LayerControl: 切換圖層顯示
    LayerControl->>+MapStore: toggleLayer(layerId)

    alt 顯示圖層
        MapStore->>+MapBox: setLayoutProperty(layerId, 'visibility', 'visible')
        MapBox->>MapBox: 顯示對應圖層
        MapBox-->>-MapStore: 圖層顯示完成
    else 隱藏圖層
        MapStore->>+MapBox: setLayoutProperty(layerId, 'visibility', 'none')
        MapBox->>MapBox: 隱藏對應圖層
        MapBox-->>-MapStore: 圖層隱藏完成
    end

    MapStore-->>-LayerControl: 圖層狀態更新
    LayerControl-->>-User: UI 狀態同步

    User->>+LayerControl: 調整圖層透明度
    LayerControl->>+MapStore: setLayerOpacity(layerId, opacity)
    MapStore->>+MapBox: setPaintProperty(layerId, 'fill-opacity', opacity)
    MapBox-->>-MapStore: 透明度更新完成
    MapStore-->>-LayerControl: 透明度狀態更新
    LayerControl-->>-User: 滑桿位置同步
```

### 6. 錯誤處理與重試機制

```mermaid
sequenceDiagram
    participant FE as Vue 前端
    participant API as Go Backend API
    participant DB_Data as dashboard DB
    participant ErrorHandler as 錯誤處理器
    participant Logger as 日誌系統

    FE->>+API: GET /api/v1/component/:id/chart
    API->>+DB_Data: 執行 SQL 查詢

    alt 資料庫連接失敗
        DB_Data-->>-API: 連接錯誤
        API->>+ErrorHandler: 處理資料庫錯誤
        ErrorHandler->>+Logger: 記錄錯誤日誌
        Logger-->>-ErrorHandler: 日誌記錄完成
        ErrorHandler->>ErrorHandler: 執行重試機制 (最多3次)
        ErrorHandler-->>-API: 重試結果

        alt 重試成功
            API-->>FE: 返回數據
        else 重試失敗
            API-->>FE: HTTP 500 + 錯誤訊息
            FE->>FE: 顯示友善錯誤訊息
        end

    else SQL 語法錯誤
        DB_Data-->>-API: SQL 執行錯誤
        API->>+Logger: 記錄 SQL 錯誤
        Logger-->>-API: 記錄完成
        API-->>FE: HTTP 400 + 錯誤詳情
        FE->>FE: 顯示「數據載入失敗」

    else 正常執行
        DB_Data-->>-API: 返回查詢結果
        API-->>-FE: HTTP 200 + 數據
    end
```

## 關鍵技術要點

### 1. 數據流架構

- **靜態數據**：GeoJSON 檔案，用於基礎地理圖形
- **動態數據**：透過 API 獲取，支援時間篩選
- **即時數據**：WebSocket 推送，10 分鐘更新週期

### 2. SQL 查詢類型對應

- `two_d`: 二維圖表 (排行榜、分布圖)
- `three_d`: 三維圖表 (熱力圖、分類統計)
- `time`: 時序圖表 (趨勢分析)
- `percent`: 百分比圖表 (佔比分析)
- `map_legend`: 地圖圖例數據

### 3. 效能優化策略

- **前端快取**: Pinia store 5 分鐘快取
- **資料庫索引**: 地理空間索引 + 時間索引
- **分層載入**: 根據縮放級別載入不同精度數據

### 4. 錯誤處理機制

- **自動重試**: 最多 3 次重試
- **友善提示**: 使用者友好的錯誤訊息
- **日誌記錄**: 完整的錯誤追蹤

### 5. 安全性考量

- **SQL 注入防護**: 使用參數化查詢
- **API 認證**: JWT Token 驗證
- **CORS 設定**: 限制跨域請求來源

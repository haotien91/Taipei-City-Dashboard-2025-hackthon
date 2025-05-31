# 商圈活化儀表板部署指南

## 📋 概述

本文件詳細說明如何在台北城市儀表板系統中部署「商圈活化」功能模組。

### 🎯 功能特色

- **商圈人流分析**: 即時監控商圈人流變化
- **數據視覺化**: 多種圖表類型展示 (柱狀圖、線圖、熱力圖)
- **決策支援**: 協助商家和政府進行商圈規劃決策

---

## 🚀 自動化部署（推薦）

### 先決條件

1. Docker 和 Docker Compose 已安裝並運行
2. 台北城市儀表板基礎環境已啟動

### 一鍵部署

```bash
# 1. 給予腳本執行權限
chmod +x scripts/setup-commercial-district.sh

# 2. 執行自動化部署
./scripts/setup-commercial-district.sh
./scripts/setup-commercial-district-metrotaipei.sh
./scripts/setup-commercial-district-with-data.sh
```

**就這麼簡單！** 腳本會自動：

- ✅ 檢查環境狀態
- ✅ 部署儀表板配置
- ✅ 驗證部署結果
- ✅ 重啟相關服務
- ✅ 提供結果回饋

---

## 🔧 手動部署

### 步驟 1: 檢查環境

```bash
# 確認必要容器正在運行
docker ps | grep postgres-manager
docker ps | grep dashboard-be
```

### 步驟 2: 部署儀表板配置

```bash
# 執行商圈活化初始化
docker-compose -f docker/docker-compose-commercial-district.yaml up
```

### 步驟 3: 驗證部署

```bash
# 檢查儀表板是否創建成功
docker exec postgres-manager psql -U postgres -d dashboardmanager -c \
  "SELECT id, index, name, components FROM dashboards WHERE index = 'commercial_district';"

# 檢查組件是否創建成功
docker exec postgres-manager psql -U postgres -d dashboardmanager -c \
  "SELECT id, index, name FROM components WHERE index = 'commercial_district_flow';"
```

### 步驟 4: 重啟後端服務

```bash
# 重啟後端以載入新配置
docker restart dashboard-be
```

---

## 📁 文件說明

### 新增文件

```
├── db-sample-data/
│   └── commercial-district-init.sql     # 商圈活化資料庫初始化腳本
├── docker/
│   └── docker-compose-commercial-district.yaml  # 部署配置
├── scripts/
│   └── setup-commercial-district.sh     # 自動化部署腳本
└── docs/
    └── COMMERCIAL-DISTRICT-DEPLOYMENT.md  # 本說明文件
```

### 文件詳解

#### `commercial-district-init.sql`

- **用途**: 資料庫初始化腳本
- **內容**:
  - 儀表板基本配置 (名稱、圖標、權限等)
  - 組件定義 (商圈人流分析)
  - 圖表配置 (顏色、類型、單位)
  - 查詢配置 (SQL、更新頻率等)
  - 自動關聯設置

#### `docker-compose-commercial-district.yaml`

- **用途**: Docker Compose 部署配置
- **特點**:
  - 連接正確的管理資料庫 (`postgres-manager`)
  - 使用正確的資料庫名稱 (`dashboardmanager`)
  - 自動載入初始化腳本

#### `setup-commercial-district.sh`

- **用途**: 一鍵自動化部署腳本
- **功能**:
  - 環境檢查與驗證
  - 自動執行部署流程
  - 結果驗證與錯誤處理
  - 彩色輸出與進度提示

---

## 🌐 使用方式

### 查看儀表板

1. 開啟瀏覽器前往 `http://localhost`
2. 登入系統 (需要有 taipei 群組權限)
3. 在左側選單找到「**臺北儀表板**」區塊
4. 點擊「**商圈活化**」儀表板

### 權限設置

- **目標群組**: `taipei`
- **必要權限**: viewer 以上
- **管理權限**: admin 或 editor

---

## 🔍 故障排除

### 常見問題

#### 1. 看不到儀表板

**可能原因**:

- 權限不足 (不在 taipei 群組)
- 前端快取未更新

**解決方法**:

```bash
# 強制刷新瀏覽器
Ctrl + Shift + R (Windows/Linux)
Cmd + Shift + R (Mac)

# 或重啟前端服務
docker restart dashboard-fe
```

#### 2. 部署失敗

**檢查步驟**:

```bash
# 1. 檢查 Docker 狀態
docker info

# 2. 檢查必要容器
docker ps | grep postgres-manager

# 3. 查看詳細錯誤
docker logs dashboard-be-init-commercial
```

#### 3. 資料庫連接錯誤

**常見錯誤**: `database "dashboard" does not exist`

**解決方法**: 確認使用正確的資料庫名稱 `dashboardmanager`

### 重新部署

如果需要重新部署：

```bash
# 1. 清理舊配置 (可選)
docker exec postgres-manager psql -U postgres -d dashboardmanager -c \
  "DELETE FROM dashboards WHERE index = 'commercial_district';"

# 2. 重新執行部署
./scripts/setup-commercial-district.sh
```

---

## 🤝 團隊協作

### 新成員快速上手

1. **Clone 專案** 並切換到最新分支
2. **啟動基礎環境**:
   ```bash
   docker-compose -f docker/docker-compose-db.yaml up -d
   docker-compose -f docker/docker-compose-init.yaml up
   docker-compose -f docker/docker-compose.yaml up -d
   ```
3. **部署商圈活化模組**:
   ```bash
   ./scripts/setup-commercial-district.sh
   ```

### 開發環境同步

- 所有配置已版本控制
- 一鍵腳本確保環境一致性
- 詳細日誌便於問題追蹤

---

## 📈 擴展計劃

### 後續功能

- [ ] 商圈營收分析
- [ ] 店家分布地圖
- [ ] 競爭對手分析
- [ ] 客戶滿意度調查
- [ ] 活動效果評估

### 技術改進

- [ ] 即時數據源整合
- [ ] 機器學習預測模型
- [ ] 多維度數據分析
- [ ] 移動端適配

# 📁 Scripts 目錄說明

> 台北城市儀表板 2025 Hackathon - 商圈活化永久化解決方案

## 🎯 概述

本目錄包含商圈活化功能的**核心腳本和文檔**。經過2025/06/01的大規模清理，我們將20+個腳本精簡為6個核心文件，專注於永久化解決方案。

## 📋 核心文件列表

### 🔧 永久化解決方案腳本

| 文件名 | 功能 | 使用頻率 |
|--------|------|----------|
| `create-permanent-init.sh` | 生成包含商圈活化配置的永久初始化文件 | 低 (配置變更時) |
| `switch-to-permanent-init.sh` | 自動切換環境變數到永久配置 | 低 (一次性設定) |
| `test-permanent-solution.sh` | 測試永久化解決方案的有效性 | 中 (驗證用) |

### 📖 文檔和工具

| 文件名 | 功能 | 使用頻率 |
|--------|------|----------|
| `商圈活化永久化解決方案.md` | 完整解決方案說明文檔 | 高 (參考用) |
| `cleanup-unused-files.sh` | 清理不需要的舊腳本和SQL文件 | 低 (維護用) |
| `modules/create-component.sh` | 通用組件創建工具 | 低 (開發用) |

## 🚀 快速開始

### ✅ 正常情況（推薦）
系統已配置完成，**不需要執行任何腳本**！

1. 直接訪問 `http://localhost`
2. 登入後即可看到商圈活化功能
3. 所有圖表和動態地圖都會自動載入

### 🔧 特殊情況處理

**情況1: 首次設置或環境變數丟失**
```bash
./scripts/switch-to-permanent-init.sh
```

**情況2: 驗證配置是否正確**
```bash
./scripts/test-permanent-solution.sh
```

**情況3: 配置有更新需要重新生成**
```bash
./scripts/create-permanent-init.sh
```

**情況4: 系統維護清理**
```bash
./scripts/cleanup-unused-files.sh
```

## 📊 已整合功能

✅ **商圈活化儀表板**
- 市集活動分佈
- 台北商圈心理測驗 ⭐
- 雙北市集活動分佈 ⭐
- 雙北商圈排行榜

✅ **動態地圖功能**  
- 🔵 Blue: 尚未開始的市集活動 (39個)
- 🟢 Green: 進行中的市集活動 (18個)  
- 🔴 Red: 即將結束的市集活動 (2個)

✅ **系統特性**
- 自動載入配置
- 跨城市支援 (台北+雙北)
- 即時狀態計算
- 永久化配置

## 🗑️ 已清理的過時文件

### 🗂️ 清理統計 (2025/06/01)

| 類別 | 清理前 | 清理後 | 減少 |
|------|--------|--------|------|
| 📁 Scripts | 20個文件 | 6個文件 | **-70%** |
| 📄 SQL文件 | 13個文件 | 3個文件 | **-77%** |
| 🐳 Docker Compose | 7個文件 | 3個文件 | **-57%** |

### 🗑️ 已移除的過時腳本
- `setup-quiz-component.sh` (心理測驗組件設置 - 已整合)
- `setup-commercial-district*.sh` (商圈設置腳本 - 已整合)
- `setup-market-map*.sh` (市集地圖設置 - 已整合)
- `restore-dynamic-map-config.sh` (動態地圖恢復 - 已整合)
- 動態地圖功能使用指南 (已整合到解決方案文檔)

### 🗑️ 已移除的過時 SQL 文件
- `quiz-component-init.sql` (已整合到 permanent.sql)
- `commercial-district-*.sql` (已整合到 permanent.sql)
- `market-events-*-init.sql` (已整合到 permanent.sql)

### 🗑️ 已移除的過時 Docker Compose 文件
- `docker-compose-quiz-component.yaml`
- `docker-compose-commercial-district*.yaml`
- `docker-compose-market-map.yaml`

## 🔄 故障排除

### ❓ 常見問題

**Q: 看不到商圈活化功能？**
A: 檢查環境變數設定：
```bash
cat .env | grep MANAGER_SAMPLE_FILE
# 應該顯示: MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql
```

**Q: 在其他機器上部署時出現找不到文件錯誤？**
A: 確保使用最新的永久化配置：
```bash
# 檢查是否有完整的永久配置文件
ls -la db-sample-data/dashboardmanager-permanent.sql

# 如果沒有，重新生成
./scripts/create-permanent-init.sh
```

**Q: 動態地圖顏色不正確？**
A: 重新初始化系統：
```bash
docker-compose down
docker-compose up -d
```

## 📞 支援

如有任何問題，請參考：
1. `商圈活化永久化解決方案.md` - 完整文檔
2. 執行 `./scripts/test-permanent-solution.sh` - 自動診斷
3. 檢查 Docker 容器日誌 
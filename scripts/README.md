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
./switch-to-permanent-init.sh
```

**情況2: 驗證配置是否正確**
```bash
./test-permanent-solution.sh
```

**情況3: 重新生成永久配置**
```bash
./create-permanent-init.sh
./switch-to-permanent-init.sh
```

## 🗂️ 目錄結構

```
scripts/
├── 📖 README.md                          # 本說明文檔
├── 🔧 create-permanent-init.sh           # 生成永久配置
├── ⚙️ switch-to-permanent-init.sh        # 環境變數切換
├── 🧪 test-permanent-solution.sh         # 測試腳本
├── 📚 商圈活化永久化解決方案.md           # 完整文檔
├── 🧹 cleanup-unused-files.sh            # 清理工具
└── modules/
    └── 🛠️ create-component.sh            # 組件創建工具
```

## 📊 商圈活化功能

### 台北版本
- 📊 儀表板: "商圈活化"
- 🧩 組件: 商圈人流分析、市集活動分佈
- 🗺️ 動態地圖: 彩色市集活動狀態顯示

### 雙北版本
- 📊 儀表板: "雙北儀表板示範" → "商圈活化"
- 🧩 組件: 雙北商圈人流分析、雙北市集活動分佈
- 🗺️ 動態地圖: 雙北市集活動狀態顯示

### 動態顏色系統
- 🔵 藍色: 尚未開始 (39個活動)
- 🟢 綠色: 進行中 (18個活動)
- 🔴 紅色: 即將結束 (2個活動)

## 🆘 問題排查

### Q: 看不到商圈活化選項？
A: 執行 `./test-permanent-solution.sh` 檢查配置

### Q: 地圖沒有顏色變化？
A: 檢查動態地圖功能是否正常載入

### Q: 需要恢復舊版腳本？
A: 查看 `cleanup-backup-*` 目錄中的備份文件

### Q: 想了解技術細節？
A: 閱讀 `商圈活化永久化解決方案.md`

## 📞 支援資訊

- 📖 **完整文檔**: `商圈活化永久化解決方案.md`
- 🧪 **測試工具**: `test-permanent-solution.sh`
- 🗄️ **備份位置**: `cleanup-backup-*` 目錄
- 🔧 **環境設定**: `.env` 文件中的 `MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql`

---

> 🎉 **永久化解決方案已完成！**  
> 系統現在會自動載入商圈活化功能，無需手動執行腳本。 
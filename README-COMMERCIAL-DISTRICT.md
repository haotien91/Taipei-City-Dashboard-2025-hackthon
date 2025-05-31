# 🏪 商圈活化模組 - 快速部署指南

> 💡 **一鍵部署商圈活化儀表板到台北城市儀表板系統**

## 🚀 快速開始

```bash
# 1. 確保基礎環境運行
docker-compose -f docker/docker-compose-db.yaml up -d
docker-compose -f docker/docker-compose.yaml up -d

# 2. 一鍵部署商圈活化模組
./scripts/setup-commercial-district.sh
```

## 📋 檢查結果

1. 開啟 http://localhost
2. 登入系統
3. 在「臺北儀表板」找到「商圈活化」
4. 如看不到請強制刷新 (Ctrl+Shift+R)

## 📁 相關文件

- **詳細部署指南**: `docs/COMMERCIAL-DISTRICT-DEPLOYMENT.md`
- **自動化腳本**: `scripts/setup-commercial-district.sh`
- **資料庫配置**: `db-sample-data/commercial-district-init.sql`
- **Docker 配置**: `docker/docker-compose-commercial-district.yaml`

## 🔧 故障排除

```bash
# 檢查容器狀態
docker ps

# 查看後端日誌
docker logs dashboard-be

# 重新部署
./scripts/setup-commercial-district.sh
```

## 💪 功能特色

- ✅ **商圈人流分析**: 即時監控人流變化
- ✅ **視覺化圖表**: 柱狀圖、線圖、熱力圖
- ✅ **決策支援**: 商圈規劃與營運分析
- ✅ **權限管理**: taipei 群組專用
- ✅ **一鍵部署**: 完全自動化

---

_需要協助？查看詳細文件: `docs/COMMERCIAL-DISTRICT-DEPLOYMENT.md`_

---
trigger: always_on
description: when you need the retrieve project information
---

# 台北城市儀表板 2025 Hackathon - 完整開發指南

## 🎯 專案概述 (Project Overview)

### 什麼是台北城市儀表板？

台北城市儀表板是一個**現代化的城市資料視覺化平台**，整合政府開放資料、即時感測器數據、地理資訊系統(GIS)等多元資料源，提供互動式的視覺化儀表板介面，讓市民與政府單位能夠即時掌握城市各項指標。

### 系統架構

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   前端 (FE)      │    │   後端 (BE)      │    │ 資料工程 (DE)     │
│ Vue 3 + TypeScript │◄──►│ Go + Gin Framework │◄──►│ Apache Airflow   │
│ Mapbox + Deck.gl   │    │ PostgreSQL + Redis │    │ ETL Pipelines    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🏗️ 技術架構詳解

### 前端技術堆疊 (Frontend Stack)

```yaml
核心框架:
  - Vue 3.4+ (Composition API + <script setup>)
  - TypeScript 5.x (嚴格模式)
  - Vite 5.x (構建工具)

狀態管理:
  - Pinia (現代 Vue 狀態管理)
  - Vue Router 4 (SPA 路由)

視覺化與地圖:
  - Mapbox GL JS 3.x (地圖引擎)
  - Deck.gl 8.x (3D 數據可視化)
  - ApexCharts 3.x (圖表庫)
  - Three.js + Threebox (3D 場景)
  - Turf.js (地理空間分析)

樣式與 UI:
  - SCSS (CSS 預處理器)
  - Material Icons
  - 響應式設計 (RWD)

開發工具:
  - ESLint + Prettier (程式碼品質)
  - Vite HMR (熱更新)
  - Vitest (單元測試)
```

### 後端技術堆疊 (Backend Stack)

```yaml
核心框架:
  - Go 1.21.3+ (高性能 Web 服務)
  - Gin Framework 1.9+ (輕量級 HTTP 框架)

資料庫與快取:
  - PostgreSQL 15+ (主資料庫)
  - PostGIS (地理空間擴展)
  - Redis 7+ (快取與 Session)

ORM 與驗證:
  - GORM v2 (Go ORM)
  - JWT (身份驗證)
  - CORS 支援

部署與工具:
  - Docker (容器化)
  - Cobra CLI (命令列工具)
  - Google Cloud Build
```

## Reference

### [競賽規則.md](mdc:Reference-for-AI/Hackthon/競賽規則.md)

這是這場 Hackthon 比賽的競賽規則

### [0526-discussion.md](mdc:Reference-for-AI/Hackthon/0526-discussion.md)

這是我們在 05/26 時討論的結果，包含想法初步發想、初步的執行方案。

### [0531-brainstorm.md](mdc:Reference-for-AI/Hackthon/0531-brainstorm.md)

這是我們在比賽第一天，針對題目 "商圈活化" 做的 brainstorm 資訊，由 GPT 整理過。

### [0531-deep-research.md](mdc:Reference-for-AI/Hackthon/0531-deep-research.md)

同上，這是由 Deep Research 深挖後的資料

### [UI-development-reference.md](mdc:Reference-for-AI/Hackthon/UI-development-reference.md)

這是 UI 設計的最高指導原則，說明了哪些 UI 會被大家喜歡

### @Reference-for-AI/Docs/\*

這些是專案的實作 Document, 分為 BE (backend), DE, (data-end), FE(front-end) 三個主要區塊，以及 Common (專案基本介紹)

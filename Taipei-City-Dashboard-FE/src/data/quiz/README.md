# 台北商圈心理測驗 - 數據檔案說明

## 📁 檔案結構概覽

```
src/data/quiz/
├── 📄 questions.json          # 測驗問題決策樹
├── 📄 results.json            # 結果與商圈推薦
├── 📄 district-details.json   # 商圈詳細介紹
├── 📄 quiz-config.json        # 測驗配置設定
└── 📄 README.md              # 本說明文檔
```

## 📋 檔案詳細說明

### 1. questions.json - 測驗問題樹

包含完整的 4 層決策樹結構，總共 12 種結果路徑。

**結構**:

-   `questions`: 問題物件，每個問題包含選項和導向
-   `pathMapping`: 路徑映射，將答案路徑對應到結果代碼

**決策路徑示例**:

```
Q1: 時段 (白天/夜晚)
└── Q2: 活動類型 (購物/文化/自然/美食/夜生活/散步)
    └── Q3: 具體偏好 (高端/平價/古蹟/文青/溫泉/茶/觀光/在地/日系/潮流/懷舊/現代)
        └── 結果: H/L/O/N/S/T/M/P/J/K/R/Q
```

### 2. results.json - 結果與評價

包含 12 種人格類型的完整資料。

**每個結果包含**:

-   `title`: 人格類型標題 (如 "質感生活家")
-   `userEvaluation`: 對用戶的性格分析
    -   `personality`: 性格描述
    -   `traits`: 特質標籤陣列
    -   `description`: 詳細性格說明
-   `tagline`: 吸引人的一句話標語
-   `districts`: 1-3 個推薦商圈
    -   每個商圈包含：id、名稱、圖片、描述、亮點

**12 種結果類型**:

-   **H**: 質感生活家 (高端購物)
-   **L**: 精明消費達人 (平價挖寶)
-   **O**: 文化探索者 (百年古蹟)
-   **N**: 文青生活家 (創意文化)
-   **S**: 療癒系旅人 (溫泉放鬆)
-   **T**: 山景品茗師 (自然品茶)
-   **M**: 美食獵人 (觀光夜市)
-   **P**: 在地美食通 (在地小吃)
-   **J**: 和風夜遊者 (日式居酒)
-   **K**: 夜生活玩家 (潮流酒吧)
-   **R**: 懷舊漫步者 (老城夜遊)
-   **Q**: 都會浪漫主義者 (現代約會)

### 3. district-details.json - 詳細介紹

點擊商圈圖片後顯示的完整資訊。

**包含資訊**:

-   `fullDescription`: 商圈完整介紹
-   `detailImages`: 多張詳細圖片
-   `keyFeatures`: 主要特色與遊玩提示
-   `transportation`: 交通資訊 (捷運、公車、停車)
-   `visitTips`: 實用遊玩建議
-   `averageBudget`: 預算建議
-   `bestTime`: 最佳造訪時間

**目前包含的商圈**:

-   信義商圈 (xinyi)
-   五分埔商圈 (wufenpu)
-   士林夜市 (shilin)
-   迪化街商圈 (dihua)
-   新北投溫泉區 (beitou)

### 4. quiz-config.json - 配置設定

測驗的各種設定和功能開關。

**主要配置區塊**:

-   `basic`: 基本資訊 (標題、描述等)
-   `analytics`: 分析追蹤設定
-   `ui`: 介面主題與動畫設定
-   `features`: 功能開關 (分享、重測等)
-   `integration`: 第三方整合 (地圖、社群分享)
-   `content`: 各畫面的內容設定
-   `texts`: 所有文字內容
-   `accessibility`: 無障礙設定
-   `performance`: 效能優化設定

## 🔧 使用方法

### 1. 在 Vue 組件中載入資料

```typescript
// composables/useQuizData.ts
import questionsData from "@/data/quiz/questions.json";
import resultsData from "@/data/quiz/results.json";
import detailsData from "@/data/quiz/district-details.json";
import configData from "@/data/quiz/quiz-config.json";

export function useQuizData() {
	const questions = ref(questionsData.questions);
	const results = ref(resultsData.results);
	const details = ref(detailsData.details);
	const config = ref(configData.config);

	return { questions, results, details, config };
}
```

### 2. 計算測驗結果

```typescript
// 根據用戶答案計算結果
function calculateResult(answers: string[]): string {
	const pathKey = answers.join("->");
	return questionsData.pathMapping[pathKey] || "H";
}

// 取得結果詳細資訊
function getResultData(resultCode: string) {
	return resultsData.results[resultCode];
}
```

### 3. 顯示商圈詳細資訊

```typescript
// 點擊商圈卡片時顯示詳細資訊
function showDistrictDetail(districtId: string) {
	const detail = detailsData.details[districtId];
	if (detail) {
		// 開啟詳細資訊 modal 或頁面
		showModal(detail);
	}
}
```

## 🎨 圖片路徑規範

### 結果頁圖片

-   路徑格式: `/images/results/{district-id}-cover.jpg`
-   建議尺寸: 400x300px
-   格式: JPG/WebP

### 詳細頁圖片

-   路徑格式: `/images/details/{district-id}-{type}.jpg`
-   建議尺寸: 600x400px
-   類型: street, shops, food, night 等

### 範例圖片路徑

```
/images/results/
├── xinyi-cover.jpg
├── wufenpu-cover.jpg
├── shilin-cover.jpg
└── ...

/images/details/
├── xinyi-101-view.jpg
├── xinyi-shopping.jpg
├── wufenpu-street.jpg
└── ...
```

## 🔄 擴展指南

### 添加新商圈

1. 在 `results.json` 中的對應結果添加新商圈
2. 在 `district-details.json` 中添加詳細資訊
3. 準備對應的圖片檔案

### 修改問題

1. 編輯 `questions.json` 中的問題內容
2. 更新 `pathMapping` 確保路徑正確
3. 測試所有路徑都能導向正確結果

### 自訂主題

1. 修改 `quiz-config.json` 中的 `ui.theme` 設定
2. 調整顏色、動畫效果等視覺元素

### 添加新功能

1. 在 `quiz-config.json` 的 `features` 區塊添加開關
2. 在組件中讀取配置並實作功能

## 📊 資料驗證

建議在載入資料時進行基本驗證：

```typescript
function validateQuizData() {
	// 檢查問題路徑完整性
	const questions = questionsData.questions;
	const pathMapping = questionsData.pathMapping;

	// 驗證所有路徑都有對應結果
	Object.values(pathMapping).forEach((resultCode) => {
		if (!resultsData.results[resultCode]) {
			console.error(`Missing result data for code: ${resultCode}`);
		}
	});

	// 檢查圖片路徑
	Object.values(resultsData.results).forEach((result) => {
		result.districts.forEach((district) => {
			if (!district.image) {
				console.warn(`Missing image for district: ${district.id}`);
			}
		});
	});
}
```

## 🚀 部署注意事項

1. **圖片優化**: 確保所有圖片都經過壓縮優化
2. **JSON 檔案**: 建議在 build 時進行 minify
3. **快取策略**: 設定適當的 HTTP 快取標頭
4. **CDN**: 考慮將圖片放到 CDN 以提升載入速度

---

**版本**: 1.0
**最後更新**: 2024-06-01
**作者**: 台北城市儀表板團隊

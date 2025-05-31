import { ref, computed } from "vue";
import { getDistrictById } from "../data/districts.js";

/**
 * 台北商圈心理測驗 composable - 3.0版本
 * 基於 OOOPEN Lab 設計方法重新設計
 * @returns {Object} 測驗相關的狀態和方法
 */
export function useQuiz() {
	// 重新設計的自然化問題數據 - 基於台北商圈特色
	const naturalQuestions = [
		{
			id: 1,
			text: "假日出門，你最期待的是什麼時光？",
			subtitle: "選擇最吸引你的生活節奏",
			options: [
				{
					id: "day",
					text: "陽光午後慢逛",
					emoji: "☀️",
					description: "我喜歡在溫暖的陽光下，悠閒地探索街頭巷尾",
					score: { timePreference: "day" },
				},
				{
					id: "night",
					text: "燈火璀璨夜生活",
					emoji: "🌃",
					description: "我享受夜晚的熱鬧氛圍，在燈光中尋找城市的魅力",
					score: { timePreference: "night" },
				},
			],
		},
		{
			id: 2,
			text: "白天逛街時，你最想體驗什麼？",
			subtitle: "陽光下的台北探索",
			condition: { timePreference: "day" },
			options: [
				{
					id: "shopping",
					text: "精品購物體驗",
					emoji: "🛍️",
					description: "我想在有格調的商圈挑選心儀的商品",
					score: { activity: "shopping" },
				},
				{
					id: "culture",
					text: "文化古蹟漫步",
					emoji: "🏛️",
					description: "我想感受台北的歷史文化，在老街中尋找故事",
					score: { activity: "culture" },
				},
				{
					id: "relax",
					text: "療癒休閒時光",
					emoji: "🌿",
					description: "我想要放鬆身心，享受寧靜悠閒的時光",
					score: { activity: "relax" },
				},
			],
		},
		{
			id: "2b",
			text: "夜晚出沒，你最渴望什麼體驗？",
			subtitle: "夜貓子的台北冒險",
			condition: { timePreference: "night" },
			options: [
				{
					id: "food",
					text: "美食探險之旅",
					emoji: "🍜",
					description: "我想品嚐各種道地美味，從夜市到餐廳都不放過",
					score: { activity: "food" },
				},
				{
					id: "nightlife",
					text: "都會夜生活",
					emoji: "🍸",
					description: "我想體驗台北的夜間文化，感受都市的不夜城魅力",
					score: { activity: "nightlife" },
				},
			],
		},
		{
			id: 3,
			text: "購物時，你的消費哲學是？",
			subtitle: "反映你的生活品味",
			condition: { activity: "shopping" },
			options: [
				{
					id: "premium",
					text: "質感優先主義",
					emoji: "💎",
					description: "我重視品質與服務，願意為美好的體驗投資",
					score: { budget: "high", style: "premium" },
				},
				{
					id: "smart",
					text: "聰明消費達人",
					emoji: "🎯",
					description: "我善於挖掘高CP值好物，追求物超所值的驚喜",
					score: { budget: "low", style: "practical" },
				},
			],
		},
		{
			id: "3b",
			text: "購物環境對你來說最重要的是？",
			subtitle: "你理想的購物氛圍",
			condition: { activity: "shopping", style: "premium" },
			options: [
				{
					id: "international",
					text: "國際化氛圍",
					emoji: "🌍",
					description: "我喜歡有異國風情的購物環境，感受多元文化",
					score: { atmosphere: "international" },
				},
				{
					id: "trendy",
					text: "時尚潮流感",
					emoji: "✨",
					description: "我追求最新的流行趨勢，喜歡走在時尚前端",
					score: { atmosphere: "trendy" },
				},
			],
		},
		{
			id: "3c",
			text: "在平價商圈，你最享受什麼？",
			subtitle: "挖寶的樂趣所在",
			condition: { activity: "shopping", style: "practical" },
			options: [
				{
					id: "wholesale",
					text: "批發市場尋寶",
					emoji: "📦",
					description: "我喜歡在批發商圈挖掘獨特商品，享受淘寶的驚喜",
					score: { shoppingStyle: "wholesale" },
				},
				{
					id: "vintage",
					text: "復古特色小店",
					emoji: "🏮",
					description:
						"我偏愛有歷史感的商圈，尋找獨一無二的vintage好物",
					score: { shoppingStyle: "vintage" },
				},
			],
		},
		{
			id: 4,
			text: "探索文化古蹟時，你偏愛什麼氛圍？",
			subtitle: "感受台北的時空魅力",
			condition: { activity: "culture" },
			options: [
				{
					id: "traditional",
					text: "古早味傳統",
					emoji: "🏮",
					description: "我喜歡傳統市場的人情味，感受最道地的台北風情",
					score: { cultureStyle: "traditional", atmosphere: "local" },
				},
				{
					id: "historic",
					text: "日式復古風",
					emoji: "⛩️",
					description: "我被日治時期的建築吸引，享受懷舊復古的情調",
					score: {
						cultureStyle: "historic",
						atmosphere: "nostalgic",
					},
				},
			],
		},
		{
			id: "4b",
			text: "在傳統商圈，你最想體驗什麼？",
			subtitle: "深度文化探索",
			condition: { activity: "culture", cultureStyle: "traditional" },
			options: [
				{
					id: "market",
					text: "傳統市場人情味",
					emoji: "🥟",
					description: "我想感受傳統市場的熱鬧，品嚐道地小吃與人情味",
					score: { focus: "market" },
				},
				{
					id: "temple",
					text: "廟宇文化巡禮",
					emoji: "🏯",
					description: "我想探訪古老廟宇，了解台北的宗教文化底蘊",
					score: { focus: "temple" },
				},
			],
		},
		{
			id: "4c",
			text: "日式復古風情中，你最著迷於？",
			subtitle: "昔日時光的魅力",
			condition: { activity: "culture", cultureStyle: "historic" },
			options: [
				{
					id: "architecture",
					text: "歷史建築之美",
					emoji: "🏛️",
					description:
						"我被老建築的建築美學深深吸引，喜歡細賞每個細節",
					score: { focus: "architecture" },
				},
				{
					id: "lifestyle",
					text: "復古生活風格",
					emoji: "🎎",
					description: "我想體驗昔日的生活方式，感受那個時代的浪漫",
					score: { focus: "lifestyle" },
				},
			],
		},
		{
			id: 5,
			text: "休閒放鬆時，你最需要什麼？",
			subtitle: "找到你的療癒方式",
			condition: { activity: "relax" },
			options: [
				{
					id: "nature",
					text: "自然溫泉療癒",
					emoji: "♨️",
					description: "我想要泡溫泉放鬆，在自然環境中釋放壓力",
					score: { relaxStyle: "hotspring", atmosphere: "nature" },
				},
				{
					id: "urban",
					text: "都會咖啡時光",
					emoji: "☕",
					description: "我喜歡在城市中找個安靜角落，享受咖啡和書香",
					score: { relaxStyle: "cafe", atmosphere: "urban" },
				},
			],
		},
		{
			id: "5b",
			text: "泡溫泉時，你偏好哪種環境？",
			subtitle: "溫泉療癒的理想選擇",
			condition: { activity: "relax", relaxStyle: "hotspring" },
			options: [
				{
					id: "resort",
					text: "度假村氛圍",
					emoji: "🏨",
					description:
						"我喜歡完整的溫泉度假體驗，享受全方位的放鬆服務",
					score: { hotelStyle: "resort" },
				},
				{
					id: "mountain",
					text: "山林野趣",
					emoji: "🏔️",
					description:
						"我偏愛隱身山間的溫泉，在自然環境中找到內心平靜",
					score: { hotelStyle: "mountain" },
				},
			],
		},
		{
			id: "5c",
			text: "都會咖啡時光，你最重視什麼？",
			subtitle: "城市中的寧靜片刻",
			condition: { activity: "relax", relaxStyle: "cafe" },
			options: [
				{
					id: "bookstore",
					text: "書香咖啡文化",
					emoji: "📚",
					description:
						"我想在書店咖啡館中品味知性時光，享受閱讀的樂趣",
					score: { cafeStyle: "bookstore" },
				},
				{
					id: "design",
					text: "設計美學空間",
					emoji: "🎨",
					description: "我被有設計感的咖啡廳吸引，欣賞空間美學與創意",
					score: { cafeStyle: "design" },
				},
			],
		},
		{
			id: 6,
			text: "美食探索時，你是哪種類型？",
			subtitle: "發現你的味蕾偏好",
			condition: { activity: "food" },
			options: [
				{
					id: "famous",
					text: "知名美食獵人",
					emoji: "📸",
					description: "我喜歡朝聖知名夜市，品嚐經典必吃小吃",
					score: { foodStyle: "famous", crowd: "popular" },
				},
				{
					id: "hidden",
					text: "巷弄秘境探索者",
					emoji: "🔍",
					description:
						"我偏愛尋找隱藏版美食，享受在地人才知道的好味道",
					score: { foodStyle: "hidden", crowd: "local" },
				},
			],
		},
		{
			id: "6b",
			text: "在知名夜市，你最期待什麼體驗？",
			subtitle: "夜市文化的精髓",
			condition: { activity: "food", foodStyle: "famous" },
			options: [
				{
					id: "classic",
					text: "經典必吃清單",
					emoji: "🏆",
					description: "我想按圖索驥品嚐所有經典小吃，不錯過任何名店",
					score: { foodFocus: "classic" },
				},
				{
					id: "atmosphere",
					text: "夜市熱鬧氛圍",
					emoji: "🎊",
					description:
						"我享受夜市的人聲鼎沸，在熱鬧中感受台灣夜市文化",
					score: { foodFocus: "atmosphere" },
				},
			],
		},
		{
			id: "6c",
			text: "尋找隱藏美食時，你最信任什麼？",
			subtitle: "在地美食探索之道",
			condition: { activity: "food", foodStyle: "hidden" },
			options: [
				{
					id: "locals",
					text: "在地人推薦",
					emoji: "👥",
					description:
						"我相信在地人的口碑，跟著老顧客找到真正的好味道",
					score: { discovery: "locals" },
				},
				{
					id: "intuition",
					text: "直覺與緣分",
					emoji: "✨",
					description:
						"我喜歡隨性探索，用直覺發現藏在巷弄間的美食驚喜",
					score: { discovery: "intuition" },
				},
			],
		},
		{
			id: 7,
			text: "夜生活中，你比較嚮往哪種氛圍？",
			subtitle: "夜晚的都市探索",
			condition: { activity: "nightlife" },
			options: [
				{
					id: "sophisticated",
					text: "精緻都會風",
					emoji: "🥂",
					description: "我喜歡有格調的酒吧，享受都市夜晚的優雅氛圍",
					score: { nightStyle: "upscale", atmosphere: "modern" },
				},
				{
					id: "authentic",
					text: "道地居酒屋",
					emoji: "🏮",
					description: "我偏愛溫馨的日式居酒屋，在微醺中感受人情味",
					score: { nightStyle: "cozy", atmosphere: "traditional" },
				},
			],
		},
		{
			id: "7b",
			text: "在精緻酒吧，你最看重什麼？",
			subtitle: "都會夜生活的品味",
			condition: { activity: "nightlife", nightStyle: "upscale" },
			options: [
				{
					id: "cocktail",
					text: "創意調酒藝術",
					emoji: "🍹",
					description:
						"我欣賞調酒師的專業技藝，品味每杯酒背後的創意故事",
					score: { nightFocus: "cocktail" },
				},
				{
					id: "ambience",
					text: "氛圍與社交",
					emoji: "🌃",
					description:
						"我重視酒吧的設計美學，享受與朋友談天說地的時光",
					score: { nightFocus: "ambience" },
				},
			],
		},
		{
			id: "7c",
			text: "在居酒屋，你最享受什麼？",
			subtitle: "日式夜晚的溫暖",
			condition: { activity: "nightlife", nightStyle: "cozy" },
			options: [
				{
					id: "sake",
					text: "清酒與下酒菜",
					emoji: "🍶",
					description: "我喜歡品嚐不同的清酒，配上道地的日式下酒菜",
					score: { nightFocus: "sake" },
				},
				{
					id: "conversation",
					text: "深度交流談心",
					emoji: "💬",
					description: "我珍惜在溫馨環境中與朋友深談，分享生活點滴",
					score: { nightFocus: "conversation" },
				},
			],
		},
		{
			id: 8,
			text: "最後一題：你理想的台北一日遊是？",
			subtitle: "總結你的完美體驗",
			options: [
				{
					id: "diverse",
					text: "多元文化體驗",
					emoji: "🌏",
					description: "我想在一天內體驗台北的多樣面貌，從傳統到現代",
					score: { finalChoice: "diverse" },
				},
				{
					id: "focused",
					text: "深度單一主題",
					emoji: "🎯",
					description: "我偏愛專注在一個主題上深度探索，不求廣但求精",
					score: { finalChoice: "focused" },
				},
				{
					id: "spontaneous",
					text: "隨性自在漫遊",
					emoji: "🚶",
					description:
						"我喜歡沒有計畫的自由探索，讓台北自己告訴我故事",
					score: { finalChoice: "spontaneous" },
				},
			],
		},
	];

	// 重新設計的結果類型定義 - 對應20個商圈
	const resultTypes = {
		// 高檔購物型
		PREMIUM_SHOPPER: {
			name: "精品生活家",
			description: "你追求高品質的生活體驗，重視環境氛圍與服務品質",
			personality: "品味獨到、注重質感",
			districts: ["tianmu", "zhongshan", "siping"], // 天母、中山、四平陽光
		},
		// 國際化購物型
		INTERNATIONAL_SHOPPER: {
			name: "國際品味達人",
			description: "你喜歡多元文化的購物體驗，追求國際化的生活風格",
			personality: "國際視野、文化包容",
			districts: ["tianmu", "yuanshan", "zhongshan"], // 天母、圓山、中山
		},
		// 聰明消費型
		SMART_SHOPPER: {
			name: "精明購物達人",
			description: "你善於發現物超所值的好東西，是聰明消費的典範",
			personality: "理性消費、眼光獨到",
			districts: ["houzhan", "chaoyang", "wanhua"], // 後站、朝陽服飾材料、萬華街區
		},
		// 批發尋寶型
		WHOLESALE_HUNTER: {
			name: "批發市場探險家",
			description: "你熱愛在批發商圈尋寶，總能找到意想不到的好東西",
			personality: "探險精神、挖掘達人",
			districts: ["houzhan", "chaoyang", "siping"], // 後站、朝陽服飾材料、四平陽光
		},
		// 傳統文化型
		CULTURE_LOVER: {
			name: "古城文化探索者",
			description: "你對台北的歷史文化有深厚興趣，喜愛傳統市井風情",
			personality: "懷古情懷、人文氣息",
			districts: ["qingguang", "wanhua", "rongding"], // 晴光、萬華街區、榮町
		},
		// 市場美食型
		MARKET_FOODIE: {
			name: "傳統市場美食家",
			description: "你熱愛傳統市場的人情味與道地小吃",
			personality: "親切隨和、重視人情味",
			districts: ["qingguang", "wanhua", "tonghua"], // 晴光、萬華街區、通化夜市
		},
		// 日式復古型
		RETRO_ENTHUSIAST: {
			name: "日式復古愛好者",
			description: "你被日治時期的建築與文化深深吸引，享受復古的浪漫",
			personality: "復古情調、文藝氣質",
			districts: ["tiaotong", "rongding", "zhongshanwedding"], // 條通、榮町、中山北路婚紗
		},
		// 建築美學型
		ARCHITECTURE_LOVER: {
			name: "建築美學鑑賞家",
			description: "你對歷史建築有獨特的審美，欣賞每個時代的建築藝術",
			personality: "美學品味、歷史情懷",
			districts: ["rongding", "zhongshanwedding", "chongnanbook"], // 榮町、中山北路婚紗、重南書路
		},
		// 溫泉療癒型
		HOTSPRING_SEEKER: {
			name: "溫泉療癒師",
			description: "你懂得照顧自己，追求身心靈的放鬆與平衡",
			personality: "注重養生、享受慢活",
			districts: ["xinbeitou", "xingyilu", "shipai"], // 新北投溫泉、行義路溫泉、石牌捷運
		},
		// 山林溫泉型
		MOUNTAIN_SPA_LOVER: {
			name: "山林溫泉隱士",
			description: "你偏愛隱身山林的溫泉，在自然中找到內心的寧靜",
			personality: "親近自然、內心平和",
			districts: ["xingyilu", "xinbeitou", "shipai"], // 行義路溫泉、新北投溫泉、石牌捷運
		},
		// 都會咖啡型
		URBAN_COFFEE_LOVER: {
			name: "都會書香咖啡人",
			description: "你喜歡在城市中尋找寧靜角落，享受知性的時光",
			personality: "文青氣質、知性優雅",
			districts: ["chongnanbook", "zhongshan", "yuanshan"], // 重南書路、中山、圓山
		},
		// 設計美學型
		DESIGN_AESTHETE: {
			name: "設計美學生活家",
			description: "你被創意設計深深吸引，追求美學與生活的完美結合",
			personality: "創意思維、美學追求",
			districts: ["zhongshan", "yuanshan", "siping"], // 中山、圓山、四平陽光
		},
		// 知名美食型
		FOODIE_EXPLORER: {
			name: "夜市美食獵人",
			description: "你熱愛探索台北的經典美食，是資深的夜市達人",
			personality: "美食控、社交達人",
			districts: ["shilin", "tonghua", "huaxi"], // 士林觀光夜市、通化夜市、華西街夜市
		},
		// 夜市氛圍型
		NIGHT_MARKET_CULTURE: {
			name: "夜市文化體驗家",
			description: "你不只愛美食，更享受夜市的熱鬧氛圍與人情味",
			personality: "熱愛生活、擁抱文化",
			districts: ["shilin", "huaxi", "tonghua"], // 士林觀光夜市、華西街夜市、通化夜市
		},
		// 隱藏美食型
		HIDDEN_GEM_HUNTER: {
			name: "巷弄秘境探索者",
			description: "你總能發現別人不知道的美食秘境，是在地美食通",
			personality: "探險精神、在地專家",
			districts: ["qingguang", "wanhua", "tonghua"], // 晴光、萬華街區、通化夜市
		},
		// 在地人情型
		LOCAL_INSIDER: {
			name: "在地人情通",
			description: "你重視在地人的推薦，深入體驗台北的庶民文化",
			personality: "親和力強、重視人際",
			districts: ["qingguang", "wanhua", "huaxi"], // 晴光、萬華街區、華西街夜市
		},
		// 精緻夜生活型
		SOPHISTICATED_NIGHT: {
			name: "都會夜生活家",
			description: "你享受台北夜晚的都會魅力，追求精緻的夜間體驗",
			personality: "都會感、時尚品味",
			districts: ["zhongshan", "tiaotong", "siping"], // 中山、條通、四平陽光
		},
		// 調酒藝術型
		COCKTAIL_CONNOISSEUR: {
			name: "調酒藝術鑑賞家",
			description: "你欣賞調酒的專業技藝，品味每杯酒背後的創意故事",
			personality: "專業品味、追求細節",
			districts: ["zhongshan", "tiaotong", "tianmu"], // 中山、條通、天母
		},
		// 傳統夜生活型
		COZY_NIGHT: {
			name: "溫馨居酒屋愛好者",
			description: "你偏愛有人情味的夜生活，在溫馨氛圍中找到歸屬感",
			personality: "重情義、喜歡交流",
			districts: ["tiaotong", "qingguang", "wanhua"], // 條通、晴光、萬華街區
		},
		// 清酒文化型
		SAKE_CULTURE_LOVER: {
			name: "清酒文化愛好者",
			description: "你深度了解日式酒文化，享受清酒帶來的文化體驗",
			personality: "文化深度、細膩品味",
			districts: ["tiaotong", "zhongshanwedding", "rongding"], // 條通、中山北路婚紗、榮町
		},
		// 科技上班族型
		TECH_WORKER: {
			name: "科技新貴生活家",
			description: "你是現代都會的科技工作者，重視便利與效率",
			personality: "效率導向、現代感",
			districts: ["xihu", "shipai", "zhongshan"], // 西湖、石牌捷運、中山
		},
		// 特殊興趣型
		SPECIAL_INTEREST: {
			name: "專業興趣達人",
			description: "你有特殊的興趣領域，總能在專業商圈中找到樂趣",
			personality: "專業導向、興趣廣泛",
			districts: ["chengdecar", "chaoyang", "chongnanbook"], // 承德路中古汽車、朝陽服飾材料、重南書路
		},
		// 多元探索型
		DIVERSE_EXPLORER: {
			name: "多元文化探索家",
			description: "你喜歡體驗台北的多樣面貌，從傳統到現代都不放過",
			personality: "開放包容、好奇心強",
			districts: ["yuanshan", "zhongshan", "wanhua"], // 圓山、中山、萬華街區
		},
		// 專注體驗型
		FOCUSED_EXPERIENCER: {
			name: "深度體驗專家",
			description: "你偏愛深度探索，在單一主題中發現豐富層次",
			personality: "專注深入、追求品質",
			districts: ["tianmu", "xinbeitou", "chongnanbook"], // 天母、新北投溫泉、重南書路
		},
		// 隨性漫遊型
		SPONTANEOUS_WANDERER: {
			name: "隨性漫遊者",
			description: "你享受沒有計畫的自由探索，讓城市自己告訴你故事",
			personality: "自由自在、隨遇而安",
			districts: ["qingguang", "siping", "tonghua"], // 晴光、四平陽光、通化夜市
		},
	};

	// 測驗狀態
	const currentScreen = ref("intro");
	const currentQuestion = ref(0);
	const answers = ref([]);
	const userProfile = ref({});
	const quizResult = ref(null);
	const recommendedDistricts = ref([]);

	// 動態生成問題序列
	const questions = ref([]);

	// 計算所有可能的問題序列
	const getAllPossibleQuestions = (profile = {}) => {
		const sequence = [];

		// 第一題總是顯示
		sequence.push(naturalQuestions[0]);

		// 根據profile模擬可能的問題路徑
		for (let i = 1; i < naturalQuestions.length; i++) {
			const question = naturalQuestions[i];

			// 檢查條件是否符合
			if (shouldShowQuestion(question, profile)) {
				sequence.push(question);
			}
		}

		return sequence;
	};

	// 取得當前問題的總數
	const totalQuestions = computed(() => {
		// 根據當前用戶檔案預估總問題數
		const currentProfile = userProfile.value;

		if (!currentProfile.timePreference) {
			return 5; // 預估最少5題
		}

		// 根據選擇的路徑計算實際問題數，現在有更多分支問題
		if (currentProfile.timePreference === "day") {
			if (currentProfile.activity === "shopping") return 4; // 基本 + 消費哲學 + 環境偏好
			if (currentProfile.activity === "culture") return 4; // 基本 + 文化風格 + 深度探索
			if (currentProfile.activity === "relax") return 4; // 基本 + 休閒類型 + 環境偏好
		} else if (currentProfile.timePreference === "night") {
			if (currentProfile.activity === "food") return 4; // 基本 + 美食類型 + 探索方式
			if (currentProfile.activity === "nightlife") return 4; // 基本 + 夜生活風格 + 體驗重點
		}

		return 4; // 加上最後一題總結問題
	});

	// 檢查是否應該顯示問題
	const shouldShowQuestion = (question, profile) => {
		if (!question.condition) return true;

		for (const [key, value] of Object.entries(question.condition)) {
			if (profile[key] !== value) return false;
		}
		return true;
	};

	// 開始測驗
	const startQuiz = () => {
		console.log("開始台北商圈心理測驗");
		resetState();
		// 載入第一題
		questions.value = [naturalQuestions[0]];
		console.log("載入的第一題數據:", naturalQuestions[0]);
		console.log("questions.value:", questions.value);
		console.log("第一題選項數量:", naturalQuestions[0].options?.length);
		currentScreen.value = "question";
	};

	// 處理回答
	const handleAnswer = (option) => {
		console.log("用戶選擇:", option);

		// 記錄答案
		answers.value.push({
			questionId: questions.value[currentQuestion.value].id,
			optionId: option.id,
			score: option.score,
		});

		// 更新用戶檔案
		if (option.score) {
			Object.assign(userProfile.value, option.score);
		}

		console.log("更新後的用戶檔案:", userProfile.value);

		// 重新計算符合條件的問題
		const allPossibleQuestions = getAllPossibleQuestions(userProfile.value);

		// 檢查是否還有更多問題
		const nextQuestionIndex = currentQuestion.value + 1;

		if (nextQuestionIndex < allPossibleQuestions.length) {
			// 添加下一題到問題序列
			if (nextQuestionIndex >= questions.value.length) {
				questions.value.push(allPossibleQuestions[nextQuestionIndex]);
			}
			currentQuestion.value = nextQuestionIndex;
		} else {
			// 測驗完成，計算結果
			calculateResult();
		}
	};

	// 智能結果計算 - 重新設計配對邏輯
	const calculateResult = () => {
		const profile = userProfile.value;
		let resultType = "FOODIE_EXPLORER"; // 默認結果

		console.log("計算結果，用戶檔案:", profile);

		// 基於用戶檔案計算結果類型 - 增加更細緻的判斷
		if (profile.timePreference === "day") {
			if (profile.activity === "shopping") {
				// 購物路徑
				if (profile.budget === "high") {
					// 高檔購物進一步細分
					resultType =
						profile.atmosphere === "international"
							? "INTERNATIONAL_SHOPPER"
							: "PREMIUM_SHOPPER";
				} else {
					// 平價購物進一步細分
					resultType =
						profile.shoppingStyle === "wholesale"
							? "WHOLESALE_HUNTER"
							: "SMART_SHOPPER";
				}
			} else if (profile.activity === "culture") {
				// 文化路徑
				if (profile.cultureStyle === "traditional") {
					resultType =
						profile.focus === "market"
							? "MARKET_FOODIE"
							: "CULTURE_LOVER";
				} else {
					resultType =
						profile.focus === "architecture"
							? "ARCHITECTURE_LOVER"
							: "RETRO_ENTHUSIAST";
				}
			} else if (profile.activity === "relax") {
				// 休閒路徑
				if (profile.relaxStyle === "hotspring") {
					resultType =
						profile.hotelStyle === "mountain"
							? "MOUNTAIN_SPA_LOVER"
							: "HOTSPRING_SEEKER";
				} else {
					resultType =
						profile.cafeStyle === "bookstore"
							? "URBAN_COFFEE_LOVER"
							: "DESIGN_AESTHETE";
				}
			}
		} else if (profile.timePreference === "night") {
			if (profile.activity === "food") {
				// 美食路徑
				if (profile.foodStyle === "famous") {
					resultType =
						profile.foodFocus === "atmosphere"
							? "NIGHT_MARKET_CULTURE"
							: "FOODIE_EXPLORER";
				} else {
					resultType =
						profile.discovery === "locals"
							? "LOCAL_INSIDER"
							: "HIDDEN_GEM_HUNTER";
				}
			} else if (profile.activity === "nightlife") {
				// 夜生活路徑
				if (profile.nightStyle === "upscale") {
					resultType =
						profile.nightFocus === "cocktail"
							? "COCKTAIL_CONNOISSEUR"
							: "SOPHISTICATED_NIGHT";
				} else {
					resultType =
						profile.nightFocus === "sake"
							? "SAKE_CULTURE_LOVER"
							: "COZY_NIGHT";
				}
			}
		}

		// 最後一題的總結性影響
		if (profile.finalChoice) {
			if (profile.finalChoice === "diverse") {
				resultType = "DIVERSE_EXPLORER";
			} else if (profile.finalChoice === "focused") {
				resultType = "FOCUSED_EXPERIENCER";
			} else if (profile.finalChoice === "spontaneous") {
				resultType = "SPONTANEOUS_WANDERER";
			}
		}

		const result = resultTypes[resultType];

		if (!result) {
			console.error("無法找到結果類型:", resultType);
			return;
		}

		quizResult.value = {
			type: resultType,
			name: result.name,
			description: result.description,
			personality: result.personality,
			profile: profile,
			recommendedTime: getRecommendedTime(profile),
			budget: getBudgetRange(profile),
			personalityInsights: getPersonalityInsights(profile),
		};

		// 使用新的商圈推薦邏輯
		const districtIds = result.districts || ["shilin"];

		// 使用 districts.js 的數據
		recommendedDistricts.value = districtIds
			.map((id) => getDistrictById(id))
			.filter(Boolean);

		console.log("測驗結果:", quizResult.value);
		console.log("推薦商圈IDs:", districtIds);
		console.log("推薦商圈數據:", recommendedDistricts.value);

		currentScreen.value = "result";
	};

	// 取得推薦時間
	const getRecommendedTime = (profile) => {
		if (profile.timePreference === "day") {
			if (profile.activity === "relax") return "平日下午 14:00-17:00";
			return "週末上午 10:00-17:00";
		} else {
			if (profile.activity === "food") return "每日 17:00-22:00";
			return "週末夜晚 19:00-23:00";
		}
	};

	// 取得預算範圍
	const getBudgetRange = (profile) => {
		if (profile.budget === "high" || profile.style === "premium") {
			return "NT$ 1,500-4,000";
		} else if (profile.budget === "low" || profile.style === "practical") {
			return "NT$ 300-1,000";
		} else if (profile.activity === "food") {
			return profile.foodStyle === "famous"
				? "NT$ 200-600"
				: "NT$ 100-400";
		} else if (profile.activity === "relax") {
			return profile.relaxStyle === "hotspring"
				? "NT$ 300-800"
				: "NT$ 150-500";
		} else {
			return "NT$ 200-800";
		}
	};

	// 取得個性洞察
	const getPersonalityInsights = (profile) => {
		const insights = [];

		if (profile.timePreference === "day") {
			insights.push("你是個晨型人，喜歡充滿活力的白天時光");
		} else {
			insights.push("你享受夜晚的魅力，是個標準的夜貓族");
		}

		if (profile.activity === "shopping") {
			if (profile.budget === "high") {
				if (profile.atmosphere === "international") {
					insights.push("你擁有國際化的視野，喜歡多元文化的購物體驗");
				} else {
					insights.push("你注重品質與品味，願意為優質體驗投資");
				}
			} else {
				if (profile.shoppingStyle === "wholesale") {
					insights.push("你有敏銳的商業嗅覺，善於在批發市場挖掘寶物");
				} else {
					insights.push(
						"你善於發現物超所值的好東西，是個聰明的消費者"
					);
				}
			}
		} else if (profile.activity === "culture") {
			if (profile.cultureStyle === "traditional") {
				if (profile.focus === "market") {
					insights.push(
						"你熱愛台灣的傳統市場文化，享受人情味與道地美食"
					);
				} else {
					insights.push(
						"你對台灣傳統文化有深厚興趣，喜歡探索在地人情味"
					);
				}
			} else {
				if (profile.focus === "architecture") {
					insights.push(
						"你有獨特的美學眼光，對歷史建築有深度的鑑賞能力"
					);
				} else {
					insights.push(
						"你被歷史建築與復古風情吸引，追求文藝的生活體驗"
					);
				}
			}
		} else if (profile.activity === "relax") {
			if (profile.relaxStyle === "hotspring") {
				if (profile.hotelStyle === "mountain") {
					insights.push(
						"你親近自然，偏愛在山林中找到內心的平靜與療癒"
					);
				} else {
					insights.push("你懂得照顧自己，重視身心靈的放鬆與療癒");
				}
			} else {
				if (profile.cafeStyle === "bookstore") {
					insights.push(
						"你是個知性的人，喜歡在書香與咖啡中度過悠閒時光"
					);
				} else {
					insights.push("你有敏銳的美學觸角，被創意設計深深吸引");
				}
			}
		} else if (profile.activity === "food") {
			if (profile.foodStyle === "famous") {
				if (profile.foodFocus === "atmosphere") {
					insights.push(
						"你不只愛美食，更享受夜市文化的熱鬧氛圍與人情味"
					);
				} else {
					insights.push("你樂於嘗試知名美食，享受與人分享的樂趣");
				}
			} else {
				if (profile.discovery === "locals") {
					insights.push(
						"你重視人際關係，喜歡跟著在地人發現真正的美味"
					);
				} else {
					insights.push("你是個美食探險家，喜歡發掘隱藏的在地美味");
				}
			}
		} else if (profile.activity === "nightlife") {
			if (profile.nightStyle === "upscale") {
				if (profile.nightFocus === "cocktail") {
					insights.push(
						"你欣賞專業的調酒技藝，品味每杯酒背後的創意故事"
					);
				} else {
					insights.push("你追求精緻的夜生活體驗，喜歡都會的時尚氛圍");
				}
			} else {
				if (profile.nightFocus === "sake") {
					insights.push(
						"你對日式酒文化有深度了解，享受清酒帶來的文化體驗"
					);
				} else {
					insights.push(
						"你偏愛溫馨的社交環境，重視人情味與真誠的交流"
					);
				}
			}
		}

		// 根據最終選擇添加洞察
		if (profile.finalChoice === "diverse") {
			insights.push("你有開放包容的心態，喜歡體驗城市的多樣面貌");
		} else if (profile.finalChoice === "focused") {
			insights.push("你追求深度體驗，在專注中發現生活的豐富層次");
		} else if (profile.finalChoice === "spontaneous") {
			insights.push("你享受自由探索的樂趣，讓城市的驚喜自然發生");
		}

		return insights;
	};

	// 返回上一題
	const goBack = () => {
		if (currentQuestion.value > 0) {
			currentQuestion.value -= 1;
			answers.value.splice(currentQuestion.value);

			// 回滾用戶檔案
			userProfile.value = {};
			for (let i = 0; i < answers.value.length; i++) {
				const answer = answers.value[i];
				if (answer?.score) {
					Object.assign(userProfile.value, answer.score);
				}
			}
		}
	};

	// 重新開始測驗
	const restartQuiz = () => {
		currentScreen.value = "intro";
		currentQuestion.value = 0;
		answers.value = [];
		userProfile.value = {};
		quizResult.value = null;
		recommendedDistricts.value = [];
	};

	// 過濾問題以支援條件邏輯
	const getFilteredQuestions = () => {
		return naturalQuestions.filter((question) => {
			// 如果沒有條件，直接包含
			if (!question.condition) return true;

			// 檢查所有條件是否符合當前用戶檔案
			return Object.entries(question.condition).every(([key, value]) => {
				return userProfile.value[key] === value;
			});
		});
	};

	// 重置狀態
	const resetState = () => {
		currentQuestion.value = 0;
		answers.value = [];
		userProfile.value = {};
		quizResult.value = null;
		recommendedDistricts.value = [];
	};

	return {
		// 狀態
		currentScreen,
		currentQuestion,
		questions,
		totalQuestions,
		answers,
		userProfile,
		quizResult,
		recommendedDistricts,

		// 方法
		startQuiz,
		handleAnswer,
		goBack,
		restartQuiz,
		calculateResult,
		getAllPossibleQuestions,
	};
}

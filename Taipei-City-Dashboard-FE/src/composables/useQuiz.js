import { ref, computed } from "vue";

/**
 * 台北商圈心理測驗 composable - 2.0版本
 * @returns {Object} 測驗相關的狀態和方法
 */
export function useQuiz() {
	// 新版本的自然化問題數據 - 二選一格式
	const naturalQuestions = [
		{
			id: 1,
			text: "週末想去商圈，你偏好什麼時間？",
			subtitle: "選擇你最喜歡的時段",
			options: [
				{
					id: "day",
					text: "白天逛街",
					emoji: "☀️",
					description: "我喜歡白天的陽光和咖啡香，享受悠閒購物時光",
					score: { timePreference: "day" },
				},
				{
					id: "night",
					text: "夜晚覓食",
					emoji: "🌙",
					description: "我偏愛夜市熱鬧氛圍，品嚐美食和夜生活",
					score: { timePreference: "night" },
				},
			],
		},
		{
			id: 2,
			text: "你更重視商圈的什麼特色？",
			subtitle: "白天商圈的魅力所在",
			condition: { timePreference: "day" },
			options: [
				{
					id: "shopping",
					text: "購物體驗",
					emoji: "🛍️",
					description: "我想要豐富的購物選擇，從精品到平價都有",
					score: { activity: "shopping" },
				},
				{
					id: "culture",
					text: "文化氛圍",
					emoji: "🏛️",
					description: "我偏愛有歷史文化特色的商圈漫步體驗",
					score: { activity: "culture" },
				},
			],
		},
		{
			id: "2b",
			text: "夜晚商圈你最想體驗什麼？",
			subtitle: "夜間活動的首選",
			condition: { timePreference: "night" },
			options: [
				{
					id: "food",
					text: "美食探索",
					emoji: "🍜",
					description: "我想品嚐各種道地美食，從夜市到餐廳",
					score: { activity: "food" },
				},
				{
					id: "nightlife",
					text: "夜生活娛樂",
					emoji: "🍸",
					description: "我想體驗酒吧、KTV等夜間娛樂活動",
					score: { activity: "nightlife" },
				},
			],
		},
		{
			id: 3,
			text: "你的消費習慣偏向哪種？",
			subtitle: "購物時的考量重點",
			condition: { activity: "shopping" },
			options: [
				{
					id: "quality",
					text: "品質優先",
					emoji: "💎",
					description: "我重視商品品質和服務，願意為好東西付費",
					score: { budget: "high" },
				},
				{
					id: "value",
					text: "CP值至上",
					emoji: "🎯",
					description: "我喜歡挖寶找便宜，追求物超所值的商品",
					score: { budget: "low" },
				},
			],
		},
		{
			id: 4,
			text: "文化商圈中，你偏愛哪種風格？",
			subtitle: "文化體驗的選擇",
			condition: { activity: "culture" },
			options: [
				{
					id: "traditional",
					text: "傳統古韻",
					emoji: "🏮",
					description: "我喜歡古蹟老街，感受台灣傳統文化魅力",
					score: { style: "traditional" },
				},
				{
					id: "modern",
					text: "現代文創",
					emoji: "🎨",
					description: "我偏愛文創園區，追求現代設計美學",
					score: { style: "modern" },
				},
			],
		},
		{
			id: 5,
			text: "美食探索時，你的偏好是？",
			subtitle: "美食獵人的選擇",
			condition: { activity: "food" },
			options: [
				{
					id: "popular",
					text: "熱門排隊店",
					emoji: "📸",
					description: "我喜歡網紅推薦的熱門美食，享受排隊的期待感",
					score: { foodStyle: "popular" },
				},
				{
					id: "local",
					text: "在地隱藏版",
					emoji: "🔍",
					description: "我偏愛巷弄深處的老店，尋找在地人的秘密基地",
					score: { foodStyle: "local" },
				},
			],
		},
		{
			id: 6,
			text: "夜生活娛樂你比較偏好？",
			subtitle: "夜晚的娛樂方式",
			condition: { activity: "nightlife" },
			options: [
				{
					id: "casual",
					text: "輕鬆小酌",
					emoji: "🏮",
					description: "我喜歡溫馨的居酒屋氛圍，和朋友小酌聊天",
					score: { nightStyle: "casual" },
				},
				{
					id: "party",
					text: "熱鬧派對",
					emoji: "🎉",
					description: "我追求熱鬧的夜店文化，享受音樂和舞蹈",
					score: { nightStyle: "party" },
				},
			],
		},
	];

	// 完整的商圈數據
	const districtData = {
		xinyi: {
			id: "xinyi",
			name: "信義商圈",
			image: "https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=800&h=600&fit=crop",
			description:
				"台北最具國際化的現代商圈，摩天大樓與精品店林立，是時尚購物與美食的頂級聚集地",
			tags: ["時尚", "購物", "現代", "國際"],
			location: "信義區",
			rating: "4.8",
			highlights: [
				"台北101觀景台",
				"新光三越信義新天地",
				"誠品信義店",
				"威秀影城",
			],
			transportation: {
				mrt: "信義安和站、市政府站",
				bus: "藍5、藍26、266、611",
			},
			spending: {
				dining: "NT$ 400-1200",
				shopping: "NT$ 1500-8000",
			},
			timing: {
				weekday: "11:00-22:00",
				weekend: "10:00-23:00",
			},
		},
		dongqu: {
			id: "dongqu",
			name: "東區商圈",
			image: "https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=800&h=600&fit=crop",
			description:
				"永遠的時尚指標，從忠孝東路四段到敦化南路，集結最新潮的服飾、美妝與餐廳",
			tags: ["潮流", "美食", "夜生活", "購物"],
			location: "大安區",
			rating: "4.6",
			highlights: ["SOGO復興館", "明曜百貨", "頂好商圈", "國父紀念館"],
			transportation: {
				mrt: "忠孝復興站、忠孝敦化站",
				bus: "204、270、311、621",
			},
			spending: {
				dining: "NT$ 300-1000",
				shopping: "NT$ 800-5000",
			},
			timing: {
				weekday: "11:00-22:00",
				weekend: "10:00-23:00",
			},
		},
		wufenpu: {
			id: "wufenpu",
			name: "五分埔商圈",
			image: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop",
			description:
				"台北最大的服飾批發商圈，CP值超高的購物天堂，從韓風到歐美風應有盡有",
			tags: ["批發", "平價", "服飾", "挖寶"],
			location: "信義區",
			rating: "4.3",
			highlights: ["服飾批發中心", "韓系服飾店", "配件雜貨", "平價美食"],
			transportation: {
				mrt: "後山埤站、永春站",
				bus: "32、46、257、286",
			},
			spending: {
				dining: "NT$ 100-300",
				shopping: "NT$ 200-800",
			},
			timing: {
				weekday: "13:00-21:00",
				weekend: "11:00-21:00",
			},
		},
		huayinstreet: {
			id: "huayinstreet",
			name: "華陰街商圈",
			image: "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop",
			description:
				"台北車站旁的購物寶庫，以平價服飾、3C用品和美食聞名的老字號商圈",
			tags: ["平價", "3C", "傳統", "美食"],
			location: "大同區",
			rating: "4.2",
			highlights: ["光華商場", "站前地下街", "懷寧商圈", "台北車站美食"],
			transportation: {
				mrt: "台北車站、中山站",
				bus: "9、37、274、612",
			},
			spending: {
				dining: "NT$ 80-250",
				shopping: "NT$ 150-600",
			},
			timing: {
				weekday: "10:00-21:00",
				weekend: "10:00-22:00",
			},
		},
		dihua: {
			id: "dihua",
			name: "迪化街商圈",
			image: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop",
			description:
				"百年老街的歷史風華，傳統年貨、中藥材、茶葉和古早味小吃的文化寶庫",
			tags: ["歷史", "傳統", "文化", "老街"],
			location: "大同區",
			rating: "4.5",
			highlights: [
				"百年建築",
				"傳統年貨大街",
				"霞海城隍廟",
				"古早味小吃",
			],
			transportation: {
				mrt: "北門站、大橋頭站",
				bus: "206、274、518、669",
			},
			spending: {
				dining: "NT$ 50-200",
				shopping: "NT$ 100-500",
			},
			timing: {
				weekday: "09:00-18:00",
				weekend: "09:00-19:00",
			},
		},
		dadaocheng: {
			id: "dadaocheng",
			name: "大稻埕商圈",
			image: "https://images.unsplash.com/photo-1589059243688-f3fba8c2b8ad?w=800&h=600&fit=crop",
			description:
				"台北的文藝復興區域，結合歷史建築、文創店鋪與特色咖啡廳的懷舊商圈",
			tags: ["文創", "咖啡", "歷史", "藝術"],
			location: "大同區",
			rating: "4.4",
			highlights: ["文創商店", "特色咖啡廳", "古蹟導覽", "淡水河景"],
			transportation: {
				mrt: "北門站、中山站",
				bus: "9、206、255、518",
			},
			spending: {
				dining: "NT$ 150-400",
				shopping: "NT$ 200-800",
			},
			timing: {
				weekday: "10:00-19:00",
				weekend: "10:00-20:00",
			},
		},
		shilin: {
			id: "shilin",
			name: "士林夜市",
			image: "https://images.unsplash.com/photo-1551218370-8d998d9b0f2a?w=800&h=600&fit=crop",
			description:
				"台北最著名的觀光夜市，美食與娛樂的完美結合，國內外遊客必訪聖地",
			tags: ["夜市", "美食", "觀光", "熱鬧"],
			location: "士林區",
			rating: "4.6",
			highlights: ["豪大雞排", "蚵仔煎", "雪花冰", "夜市遊戲"],
			transportation: {
				mrt: "劍潭站",
				bus: "111、216、220、260",
			},
			spending: {
				dining: "NT$ 150-500",
				entertainment: "NT$ 100-300",
			},
			timing: {
				weekday: "17:00-01:00",
				weekend: "16:00-02:00",
			},
		},
		ximending: {
			id: "ximending",
			name: "西門町商圈",
			image: "https://images.unsplash.com/photo-1537516628943-ff5a8410b503?w=800&h=600&fit=crop",
			description:
				"台北的原宿，年輕潮流文化的發源地，街頭美食與流行文化的交匯點",
			tags: ["年輕", "潮流", "娛樂", "多元"],
			location: "萬華區",
			rating: "4.5",
			highlights: ["西門紅樓", "電影街", "街頭美食", "流行服飾"],
			transportation: {
				mrt: "西門站",
				bus: "1、12、265、307",
			},
			spending: {
				dining: "NT$ 100-400",
				shopping: "NT$ 200-1000",
			},
			timing: {
				weekday: "11:00-23:00",
				weekend: "10:00-24:00",
			},
		},
	};

	// 結果類型定義
	const resultTypes = {
		H: {
			name: "質感生活家",
			description: "你追求品味與格調，願意為質感付費",
			tagline: "推薦商圈：信義商圈、東區商圈",
		},
		L: {
			name: "精明消費達人",
			description: "你善於發現物超所值的好東西",
			tagline: "推薦商圈：五分埔、華陰街商圈",
		},
		O: {
			name: "文化探索者",
			description: "你對歷史文化有著深深的眷戀",
			tagline: "推薦商圈：迪化街、大稻埕商圈",
		},
		N: {
			name: "文青生活家",
			description: "你熱愛創意與美學的文藝青年",
			tagline: "推薦商圈：大稻埕、西門町商圈",
		},
		S: {
			name: "療癒系旅人",
			description: "你懂得照顧自己，追求身心放鬆",
			tagline: "推薦商圈：士林夜市周邊",
		},
		T: {
			name: "山景品茗師",
			description: "你追求寧靜致遠的雅士",
			tagline: "推薦商圈：大稻埕咖啡文化",
		},
		M: {
			name: "美食獵人",
			description: "你熱愛探索美食的饕客",
			tagline: "推薦商圈：士林夜市、西門町商圈",
		},
		P: {
			name: "在地美食通",
			description: "你深諳在地美味的老饕",
			tagline: "推薦商圈：士林夜市、迪化街商圈",
		},
		J: {
			name: "居酒屋愛好者",
			description: "你偏愛日式溫暖的微醺氛圍",
			tagline: "推薦商圈：東區、西門町商圈",
		},
		K: {
			name: "夜生活玩家",
			description: "你熱愛夜生活的潮流先鋒",
			tagline: "推薦商圈：信義商圈、東區商圈",
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
			return 3; // 最少3題
		}

		// 根據選擇的路徑計算實際問題數
		if (currentProfile.timePreference === "day") {
			return 3; // 時間 + 活動 + 細分
		} else if (currentProfile.timePreference === "night") {
			return 3; // 時間 + 活動 + 細分
		}

		return 3;
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
		console.log("開始心理測驗");
		resetState();
		// 載入第一題
		questions.value = [naturalQuestions[0]];
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

	// 智能結果計算
	const calculateResult = () => {
		const profile = userProfile.value;
		let resultType = "N"; // 默認結果

		console.log("計算結果，用戶檔案:", profile);

		// 基於用戶檔案計算結果類型
		if (profile.timePreference === "day") {
			if (profile.activity === "shopping") {
				// 購物路徑
				resultType = profile.budget === "high" ? "H" : "L";
			} else if (profile.activity === "culture") {
				// 文化路徑
				resultType = profile.style === "traditional" ? "O" : "N";
			}
		} else if (profile.timePreference === "night") {
			if (profile.activity === "food") {
				// 美食路徑
				resultType = profile.foodStyle === "popular" ? "M" : "P";
			} else if (profile.activity === "nightlife") {
				// 夜生活路徑
				resultType = profile.nightStyle === "casual" ? "J" : "K";
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
			tagline: result.tagline,
			profile: profile,
			recommendedTime:
				profile.timePreference === "day"
					? "白天 10:00-18:00"
					: "夜晚 18:00-23:00",
			budget: getBudgetRange(profile),
			personalityInsights: getPersonalityInsights(profile),
		};

		// 商圈推薦對應表
		const districtMapping = {
			H: ["xinyi", "dongqu"], // 質感生活家 → 信義、東區
			L: ["wufenpu", "huayinstreet"], // 精明消費達人 → 五分埔、華陰街
			O: ["dihua", "dadaocheng"], // 文化探索者 → 迪化街、大稻埕
			N: ["dadaocheng", "ximending"], // 文青生活家 → 大稻埕、西門町
			M: ["shilin", "ximending"], // 美食獵人 → 士林、西門町
			P: ["shilin", "dihua"], // 在地美食通 → 士林、迪化街
			J: ["dongqu", "ximending"], // 居酒屋愛好者 → 東區、西門町
			K: ["xinyi", "dongqu"], // 夜生活玩家 → 信義、東區
		};

		const districtIds = districtMapping[resultType] || ["shilin"];
		recommendedDistricts.value = districtIds
			.map((id) => districtData[id])
			.filter(Boolean);

		console.log("測驗結果:", quizResult.value);
		console.log("推薦商圈IDs:", districtIds);
		console.log("推薦商圈數據:", recommendedDistricts.value);

		currentScreen.value = "result";
	};

	// 取得預算範圍
	const getBudgetRange = (profile) => {
		if (profile.budget === "high") {
			return "NT$ 1,000-3,000";
		} else if (profile.budget === "low") {
			return "NT$ 300-1,000";
		} else if (profile.activity === "food") {
			return profile.foodStyle === "popular"
				? "NT$ 200-600"
				: "NT$ 100-400";
		} else if (profile.activity === "drinks") {
			return profile.drinkStyle === "modern"
				? "NT$ 500-1,500"
				: "NT$ 300-800";
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
				insights.push("你注重品質與品味，願意為優質體驗投資");
			} else {
				insights.push("你善於發現物超所值的好東西，是個聰明的消費者");
			}
		} else if (profile.activity === "culture") {
			if (profile.style === "traditional") {
				insights.push("你對歷史文化有深厚興趣，喜歡探索傳統之美");
			} else {
				insights.push("你被現代創意吸引，追求新穎的文化體驗");
			}
		} else if (profile.activity === "nature") {
			if (profile.relaxStyle === "active") {
				insights.push("你喜歡主動的休閒方式，追求身心的全面放鬆");
			} else {
				insights.push("你偏好靜態的休憩時光，享受寧靜致遠的雅緻");
			}
		} else if (profile.activity === "food") {
			if (profile.foodStyle === "popular") {
				insights.push("你樂於嘗試熱門美食，享受與人分享的樂趣");
			} else {
				insights.push("你是個美食探險家，喜歡發掘隱藏的在地美味");
			}
		} else if (profile.activity === "drinks") {
			if (profile.drinkStyle === "traditional") {
				insights.push("你偏愛溫馨的飲酒環境，重視人情味與氛圍");
			} else {
				insights.push("你追求現代化的夜生活體驗，喜歡時尚潮流");
			}
		} else if (profile.activity === "chill") {
			if (profile.chillStyle === "nostalgic") {
				insights.push("你是個懷舊的浪漫主義者，被歷史故事深深吸引");
			} else {
				insights.push("你嚮往都會的現代美感，享受城市的繁華與精緻");
			}
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

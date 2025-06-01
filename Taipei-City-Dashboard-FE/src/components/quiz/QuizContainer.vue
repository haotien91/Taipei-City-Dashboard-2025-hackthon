<template>
	<div class="quiz-container">
		<!-- 歡迎頁面 -->
		<div v-if="currentScreen === 'intro'" class="quiz-intro">
			<div class="quiz-intro-content">
				<h1>
					<span class="subtitle">探索最適合你的個性化商圈</span>
				</h1>
				<h5>
					透過簡單的心理測驗，分析你的消費習慣、生活偏好與興趣類型，為你推薦最符合個性的台北商圈。每個商圈都有獨特的魅力等待你發現！
				</h5>
				<div class="intro-buttons">
					<button class="quiz-start-btn" @click="startQuiz">
						<span>play_arrow</span>
						開始測驗
					</button>
				</div>
			</div>
		</div>

		<!-- 問題頁面 -->
		<transition name="fade" mode="out-in">
			<div
				v-if="currentScreen === 'question'"
				class="quiz-question-container"
			>
				<QuizQuestion
					:question="questions[currentQuestion]"
					:question-number="currentQuestion + 1"
					:total-questions="totalQuestions"
					@answer="handleAnswer"
					@back="goBack"
					:can-go-back="currentQuestion > 0"
				/>
			</div>
		</transition>

		<!-- 結果頁面 -->
		<transition name="fade" mode="out-in">
			<div
				v-if="currentScreen === 'result'"
				class="quiz-result-container"
			>
				<QuizResult
					:result="quizResult"
					:recommended-districts="recommendedDistricts"
					@show-detail="showDistrictDetail"
				/>
			</div>
		</transition>

		<!-- 商圈詳情彈窗 -->
		<DistrictDetail
			v-if="showDetailModal"
			:district="selectedDistrict"
			@close="closeDistrictDetail"
		/>
	</div>
</template>

<script setup>
import { ref, computed, watch } from "vue";
import { useQuiz } from "../../composables/useQuiz.js";
import QuizProgress from "./QuizProgress.vue";
import QuizQuestion from "./QuizQuestion.vue";
import QuizResult from "./QuizResult.vue";
import DistrictDetail from "./DistrictDetail.vue";

// 使用 composable
const {
	currentScreen,
	currentQuestion,
	questions,
	totalQuestions,
	answers,
	quizResult,
	recommendedDistricts,
	startQuiz,
	handleAnswer,
	goBack,
	restartQuiz,
	calculateResult,
} = useQuiz();

// 詳情彈窗控制
const showDetailModal = ref(false);
const selectedDistrict = ref(null);

function showDistrictDetail(district) {
	selectedDistrict.value = district;
	showDetailModal.value = true;
}

function closeDistrictDetail() {
	showDetailModal.value = false;
	selectedDistrict.value = null;
}

// 監聽數據變化，確保選項可見
watch(
	() => currentQuestion.value,
	(newValue) => {
		console.log("當前問題變更為:", newValue);
		console.log("當前問題數據:", questions.value[newValue]);

		// 驗證問題數據完整性
		if (!questions.value[newValue]) {
			console.error("無效問題索引:", newValue);
			return;
		}

		// 驗證選項數據
		const currentOptions = questions.value[newValue].options;
		console.log("當前問題選項:", currentOptions?.length || 0);

		if (!currentOptions || currentOptions.length === 0) {
			console.error("當前問題缺少選項數據");
		}
	},
	{ immediate: true }
);

// 監聽questions陣列變化
watch(
	() => questions.value,
	(newQuestions) => {
		console.log("questions陣列更新:", newQuestions);
		console.log("questions數量:", newQuestions?.length || 0);
		if (newQuestions && newQuestions.length > 0) {
			console.log("第一個問題:", newQuestions[0]);
			console.log(
				"第一個問題選項數量:",
				newQuestions[0]?.options?.length || 0
			);
		}
	},
	{ immediate: true, deep: true }
);
</script>

<style scoped lang="scss">
.quiz-container {
	width: 100%;
	height: 100%;
	display: flex;
	flex-direction: column;
	background-color: var(--color-component-background);
	color: var(--color-complement-text);
	font-family: var(--font-family);
	overflow: hidden;
	position: relative; // 確保定位上下文正確
}

// 淡入淡出動畫效果
.fade-enter-active,
.fade-leave-active {
	transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
	opacity: 0;
}

.quiz-intro {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 2rem;
	background: linear-gradient(
		135deg,
		rgba(99, 102, 241, 0.25),
		rgba(168, 85, 247, 0.25),
		rgba(236, 72, 153, 0.25)
	);
	border-radius: 16px;
	margin: 16px;
	position: relative;
	overflow: hidden;

	&::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: radial-gradient(
				circle at 20% 80%,
				rgba(120, 119, 198, 0.3) 0%,
				transparent 50%
			),
			radial-gradient(
				circle at 80% 20%,
				rgba(255, 119, 198, 0.3) 0%,
				transparent 50%
			);
		pointer-events: none;
	}
}

.quiz-intro-content {
	text-align: center;
	max-width: 500px;
	position: relative;
	z-index: 1;

	h1 {
		color: white;
		font-size: var(--font-xl);
		font-weight: 700;
		margin-bottom: 1rem;
		line-height: 1.3;
		text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);

		.subtitle {
			display: block;
			font-size: var(--font-l);
			font-weight: 500;
			opacity: 0.85;
			margin-top: 8px;
			line-height: 1.4;
		}
	}

	h5 {
		color: white;
		font-size: var(--font-s);
		font-weight: 400;
		opacity: 0.9;
		line-height: 1.6;
		margin-bottom: 2rem;
		text-shadow: 0 1px 5px rgba(0, 0, 0, 0.2);
	}
}

.intro-buttons {
	display: flex;
	gap: 16px;
	justify-content: center;
	flex-wrap: wrap;
}

.quiz-start-btn {
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 16px 32px;
	border: none;
	border-radius: 50px;
	font-size: var(--font-m);
	font-weight: 600;
	cursor: pointer;
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	text-decoration: none;
	position: relative;
	z-index: 2;
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	color: white;
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);

	span {
		font-family: var(--font-icon);
		font-size: 18px;
	}

	&:hover {
		transform: translateY(-2px);
		box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
		background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
		box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
	}

	&:active {
		transform: translateY(0);
	}
}

.quiz-question-container,
.quiz-result-container {
	display: flex;
	flex-direction: column;
	height: 100%;
	overflow: hidden;
	position: relative; // 確保內部元素定位正確
}

@media (max-width: 768px) {
	.quiz-intro {
		padding: var(--font-s);

		&-content {
			max-width: none;

			h1 {
				font-size: var(--font-l);

				.subtitle {
					font-size: var(--font-m);
					margin-top: 6px;
				}
			}

			h5 {
				font-size: 12px;
				margin-bottom: 1.5rem;
			}
		}

		&-features {
			grid-template-columns: 1fr;
			gap: var(--font-s);
		}
	}

	.quiz-start-btn {
		width: 100%;
		justify-content: center;
		padding: 14px 24px;
		font-size: 14px;
	}
}
</style>

<template>
	<div class="quiz-question">
		<!-- 精簡的問題展示 -->
		<div class="question-content">
			<div class="question-title">
				<h2>{{ question.text }} ({{ questionNumber }}/3)</h2>
				<p class="question-subtitle">
					{{ question.subtitle || "選擇最符合你想法的選項" }}
				</p>
			</div>

			<!-- 答題選項區域 - 主要空間 -->
			<div class="question-options">
				<button
					v-for="option in question.options"
					:key="option.id"
					class="option-button"
					@click="selectOption(option)"
				>
					<div class="option-content">
						<div class="option-header">
							<span class="option-emoji">{{ option.emoji }}</span>
							<h4 class="option-title">{{ option.text }}</h4>
						</div>
						<p class="option-description">
							{{ option.description }}
						</p>
					</div>
				</button>

				<!-- 備用提示 -->
				<div
					v-if="!question.options || question.options.length === 0"
					class="no-options-warning"
				>
					<span>error</span>
					問題載入中，請稍候...
				</div>
			</div>
		</div>
	</div>
</template>

<script setup>
import { defineProps, defineEmits, onMounted } from "vue";

const props = defineProps({
	question: {
		type: Object,
		required: true,
	},
	questionNumber: {
		type: Number,
		required: true,
	},
	totalQuestions: {
		type: Number,
		required: true,
	},
	canGoBack: {
		type: Boolean,
		default: false,
	},
});

const emit = defineEmits(["answer", "back"]);

function selectOption(option) {
	console.log("選項被點擊:", option);

	// 增加觸覺反饋效果
	if (navigator.vibrate) {
		navigator.vibrate(50);
	}

	emit("answer", option);
}

onMounted(() => {
	console.log("QuizQuestion mounted - Question data:", props.question);

	if (!props.question?.options || props.question.options.length === 0) {
		console.error("問題選項缺失或為空數組");
	}
});
</script>

<style scoped lang="scss">
.quiz-question {
	display: flex;
	flex-direction: column;
	height: 100%;
	padding: 12px;
	max-width: 650px;
	margin: 0 auto;
	overflow: hidden;
}

.question-content {
	flex: 1;
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.question-title {
	flex-shrink: 0;
	text-align: center;
	margin-bottom: 20px;

	h2 {
		color: white;
		font-size: 16px;
		font-weight: 600;
		line-height: 1.3;
		margin-bottom: 8px;
		word-wrap: break-word;
	}

	.question-subtitle {
		color: white;
		font-size: 12px;
		opacity: 0.7;
		font-weight: 400;
		line-height: 1.4;
		word-wrap: break-word;
	}
}

.question-options {
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 12px;
	overflow-y: auto;
	padding-right: 4px;

	&::-webkit-scrollbar {
		width: 3px;
	}
	&::-webkit-scrollbar-thumb {
		background-color: rgba(255, 255, 255, 0.2);
		border-radius: 2px;
	}
}

.option-button {
	width: 100%;
	padding: 18px 16px;
	background: linear-gradient(
		135deg,
		rgba(255, 255, 255, 0.08),
		rgba(255, 255, 255, 0.04)
	);
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 12px;
	cursor: pointer;
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	position: relative;
	overflow: hidden;
	min-height: auto;

	&:hover {
		background: linear-gradient(
			135deg,
			rgba(255, 255, 255, 0.12),
			rgba(255, 255, 255, 0.08)
		);
		border-color: rgba(255, 255, 255, 0.25);
		transform: translateY(-1px);
		box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
	}

	&:active {
		transform: translateY(0);
	}
}

.option-content {
	display: flex;
	flex-direction: column;
	gap: 10px;
	width: 100%;
	text-align: left;
}

.option-header {
	display: flex;
	align-items: flex-start;
	gap: 12px;
	min-height: 24px;
}

.option-emoji {
	font-size: 20px;
	flex-shrink: 0;
	line-height: 1.2;
	filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.3));
	margin-top: 2px;
}

.option-title {
	font-size: 15px;
	font-weight: 600;
	color: white;
	margin: 0;
	line-height: 1.3;
	word-wrap: break-word;
	flex: 1;
	white-space: normal;
}

.option-description {
	color: white;
	font-size: 12px;
	opacity: 0.7;
	line-height: 1.4;
	margin: 0;
	word-wrap: break-word;
	white-space: normal;
	overflow: visible;
}

.no-options-warning {
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 8px;
	color: var(--color-highlight);
	padding: 16px;
	border: 1px dashed var(--color-highlight);
	border-radius: 8px;
	text-align: center;
	font-weight: 500;

	span {
		font-family: var(--font-icon);
		font-size: 14px;
	}
}

.question-navigation {
	flex-shrink: 0;
	margin-top: 16px;
	padding-top: 12px;
	border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.nav-button {
	display: flex;
	align-items: center;
	gap: 6px;
	padding: 8px 16px;
	background-color: rgba(255, 255, 255, 0.05);
	border: 1px solid rgba(255, 255, 255, 0.1);
	border-radius: 20px;
	color: var(--color-complement-text);
	font-size: 12px;
	cursor: pointer;
	transition: all 0.2s;

	&:hover {
		background-color: rgba(255, 255, 255, 0.1);
		color: var(--color-highlight);
	}

	span {
		font-family: var(--font-icon);
		font-size: 14px;
	}
}

// 響應式優化
@media (max-width: 768px) {
	.quiz-question {
		padding: 10px;
		max-width: 100%;
	}

	.question-title {
		margin-bottom: 16px;

		h2 {
			font-size: 14px;
		}

		.question-subtitle {
			font-size: 11px;
		}
	}

	.question-options {
		gap: 10px;
	}

	.option-button {
		padding: 16px 12px;
		border-radius: 10px;
	}

	.option-content {
		gap: 8px;
	}

	.option-emoji {
		font-size: 18px;
	}

	.option-title {
		font-size: 14px;
	}

	.option-description {
		font-size: 11px;
	}
}
</style>

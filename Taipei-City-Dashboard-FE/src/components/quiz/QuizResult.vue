<template>
	<div class="quiz-result">
		<div class="quiz-result-header">
			<h2>🎯 你的類型：{{ result.name }}</h2>
			<br />
			<h4 class="result-description">{{ result.description }}</h4>
			<p class="result-insights">
				{{
					result.personalityInsights &&
					result.personalityInsights.length > 0
						? result.personalityInsights.join("，")
						: ""
				}}
			</p>

			<!-- 推薦商圈區域 -->
			<div class="recommended-districts-info">
				<div class="districts-inline">
					<span class="label">推薦：</span>
					<span
						v-for="(district, index) in recommendedDistricts"
						:key="district.id"
						class="district-link"
						@click="showDistrictInfo(district)"
					>
						<img
							:src="getDistrictImage(district)"
							:alt="district.name"
							class="district-thumb"
							@error="handleImageError"
						/>
						{{ district.name }}
						{{
							index < recommendedDistricts.length - 1 ? "、" : ""
						}}
					</span>
				</div>
			</div>
		</div>
	</div>
</template>

<script setup>
import { defineProps, defineEmits } from "vue";
import { useDialogStore } from "../../store/dialogStore";

const props = defineProps({
	result: {
		type: Object,
		required: true,
	},
	recommendedDistricts: {
		type: Array,
		required: true,
	},
});

const emit = defineEmits(["show-detail"]);

const dialogStore = useDialogStore();

function showDetail(district) {
	emit("show-detail", district);
}

function showDistrictInfo(district) {
	// 使用新的商圈對話框顯示詳細資訊
	dialogStore.selectedDistrict = district;
	dialogStore.dialogs.districtDetail = true;
}

// 根據商圈 ID 生成圖片路徑
function getDistrictImage(district) {
	return `/images/business_district/${district.id}.jpg`;
}

function handleImageError(event) {
	event.target.src = "/images/default-district.jpg";
}
</script>

<style scoped lang="scss">
.quiz-result {
	display: flex;
	flex-direction: column;
	height: 100%;
	padding: 8px 16px;
	overflow: hidden;
}

.quiz-result-header {
	flex: 1;
	text-align: center;
	background: linear-gradient(
		135deg,
		rgba(255, 255, 255, 0.08),
		rgba(255, 255, 255, 0.02)
	);
	border: 1px solid rgba(255, 255, 255, 0.1);
	border-radius: 12px;
	padding: 16px 12px;
	backdrop-filter: blur(10px);
	overflow-y: auto;

	&::-webkit-scrollbar {
		width: 4px;
	}
	&::-webkit-scrollbar-thumb {
		background: linear-gradient(
			180deg,
			rgba(255, 255, 255, 0.3),
			rgba(255, 255, 255, 0.1)
		);
		border-radius: 4px;
	}
	&::-webkit-scrollbar-track {
		background: rgba(255, 255, 255, 0.05);
		border-radius: 4px;
	}

	h2 {
		color: white;
		font-size: 20px;
		font-weight: 700;
		margin-bottom: 6px;
		line-height: 1.3;
	}

	.result-description {
		color: white;
		font-size: 16px;
		line-height: 1.4;
		opacity: 0.85;
		margin-bottom: 4px;
		text-align: center;
	}

	.result-insights {
		color: white;
		font-size: 14px;
		line-height: 1.3;
		opacity: 0.7;
		margin-bottom: 12px;
		text-align: center;
	}

	.recommended-districts-info {
		margin-top: 20px;
		background: rgba(255, 255, 255, 0.05);
		border-radius: 8px;
		padding: 10px 12px;
		border: 1px solid rgba(255, 255, 255, 0.1);

		.districts-inline {
			text-align: center;
			display: flex;
			justify-content: center;
			align-items: center;
			flex-wrap: wrap;
			gap: 4px;
			line-height: 1.5;

			.label {
				color: white;
				font-size: 13px;
				font-weight: 600;
				margin-right: 6px;
				flex-shrink: 0;
			}

			.district-link {
				color: var(--color-highlight);
				font-size: 13px;
				font-weight: 600;
				cursor: pointer;
				position: relative;
				display: inline-flex;
				align-items: center;
				transition: all 0.3s ease;
				white-space: nowrap;

				.district-thumb {
					width: 24px;
					height: 24px;
					object-fit: cover;
					border-radius: 4px;
					margin-right: 6px;
					background: rgba(255, 255, 255, 0.1);
					border: 1px solid rgba(255, 255, 255, 0.2);
					transition: all 0.3s ease;
				}

				&:hover {
					color: white;
					text-shadow: 0 0 8px var(--color-highlight);
					transform: scale(1.05);

					.district-thumb {
						border-color: var(--color-highlight);
						box-shadow: 0 0 8px rgba(var(--color-highlight), 0.3);
					}
				}

				&:active {
					transform: scale(0.98);
				}
			}
		}
	}
}

@media (max-width: 768px) {
	.quiz-result {
		padding: 12px;
	}

	.quiz-result-header {
		padding: 16px 12px;

		h2 {
			font-size: 16px;
		}

		.result-description {
			font-size: 13px;
		}

		.result-insights {
			font-size: 12px;
		}

		.recommended-districts-info {
			margin-top: 12px;
			padding: 10px 12px;

			.districts-inline {
				gap: 3px;

				.label {
					font-size: 12px;
				}

				.district-link {
					font-size: 12px;

					.district-thumb {
						width: 20px;
						height: 20px;
						margin-right: 4px;
					}
				}
			}
		}
	}
}

@media (max-width: 480px) {
	.quiz-result {
		padding: 8px;
	}

	.quiz-result-header {
		padding: 12px 10px;

		h2 {
			font-size: 15px;
		}

		.recommended-districts-info {
			.districts-inline {
				gap: 2px;

				.district-link {
					font-size: 11px;

					.district-thumb {
						width: 18px;
						height: 18px;
						margin-right: 3px;
					}
				}

				.label {
					font-size: 11px;
				}
			}
		}
	}
}
</style>

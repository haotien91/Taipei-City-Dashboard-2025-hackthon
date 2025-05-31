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
						{{ district.name }}
						{{
							index < recommendedDistricts.length - 1 ? "、" : ""
						}}
					</span>
				</div>
			</div>
		</div>

		<div class="quiz-result-footer">
			<div class="result-actions">
				<button class="action-button secondary" @click="restart">
					<span>refresh</span>
					重新測驗
				</button>
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

const emit = defineEmits(["restart", "show-detail"]);

const dialogStore = useDialogStore();

function showDetail(district) {
	emit("show-detail", district);
}

function restart() {
	emit("restart");
}

function showDistrictInfo(district) {
	// 設置商圈資訊到 dialog store
	dialogStore.districtInfoContent = {
		districtName: district.name,
		description: district.description,
		location: district.location,
		tags: district.tags,
		highlights: district.highlights,
		transportation: district.transportation,
		spending: district.spending,
		timing: district.timing,
		image: district.image,
		rating: district.rating,
		// 可以在這裡添加活動資訊，暫時為空
		events: [],
	};

	// 顯示對話框
	dialogStore.dialogs.districtInfo = true;
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
	gap: 12px;
}

.quiz-result-header {
	flex-shrink: 0;
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
			gap: 2px;

			.label {
				color: white;
				font-size: 13px;
				font-weight: 600;
				margin-right: 6px;
			}

			.district-link {
				color: var(--color-highlight);
				font-size: 13px;
				font-weight: 600;
				cursor: pointer;
				position: relative;
				display: inline;
				transition: all 0.3s ease;

				&:hover {
					color: white;
					text-shadow: 0 0 8px var(--color-highlight);
					transform: scale(1.05);
				}

				&:active {
					transform: scale(0.98);
				}
			}
		}
	}
}

.quiz-result-content {
	flex: 1;
	display: flex;
	flex-direction: column;
	overflow: hidden;
	min-height: 0;

	h3 {
		flex-shrink: 0;
		color: white;
		font-size: 16px;
		font-weight: 600;
		margin-bottom: 10px;
		text-align: center;
	}

	.recommended-districts {
		flex: 1;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		gap: 10px;
		overflow-y: auto;
		padding-right: 4px;
		min-height: 200px;

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

		.district-card {
			background: linear-gradient(
				135deg,
				rgba(255, 255, 255, 0.08),
				rgba(255, 255, 255, 0.02)
			);
			border: 1px solid rgba(255, 255, 255, 0.15);
			border-radius: 10px;
			overflow: hidden;
			cursor: pointer;
			transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
			height: fit-content;
			backdrop-filter: blur(10px);

			&:hover {
				background: linear-gradient(
					135deg,
					rgba(255, 255, 255, 0.12),
					rgba(255, 255, 255, 0.06)
				);
				border-color: var(--color-highlight);
				transform: translateY(-2px);
				box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
			}

			.district-image {
				position: relative;
				height: 120px;
				overflow: hidden;

				img {
					width: 100%;
					height: 100%;
					object-fit: cover;
					transition: transform 0.3s ease;
				}

				.district-overlay {
					position: absolute;
					top: 0;
					right: 0;
					bottom: 0;
					left: 0;
					background: linear-gradient(
						to bottom,
						rgba(0, 0, 0, 0.1),
						rgba(0, 0, 0, 0.4)
					);
					display: flex;
					align-items: center;
					justify-content: center;
					opacity: 0;
					transition: opacity 0.3s ease;

					span {
						font-family: var(--font-icon);
						font-size: 18px;
						color: white;
						background: rgba(255, 255, 255, 0.2);
						border-radius: 50%;
						width: 36px;
						height: 36px;
						display: flex;
						align-items: center;
						justify-content: center;
						backdrop-filter: blur(10px);
					}
				}

				&:hover .district-overlay {
					opacity: 1;
				}

				&:hover img {
					transform: scale(1.05);
				}
			}

			.district-info {
				padding: 12px;

				.clickable-title {
					color: var(--color-highlight);
					font-size: 15px;
					font-weight: 700;
					margin-bottom: 6px;
					line-height: 1.3;
					cursor: pointer;
					transition: all 0.3s ease;
					text-decoration: underline;
					text-underline-offset: 2px;
					text-decoration-thickness: 1px;

					&:hover {
						color: white;
						text-shadow: 0 0 8px var(--color-highlight);
						transform: scale(1.02);
					}
				}

				.district-tags {
					display: flex;
					flex-wrap: wrap;
					gap: 4px;
					margin-bottom: 10px;

					.tag {
						padding: 2px 6px;
						background: linear-gradient(
							135deg,
							var(--color-highlight),
							rgba(var(--color-highlight), 0.8)
						);
						color: white;
						border-radius: 10px;
						font-size: 9px;
						font-weight: 500;
						opacity: 0.9;
					}
				}

				.district-meta {
					display: flex;
					justify-content: space-between;
					align-items: center;

					.meta-item {
						display: flex;
						align-items: center;
						gap: 3px;
						color: white;
						font-size: 10px;
						opacity: 0.7;

						span:first-child {
							font-family: var(--font-icon);
							font-size: 12px;
							color: var(--color-highlight);
						}
					}
				}
			}
		}
	}
}

.quiz-result-footer {
	flex-shrink: 0;
	border-top: 1px solid rgba(255, 255, 255, 0.1);
	padding-top: 8px;

	.result-actions {
		display: flex;
		justify-content: center;

		.action-button {
			display: flex;
			align-items: center;
			gap: 6px;
			padding: 10px 16px;
			border: 1px solid rgba(255, 255, 255, 0.2);
			border-radius: 20px;
			font-size: 11px;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
			justify-content: center;

			span {
				font-family: var(--font-icon);
				font-size: 14px;
			}

			&.secondary {
				background: linear-gradient(
					135deg,
					rgba(255, 255, 255, 0.08),
					rgba(255, 255, 255, 0.02)
				);
				color: white;
				backdrop-filter: blur(10px);

				&:hover {
					background: linear-gradient(
						135deg,
						rgba(255, 255, 255, 0.12),
						rgba(255, 255, 255, 0.06)
					);
					border-color: rgba(255, 255, 255, 0.3);
					transform: translateY(-1px);
					box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
				}
			}
		}
	}
}

@media (max-width: 768px) {
	.quiz-result {
		padding: 12px;
		gap: 12px;
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

			.districts-inline .label {
				font-size: 12px;
			}

			.districts-inline .district-link {
				font-size: 12px;
			}
		}
	}

	.quiz-result-content {
		h3 {
			font-size: 16px;
			margin-bottom: 10px;
		}

		.recommended-districts {
			grid-template-columns: 1fr;
			gap: 10px;

			.district-card {
				.district-image {
					height: 120px;
				}

				.district-info {
					padding: 12px;

					.clickable-title {
						font-size: 15px;
						margin-bottom: 6px;
					}

					.district-tags {
						gap: 4px;
						margin-bottom: 10px;

						.tag {
							padding: 2px 6px;
							font-size: 9px;
						}
					}

					.district-meta .meta-item {
						font-size: 10px;

						span:first-child {
							font-size: 12px;
						}
					}
				}
			}
		}
	}

	.quiz-result-footer {
		padding-top: 12px;

		.result-actions {
			flex-direction: column;
			gap: 10px;

			.action-button {
				width: 100%;
				padding: 10px 16px;
				font-size: 11px;

				span {
					font-size: 14px;
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

		.recommended-districts-info .districts-inline .district-link {
			font-size: 11px;
		}

		.recommended-districts-info .districts-inline .label {
			font-size: 11px;
		}
	}

	.quiz-result-content .recommended-districts {
		.district-card .district-info {
			padding: 10px;

			.district-tags .tag {
				font-size: 8px;
			}
		}
	}
}
</style>

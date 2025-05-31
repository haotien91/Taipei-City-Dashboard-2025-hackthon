<template>
	<div class="quiz-result">
		<div class="quiz-result-header">
			<h2>🎯 你的類型：{{ result.name }}</h2>
			<p class="result-description">{{ result.description }}</p>
			<p class="result-tagline">{{ result.tagline }}</p>

			<!-- 簡化的個性洞察區域 -->
			<div
				v-if="
					result.personalityInsights &&
					result.personalityInsights.length > 0
				"
				class="personality-insights"
			>
				<h5>💡 個性洞察</h5>
				<ul class="insights-list">
					<li
						v-for="insight in result.personalityInsights"
						:key="insight"
					>
						{{ insight }}
					</li>
				</ul>
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

function showDetail(district) {
	emit("show-detail", district);
}

function restart() {
	emit("restart");
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
		font-size: 17px;
		font-weight: 700;
		margin-bottom: 6px;
		line-height: 1.3;
	}

	.result-description {
		color: white;
		font-size: 13px;
		line-height: 1.4;
		opacity: 0.85;
		margin-bottom: 4px;
		text-align: center;
	}

	.result-tagline {
		color: white;
		font-size: 12px;
		line-height: 1.3;
		opacity: 0.7;
		margin-bottom: 12px;
		text-align: center;
	}

	.personality-insights {
		margin-top: 12px;
		background: rgba(255, 255, 255, 0.05);
		border-radius: 8px;
		padding: 10px 12px;
		border: 1px solid rgba(255, 255, 255, 0.1);

		h5 {
			color: white;
			font-size: 13px;
			font-weight: 600;
			margin-bottom: 6px;
			text-align: center;
		}

		.insights-list {
			list-style: none;
			padding: 0;
			margin: 0;
			text-align: center;

			li {
				color: white;
				font-size: 11px;
				line-height: 1.5;
				opacity: 0.8;
				margin-bottom: 4px;
				position: relative;

				&:last-child {
					margin-bottom: 0;
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
		font-size: 15px;
		font-weight: 600;
		margin-bottom: 8px;
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

				h4 {
					color: white;
					font-size: 14px;
					font-weight: 600;
					margin-bottom: 6px;
					line-height: 1.3;
				}

				.district-tags {
					display: flex;
					flex-wrap: wrap;
					gap: 4px;
					margin-bottom: 8px;

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
	padding-top: 10px;

	.result-actions {
		display: flex;
		justify-content: center;

		.action-button {
			display: flex;
			align-items: center;
			gap: 6px;
			padding: 10px 24px;
			border: 1px solid rgba(255, 255, 255, 0.2);
			border-radius: 20px;
			font-size: 12px;
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

		.result-tagline {
			font-size: 12px;
		}

		.personality-insights {
			margin-top: 12px;
			padding: 10px 12px;

			h5 {
				font-size: 13px;
			}

			.insights-list li {
				font-size: 11px;
				margin-bottom: 4px;
			}
		}
	}

	.quiz-result-content {
		h3 {
			font-size: 15px;
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

					h4 {
						font-size: 14px;
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

		.personality-insights .insights-list li {
			font-size: 10px;
			padding-left: 12px;
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

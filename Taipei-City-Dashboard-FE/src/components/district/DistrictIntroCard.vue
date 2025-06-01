<template>
	<div class="district-card" @click="handleClick">
		<div class="card-content">
			<div class="info-section">
				<div class="header">
					<h2 class="district-name">{{ district.name }}</h2>
					<p class="tagline">{{ district.tagline }}</p>
				</div>

				<div class="description">
					<p>{{ district.description }}</p>
					<p class="cta">{{ district.cta }}</p>
				</div>

				<div class="hashtags">
					<span
						v-for="tag in district.hashtags"
						:key="tag"
						class="hashtag"
						@click.stop="handleHashtagClick(tag)"
					>
						{{ tag }}
					</span>
				</div>
			</div>

			<div class="image-section">
				<img
					:src="districtImage"
					:alt="district.name"
					@error="handleImageError"
				/>
				<div class="image-overlay">
					<span class="explore-icon">explore</span>
				</div>
			</div>
		</div>
	</div>
</template>

<script setup>
import { defineProps, defineEmits, onMounted, computed } from "vue";

const props = defineProps({
	district: {
		type: Object,
		required: true,
	},
});

const emit = defineEmits(["click", "hashtag-click"]);

// 根據商圈 ID 生成圖片路徑
const districtImage = computed(() => {
	return `/images/business_district/${props.district.id}.jpg`;
});

// 調試用：檢查傳入的數據
onMounted(() => {
	console.log("DistrictIntroCard received district data:", props.district);
	if (!props.district.description) {
		console.warn("Warning: district.description is missing!");
	}
	if (!props.district.hashtags || props.district.hashtags.length === 0) {
		console.warn("Warning: district.hashtags is missing or empty!");
	}
});

function handleClick() {
	emit("click", props.district);
}

function handleHashtagClick(tag) {
	emit("hashtag-click", tag);
}

function handleImageError(event) {
	event.target.src = "/images/default-district.jpg";
}
</script>

<style scoped lang="scss">
.district-card {
	width: 100%;
	max-width: 900px;
	margin: 0 auto;
	background: linear-gradient(
		135deg,
		rgba(255, 255, 255, 0.08),
		rgba(255, 255, 255, 0.02)
	);
	backdrop-filter: blur(10px);
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 16px;
	overflow: hidden;
	box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
	cursor: pointer;
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

	&:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 48px rgba(0, 0, 0, 0.15);
		border-color: var(--color-highlight);
	}

	.card-content {
		display: flex;
		min-height: 400px;

		.info-section {
			flex: 1;
			padding: 40px;
			display: flex;
			flex-direction: column;
			justify-content: space-between;
			overflow: visible;

			.header {
				flex-shrink: 0;

				.district-name {
					font-size: 28px;
					font-weight: 700;
					color: white;
					margin-bottom: 8px;
					line-height: 1.2;
				}

				.tagline {
					font-size: 18px;
					color: var(--color-highlight);
					font-weight: 500;
					opacity: 0.9;
					margin-bottom: 0;
				}
			}

			.description {
				flex: 1;
				margin: 20px 0;
				display: flex;
				flex-direction: column;
				justify-content: center;
				min-height: 120px;

				p {
					color: rgba(255, 255, 255, 0.85);
					line-height: 1.6;
					font-size: 14px;
					margin-bottom: 0;
					word-wrap: break-word;
				}

				.cta {
					margin-top: 12px;
					font-weight: 600;
					color: var(--color-highlight);
					font-size: 15px;
					letter-spacing: 0.3px;
				}
			}

			.hashtags {
				flex-shrink: 0;
				display: flex;
				gap: 10px;
				flex-wrap: wrap;
				margin-top: auto;

				.hashtag {
					padding: 6px 14px;
					background: rgba(255, 255, 255, 0.08);
					border: 1px solid rgba(255, 255, 255, 0.3);
					border-radius: 20px;
					color: white;
					font-size: 13px;
					font-weight: 500;
					transition: all 0.3s ease;
					cursor: pointer;
					white-space: nowrap;

					&:hover {
						background: var(--color-highlight);
						border-color: var(--color-highlight);
						transform: translateY(-2px);
						box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
					}
				}
			}
		}

		.image-section {
			flex: 1.2;
			position: relative;
			overflow: hidden;
			background: linear-gradient(135deg, #1a1a1a, #2a2a2a);
			min-height: 400px;

			img {
				width: 100%;
				height: 100%;
				object-fit: cover;
				transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
			}

			.image-overlay {
				position: absolute;
				top: 0;
				left: 0;
				right: 0;
				bottom: 0;
				background: linear-gradient(
					to bottom,
					rgba(0, 0, 0, 0) 0%,
					rgba(0, 0, 0, 0.3) 100%
				);
				display: flex;
				align-items: center;
				justify-content: center;
				opacity: 0;
				transition: opacity 0.3s ease;

				.explore-icon {
					font-family: var(--font-icon);
					font-size: 48px;
					color: white;
					background: rgba(255, 255, 255, 0.2);
					width: 80px;
					height: 80px;
					border-radius: 50%;
					display: flex;
					align-items: center;
					justify-content: center;
					backdrop-filter: blur(10px);
					transform: scale(0.8);
					transition: transform 0.3s ease;
				}
			}

			&:hover {
				img {
					transform: scale(1.08);
				}
			}
		}
	}
}

// 響應式設計
@media (max-width: 768px) {
	.district-card {
		.card-content {
			flex-direction: column;
			min-height: auto;

			.image-section {
				height: 240px;
				min-height: 240px;
				order: -1;
			}

			.info-section {
				padding: 24px;

				.header {
					.district-name {
						font-size: 24px;
					}

					.tagline {
						font-size: 16px;
					}
				}

				.description {
					margin: 16px 0;
					min-height: auto;

					p {
						font-size: 13px;
					}

					.cta {
						font-size: 14px;
					}
				}

				.hashtags {
					gap: 8px;

					.hashtag {
						padding: 4px 12px;
						font-size: 12px;
					}
				}
			}
		}
	}
}

@media (max-width: 480px) {
	.district-card {
		.card-content {
			.image-section {
				height: 200px;
				min-height: 200px;
			}

			.info-section {
				padding: 20px;

				.header {
					.district-name {
						font-size: 22px;
					}

					.tagline {
						font-size: 15px;
					}
				}

				.description {
					p {
						font-size: 12px;
						line-height: 1.5;
					}

					.cta {
						font-size: 13px;
					}
				}

				.hashtags {
					.hashtag {
						font-size: 11px;
						padding: 3px 10px;
					}
				}
			}
		}
	}
}
</style>

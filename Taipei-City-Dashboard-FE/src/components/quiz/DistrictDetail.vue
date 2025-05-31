<template>
	<div class="district-detail-modal" @click="closeModal">
		<div class="modal-content" @click.stop>
			<div class="modal-header">
				<h2>{{ district.name }}</h2>
				<button class="close-btn" @click="closeModal">
					<span>close</span>
				</button>
			</div>

			<div class="modal-body">
				<!-- 商圈圖片 -->
				<div class="district-image-container">
					<img
						:src="district.image"
						:alt="district.name"
						@error="handleImageError"
						class="district-image"
					/>
					<div class="image-overlay">
						<div class="district-rating">
							<span class="star-icon">star</span>
							<span>{{ district.rating }}</span>
						</div>
					</div>
				</div>

				<!-- 商圈資訊 -->
				<div class="district-info">
					<div class="info-section">
						<h3>商圈特色</h3>
						<p class="description">{{ district.description }}</p>
						<div class="tags-container">
							<span
								v-for="tag in district.tags"
								:key="tag"
								class="tag"
							>
								{{ tag }}
							</span>
						</div>
					</div>

					<div class="info-section">
						<h3>亮點介紹</h3>
						<ul class="highlights-list">
							<li
								v-for="highlight in district.highlights"
								:key="highlight"
							>
								{{ highlight }}
							</li>
						</ul>
					</div>

					<div class="info-grid">
						<div class="info-item">
							<div class="info-label">
								<span class="icon">location_on</span>
								<span>位置</span>
							</div>
							<div class="info-value">
								{{ district.location }}
							</div>
						</div>

						<div class="info-item">
							<div class="info-label">
								<span class="icon">schedule</span>
								<span>營業時間</span>
							</div>
							<div class="info-value">
								<div>
									平日：{{
										district.timing?.weekday ||
										"10:00-22:00"
									}}
								</div>
								<div>
									假日：{{
										district.timing?.weekend ||
										"10:00-23:00"
									}}
								</div>
							</div>
						</div>

						<div class="info-item">
							<div class="info-label">
								<span class="icon">train</span>
								<span>交通資訊</span>
							</div>
							<div class="info-value">
								<div v-if="district.transportation?.mrt">
									捷運：{{ district.transportation.mrt }}
								</div>
								<div v-if="district.transportation?.bus">
									公車：{{ district.transportation.bus }}
								</div>
							</div>
						</div>

						<div class="info-item">
							<div class="info-label">
								<span class="icon">account_balance_wallet</span>
								<span>消費參考</span>
							</div>
							<div class="info-value">
								<div v-if="district.spending?.dining">
									用餐：{{ district.spending.dining }}
								</div>
								<div v-if="district.spending?.shopping">
									購物：{{ district.spending.shopping }}
								</div>
								<div v-if="district.spending?.entertainment">
									娛樂：{{ district.spending.entertainment }}
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="modal-footer">
				<button class="action-btn primary" @click="openMaps">
					<span>map</span>
					在地圖中查看
				</button>
				<button class="action-btn secondary" @click="closeModal">
					<span>arrow_back</span>
					返回結果
				</button>
			</div>
		</div>
	</div>
</template>

<script setup>
import { defineProps, defineEmits } from "vue";

const props = defineProps({
	district: {
		type: Object,
		required: true,
	},
});

const emit = defineEmits(["close"]);

function closeModal() {
	emit("close");
}

function handleImageError(event) {
	event.target.src = "/images/default-district.jpg";
}

function openMaps() {
	// 開啟 Google Maps
	const query = encodeURIComponent(`${props.district.name} 台北`);
	window.open(`https://www.google.com/maps/search/${query}`, "_blank");
}
</script>

<style scoped lang="scss">
.district-detail-modal {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.7);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 1000;
	padding: 20px;
}

.modal-content {
	background: var(--color-component-background);
	border-radius: 16px;
	width: 100%;
	max-width: 600px;
	max-height: 90vh;
	overflow: hidden;
	display: flex;
	flex-direction: column;
	box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 24px;
	border-bottom: 1px solid var(--color-border);

	h2 {
		color: var(--color-complement-text);
		font-size: var(--font-l);
		font-weight: 600;
		margin: 0;
	}

	.close-btn {
		background: none;
		border: none;
		color: var(--color-complement-text);
		cursor: pointer;
		padding: 8px;
		border-radius: 50%;
		transition: background-color 0.2s;

		&:hover {
			background-color: rgba(255, 255, 255, 0.1);
		}

		span {
			font-family: var(--font-icon);
			font-size: 24px;
		}
	}
}

.modal-body {
	flex: 1;
	overflow-y: auto;
	padding: 0;

	&::-webkit-scrollbar {
		width: 6px;
	}
	&::-webkit-scrollbar-thumb {
		background-color: rgba(255, 255, 255, 0.2);
		border-radius: 3px;
	}
}

.district-image-container {
	position: relative;
	height: 240px;
	overflow: hidden;

	.district-image {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.image-overlay {
		position: absolute;
		top: 0;
		right: 0;
		bottom: 0;
		left: 0;
		background: linear-gradient(
			to bottom,
			rgba(0, 0, 0, 0.1),
			rgba(0, 0, 0, 0.6)
		);
		display: flex;
		align-items: flex-end;
		padding: 20px;
	}

	.district-rating {
		background: rgba(0, 0, 0, 0.6);
		color: white;
		padding: 8px 12px;
		border-radius: 20px;
		display: flex;
		align-items: center;
		gap: 4px;
		font-weight: 500;

		.star-icon {
			font-family: var(--font-icon);
			color: #ffd700;
		}
	}
}

.district-info {
	padding: 24px;
}

.info-section {
	margin-bottom: 24px;

	h3 {
		color: var(--color-complement-text);
		font-size: var(--font-m);
		font-weight: 600;
		margin-bottom: 12px;
	}

	.description {
		color: var(--color-complement-text);
		font-size: var(--font-s);
		line-height: 1.6;
		opacity: 0.8;
		margin-bottom: 16px;
	}

	.tags-container {
		display: flex;
		flex-wrap: wrap;
		gap: 8px;

		.tag {
			background: rgba(255, 255, 255, 0.1);
			color: var(--color-complement-text);
			padding: 6px 12px;
			border-radius: 12px;
			font-size: 12px;
			font-weight: 500;
		}
	}

	.highlights-list {
		list-style: none;
		padding: 0;
		margin: 0;

		li {
			color: var(--color-complement-text);
			font-size: var(--font-s);
			padding: 8px 0;
			padding-left: 20px;
			position: relative;
			opacity: 0.8;

			&:before {
				content: "•";
				color: var(--color-highlight);
				position: absolute;
				left: 0;
				font-weight: bold;
			}
		}
	}
}

.info-grid {
	display: grid;
	grid-template-columns: 1fr;
	gap: 20px;
}

.info-item {
	.info-label {
		display: flex;
		align-items: center;
		gap: 8px;
		color: var(--color-complement-text);
		font-size: var(--font-s);
		font-weight: 600;
		margin-bottom: 8px;

		.icon {
			font-family: var(--font-icon);
			color: var(--color-highlight);
		}
	}

	.info-value {
		color: var(--color-complement-text);
		font-size: var(--font-s);
		opacity: 0.8;
		line-height: 1.5;
		padding-left: 28px;

		div {
			margin-bottom: 4px;
		}
	}
}

.modal-footer {
	display: flex;
	gap: 12px;
	padding: 24px;
	border-top: 1px solid var(--color-border);

	.action-btn {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 8px;
		padding: 14px;
		border: 1px solid var(--color-border);
		border-radius: 8px;
		font-size: var(--font-s);
		font-weight: 500;
		cursor: pointer;
		transition: all 0.2s;

		span {
			font-family: var(--font-icon);
		}

		&.primary {
			background: var(--color-highlight);
			color: white;
			border-color: var(--color-highlight);

			&:hover {
				background: #5a67d8;
			}
		}

		&.secondary {
			background: rgba(255, 255, 255, 0.05);
			color: var(--color-complement-text);

			&:hover {
				background: rgba(255, 255, 255, 0.1);
			}
		}
	}
}

@media (max-width: 768px) {
	.district-detail-modal {
		padding: 10px;
	}

	.modal-content {
		max-height: 95vh;
	}

	.modal-header,
	.district-info,
	.modal-footer {
		padding: 16px;
	}

	.district-image-container {
		height: 200px;
	}

	.info-grid {
		grid-template-columns: 1fr;
		gap: 16px;
	}

	.modal-footer {
		.action-btn {
			font-size: 12px;
			padding: 12px;
		}
	}
}
</style>

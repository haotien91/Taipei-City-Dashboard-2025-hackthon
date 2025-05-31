<template>
	<div class="district-showcase">
		<div class="showcase-header" v-if="title">
			<h1>{{ title }}</h1>
			<p v-if="subtitle" class="subtitle">{{ subtitle }}</p>
		</div>

		<div class="filter-section" v-if="showFilters">
			<div class="filter-group">
				<span class="filter-label">篩選條件：</span>
				<button
					class="filter-btn"
					:class="{ active: activeFilter === 'all' }"
					@click="setFilter('all')"
				>
					全部
				</button>
				<button
					class="filter-btn"
					:class="{ active: activeFilter === 'high' }"
					@click="setFilter('high')"
				>
					高消費
				</button>
				<button
					class="filter-btn"
					:class="{ active: activeFilter === 'mid' }"
					@click="setFilter('mid')"
				>
					中消費
				</button>
				<button
					class="filter-btn"
					:class="{ active: activeFilter === 'low' }"
					@click="setFilter('low')"
				>
					低消費
				</button>
			</div>
		</div>

		<div class="districts-container">
			<transition-group
				name="district-fade"
				tag="div"
				class="districts-grid"
			>
				<div
					v-for="district in filteredDistricts"
					:key="district.id"
					class="district-wrapper"
				>
					<DistrictIntroCard
						:district="district"
						@click="handleDistrictClick"
						@hashtag-click="handleHashtagClick"
					/>
				</div>
			</transition-group>
		</div>

		<div v-if="filteredDistricts.length === 0" class="no-results">
			<span class="icon">search_off</span>
			<p>沒有符合條件的商圈</p>
		</div>
	</div>
</template>

<script setup>
import { ref, computed, defineProps } from "vue";
import DistrictIntroCard from "./DistrictIntroCard.vue";
import {
	getAllDistricts,
	getDistrictsBySpending,
} from "../../data/districts.js";

const props = defineProps({
	districts: {
		type: Array,
		default: () => getAllDistricts(),
	},
	title: {
		type: String,
		default: "",
	},
	subtitle: {
		type: String,
		default: "",
	},
	showFilters: {
		type: Boolean,
		default: false,
	},
});

const activeFilter = ref("all");
const searchTag = ref("");

const filteredDistricts = computed(() => {
	let result = props.districts;

	if (activeFilter.value !== "all") {
		const filterMap = {
			high: "高消費",
			mid: "中",
			low: "低",
		};
		result = result.filter((district) =>
			district.spending.includes(filterMap[activeFilter.value])
		);
	}

	if (searchTag.value) {
		result = result.filter((district) =>
			district.hashtags.some((tag) => tag.includes(searchTag.value))
		);
	}

	return result;
});

function setFilter(filter) {
	activeFilter.value = filter;
}

function handleDistrictClick(district) {
	// 可以導航到詳細頁面或顯示更多資訊
	console.log("District clicked:", district);
}

function handleHashtagClick(tag) {
	// 根據標籤篩選
	searchTag.value = tag.replace("#", "");
	console.log("Hashtag clicked:", tag);
}
</script>

<style scoped lang="scss">
.district-showcase {
	width: 100%;
	padding: 40px 20px;

	.showcase-header {
		text-align: center;
		margin-bottom: 40px;

		h1 {
			font-size: 36px;
			font-weight: 700;
			color: white;
			margin-bottom: 12px;
		}

		.subtitle {
			font-size: 18px;
			color: rgba(255, 255, 255, 0.7);
			line-height: 1.6;
		}
	}

	.filter-section {
		display: flex;
		justify-content: center;
		margin-bottom: 32px;

		.filter-group {
			display: flex;
			align-items: center;
			gap: 12px;
			background: rgba(255, 255, 255, 0.05);
			padding: 8px 16px;
			border-radius: 30px;
			border: 1px solid rgba(255, 255, 255, 0.1);

			.filter-label {
				color: rgba(255, 255, 255, 0.7);
				font-size: 14px;
				margin-right: 8px;
			}

			.filter-btn {
				padding: 6px 16px;
				background: transparent;
				border: 1px solid rgba(255, 255, 255, 0.2);
				border-radius: 20px;
				color: white;
				font-size: 14px;
				cursor: pointer;
				transition: all 0.3s ease;

				&:hover {
					background: rgba(255, 255, 255, 0.1);
					border-color: rgba(255, 255, 255, 0.3);
				}

				&.active {
					background: var(--color-highlight);
					border-color: var(--color-highlight);
					font-weight: 600;
				}
			}
		}
	}

	.districts-container {
		max-width: 1400px;
		margin: 0 auto;

		.districts-grid {
			display: flex;
			flex-direction: column;
			gap: 40px;
			align-items: center;
		}

		.district-wrapper {
			width: 100%;
			max-width: 900px;
		}
	}

	.no-results {
		text-align: center;
		padding: 80px 20px;
		color: rgba(255, 255, 255, 0.5);

		.icon {
			font-family: var(--font-icon);
			font-size: 64px;
			display: block;
			margin-bottom: 16px;
		}

		p {
			font-size: 18px;
		}
	}
}

// 過渡動畫
.district-fade-enter-active,
.district-fade-leave-active {
	transition: all 0.3s ease;
}

.district-fade-enter-from,
.district-fade-leave-to {
	opacity: 0;
	transform: translateY(20px);
}

@media (max-width: 768px) {
	.district-showcase {
		padding: 24px 16px;

		.showcase-header {
			margin-bottom: 24px;

			h1 {
				font-size: 28px;
			}

			.subtitle {
				font-size: 16px;
			}
		}

		.filter-section .filter-group {
			flex-wrap: wrap;
			justify-content: center;
			padding: 12px;

			.filter-btn {
				padding: 4px 12px;
				font-size: 13px;
			}
		}

		.districts-container .districts-grid {
			gap: 24px;
		}
	}
}
</style>

<template>
	<div class="district-showcase-view">
		<DistrictShowcase
			:title="'台北商圈巡禮'"
			:subtitle="'探索台北各具特色的商圈，找到最適合你的生活風格'"
			:show-filters="true"
		/>
	</div>
</template>

<script setup>
import DistrictShowcase from "../components/district/DistrictShowcase.vue";
</script>

<style scoped lang="scss">
.district-showcase-view {
	width: 100%;
	min-height: 100vh;
	background: linear-gradient(135deg, #1a1a1a, #2a2a2a);
	padding-top: 60px; // 留出 navbar 空間
}
</style>

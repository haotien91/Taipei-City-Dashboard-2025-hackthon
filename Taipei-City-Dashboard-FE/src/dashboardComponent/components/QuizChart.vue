<template>
	<div v-if="activeChart === 'QuizChart'" class="quiz-chart">
		<QuizContainer />
	</div>
</template>

<script setup>
import QuizContainer from "../../components/quiz/QuizContainer.vue";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
	"map_config",
	"map_filter",
	"map_filter_on",
]);

const emits = defineEmits([
	"filterByParam",
	"filterByLayer",
	"clearByParamFilter",
	"clearByLayerFilter",
	"fly",
]);
</script>

<style scoped lang="scss">
.quiz-chart {
	width: 100%;
	height: 100%;
	display: flex;
	flex-direction: column;
	background-color: var(--color-component-background);
	overflow: hidden;
	border-radius: 5px;
}
</style>

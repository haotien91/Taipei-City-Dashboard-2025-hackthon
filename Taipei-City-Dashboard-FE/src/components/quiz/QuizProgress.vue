<template>
	<div class="quiz-progress-compact">
		<div class="progress-info">
			<span class="current-step">{{ current }}</span>
			<div class="progress-bar">
				<div
					class="progress-fill"
					:style="{ width: progress + '%' }"
				></div>
			</div>
			<span class="total-steps">{{ total }}</span>
		</div>
	</div>
</template>

<script setup>
defineProps({
	progress: {
		type: Number,
		required: true,
	},
	current: {
		type: Number,
		required: true,
	},
	total: {
		type: Number,
		required: true,
	},
});
</script>

<style scoped lang="scss">
.quiz-progress-compact {
	display: flex;
	align-items: center;
	padding: 8px 12px;
	background-color: rgba(255, 255, 255, 0.02);
	border-radius: 20px;
	margin-bottom: 8px;
	flex-shrink: 0;
}

.progress-info {
	display: flex;
	align-items: center;
	gap: 12px;
	width: 100%;

	.current-step,
	.total-steps {
		font-size: 12px;
		color: var(--color-complement-text);
		font-weight: 600;
		min-width: 20px;
		text-align: center;
	}

	.current-step {
		color: var(--color-highlight);
	}

	.progress-bar {
		flex: 1;
		height: 4px;
		background-color: rgba(255, 255, 255, 0.1);
		border-radius: 2px;
		overflow: hidden;

		.progress-fill {
			height: 100%;
			background: linear-gradient(90deg, var(--color-highlight), #667eea);
			border-radius: 2px;
			transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
		}
	}
}

@media (max-width: 768px) {
	.quiz-progress-compact {
		padding: 6px 10px;
		margin-bottom: 6px;
	}

	.progress-info {
		gap: 8px;

		.current-step,
		.total-steps {
			font-size: 11px;
			min-width: 18px;
		}

		.progress-bar {
			height: 3px;
		}
	}
}
</style>

<template>
	<DialogContainer dialog="districtDetail" @on-close="handleClose">
		<div class="district-detail-dialog">
			<button class="close-btn" @click="handleClose">
				<span>close</span>
			</button>

			<div class="dialog-content">
				<DistrictIntroCard
					v-if="dialogStore.selectedDistrict"
					:district="dialogStore.selectedDistrict"
					@click="handleExplore"
				/>
			</div>
		</div>
	</DialogContainer>
</template>

<script setup>
import { useDialogStore } from "../../store/dialogStore";
import DialogContainer from "./DialogContainer.vue";
import DistrictIntroCard from "../district/DistrictIntroCard.vue";

const dialogStore = useDialogStore();

function handleClose() {
	dialogStore.dialogs.districtDetail = false;
	dialogStore.selectedDistrict = null;
}

function handleExplore() {
	// 可以導航到商圈頁面或地圖
	console.log("Explore district:", dialogStore.selectedDistrict);
}
</script>

<style scoped lang="scss">
.district-detail-dialog {
	position: relative;
	max-width: 95vw;
	max-height: 90vh;
	overflow-y: auto;

	.close-btn {
		position: absolute;
		top: 16px;
		right: 16px;
		z-index: 10;
		width: 40px;
		height: 40px;
		border-radius: 50%;
		background: rgba(255, 255, 255, 0.1);
		backdrop-filter: blur(10px);
		border: 1px solid rgba(255, 255, 255, 0.2);
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		transition: all 0.3s ease;

		span {
			font-family: var(--font-icon);
			font-size: 20px;
			color: white;
		}

		&:hover {
			background: rgba(255, 255, 255, 0.2);
			transform: scale(1.1);
		}
	}

	.dialog-content {
		padding: 40px 20px 20px;
	}
}

@media (max-width: 768px) {
	.district-detail-dialog {
		.dialog-content {
			padding: 60px 16px 16px;
		}
	}
}
</style>

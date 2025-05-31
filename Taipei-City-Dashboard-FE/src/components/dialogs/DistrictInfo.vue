<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { computed } from "vue";
import { useDialogStore } from "../../store/dialogStore";
import DialogContainer from "./DialogContainer.vue";

const dialogStore = useDialogStore();

// 計算活動分類
const eventsByType = computed(() => {
	const events = dialogStore.districtInfoContent?.events || [];
	
	// 過濾掉已結束的活動，只保留正在進行中和即將開始的
	const activeEvents = events.filter(event => {
		const now = new Date();
		const end = new Date(event.endTime);
		return now <= end; // 只保留還沒結束的活動
	});
	
	const grouped = {
		market: activeEvents.filter(event => event.type === "市集"),
		performance: activeEvents.filter(event => event.type === "展演"),
		exhibition: activeEvents.filter(event => event.type === "展覽"),
		other: activeEvents.filter(event => !["市集", "展演", "展覽"].includes(event.type))
	};
	return grouped;
});

// 格式化日期時間
function formatDateTime(dateTime) {
	const date = new Date(dateTime);
	return date.toLocaleString('zh-TW', {
		year: 'numeric',
		month: '2-digit',
		day: '2-digit',
		hour: '2-digit',
		minute: '2-digit',
		hour12: false
	});
}

// 判斷活動狀態並計算天數
function getEventStatus(startTime, endTime) {
	const now = new Date();
	const start = new Date(startTime);
	const end = new Date(endTime);
	
	// 調試用 console.log
	console.log('活動時間調試:', {
		now: now.toISOString(),
		start: start.toISOString(),
		end: end.toISOString(),
		nowTime: now.getTime(),
		startTime: start.getTime(),
		endTime: end.getTime()
	});
	
	if (now < start) {
		// 即將開始 - 計算等待天數
		const diffTime = start.getTime() - now.getTime();
		const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
		return { 
			status: 'upcoming', 
			text: diffDays === 0 ? '今天開始' : `還有 ${diffDays} 天`, 
			class: 'status-upcoming' 
		};
	} else if (now >= start && now <= end) {
		// 進行中 - 計算剩餘天數
		const diffTime = end.getTime() - now.getTime();
		const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
		return { 
			status: 'ongoing', 
			text: diffDays === 0 ? '今天結束' : `剩餘 ${diffDays} 天`, 
			class: 'status-ongoing' 
		};
	} else {
		// 已結束 - 但這個狀態不應該出現，因為我們已經過濾掉了
		return { 
			status: 'ended', 
			text: '已結束', 
			class: 'status-ended' 
		};
	}
}

function handleClose() {
	dialogStore.dialogs.districtInfo = false;
}
</script>

<template>
  <DialogContainer
    dialog="districtInfo"
    @on-close="handleClose"
  >
    <div class="districtinfo">
      <div class="districtinfo-header">
        <h2>{{ dialogStore.districtInfoContent?.districtName }} 活動資訊</h2>
        <button
          class="districtinfo-close"
          @click="handleClose"
        >
          <span>close</span>
        </button>
      </div>
      
      <div class="districtinfo-content">
        <!-- 市集活動 -->
        <div
          v-if="eventsByType.market.length > 0"
          class="districtinfo-section"
        >
          <h3>
            <span class="icon">shopping_cart</span>
            市集活動 ({{ eventsByType.market.length }})
          </h3>
          <div class="districtinfo-events">
            <div
              v-for="event in eventsByType.market"
              :key="event.id"
              class="districtinfo-event"
            >
              <div class="districtinfo-event-header">
                <h4>{{ event.name }}</h4>
                <span :class="['status', getEventStatus(event.startTime, event.endTime).class]">
                  {{ getEventStatus(event.startTime, event.endTime).text }}
                </span>
              </div>
              <div class="districtinfo-event-details">
                <p>
                  <span class="icon">location_on</span>
                  {{ event.location }}
                </p>
                <p>
                  <span class="icon">schedule</span>
                  {{ formatDateTime(event.startTime) }} ~ {{ formatDateTime(event.endTime) }}
                </p>
                <p
                  v-if="event.description"
                  class="description"
                >
                  {{ event.description }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 展演活動 -->
        <div
          v-if="eventsByType.performance.length > 0"
          class="districtinfo-section"
        >
          <h3>
            <span class="icon">theater_comedy</span>
            展演活動 ({{ eventsByType.performance.length }})
          </h3>
          <div class="districtinfo-events">
            <div
              v-for="event in eventsByType.performance"
              :key="event.id"
              class="districtinfo-event"
            >
              <div class="districtinfo-event-header">
                <h4>{{ event.name }}</h4>
                <span :class="['status', getEventStatus(event.startTime, event.endTime).class]">
                  {{ getEventStatus(event.startTime, event.endTime).text }}
                </span>
              </div>
              <div class="districtinfo-event-details">
                <p>
                  <span class="icon">location_on</span>
                  {{ event.location }}
                </p>
                <p>
                  <span class="icon">schedule</span>
                  {{ formatDateTime(event.startTime) }} ~ {{ formatDateTime(event.endTime) }}
                </p>
                <p
                  v-if="event.description"
                  class="description"
                >
                  {{ event.description }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 展覽活動 -->
        <div
          v-if="eventsByType.exhibition.length > 0"
          class="districtinfo-section"
        >
          <h3>
            <span class="icon">museum</span>
            展覽活動 ({{ eventsByType.exhibition.length }})
          </h3>
          <div class="districtinfo-events">
            <div
              v-for="event in eventsByType.exhibition"
              :key="event.id"
              class="districtinfo-event"
            >
              <div class="districtinfo-event-header">
                <h4>{{ event.name }}</h4>
                <span :class="['status', getEventStatus(event.startTime, event.endTime).class]">
                  {{ getEventStatus(event.startTime, event.endTime).text }}
                </span>
              </div>
              <div class="districtinfo-event-details">
                <p>
                  <span class="icon">location_on</span>
                  {{ event.location }}
                </p>
                <p>
                  <span class="icon">schedule</span>
                  {{ formatDateTime(event.startTime) }} ~ {{ formatDateTime(event.endTime) }}
                </p>
                <p
                  v-if="event.description"
                  class="description"
                >
                  {{ event.description }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 其他活動 -->
        <div
          v-if="eventsByType.other.length > 0"
          class="districtinfo-section"
        >
          <h3>
            <span class="icon">event</span>
            其他活動 ({{ eventsByType.other.length }})
          </h3>
          <div class="districtinfo-events">
            <div
              v-for="event in eventsByType.other"
              :key="event.id"
              class="districtinfo-event"
            >
              <div class="districtinfo-event-header">
                <h4>{{ event.name }}</h4>
                <span :class="['status', getEventStatus(event.startTime, event.endTime).class]">
                  {{ getEventStatus(event.startTime, event.endTime).text }}
                </span>
              </div>
              <div class="districtinfo-event-details">
                <p>
                  <span class="icon">location_on</span>
                  {{ event.location }}
                </p>
                <p>
                  <span class="icon">schedule</span>
                  {{ formatDateTime(event.startTime) }} ~ {{ formatDateTime(event.endTime) }}
                </p>
                <p
                  v-if="event.description"
                  class="description"
                >
                  {{ event.description }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- 無活動時的顯示 -->
        <div
          v-if="!dialogStore.districtInfoContent?.events?.length"
          class="districtinfo-empty"
        >
          <span class="icon">event_busy</span>
          <h3>目前沒有活動資訊</h3>
          <p>{{ dialogStore.districtInfoContent?.districtName }}暫無進行中或即將開始的活動</p>
        </div>
      </div>
    </div>
  </DialogContainer>
</template>

<style scoped lang="scss">
.districtinfo {
	width: 600px;
	max-width: 90vw;
	max-height: 80vh;
	background-color: var(--color-component-background);
	border-radius: 5px;
	overflow: hidden;
	display: flex;
	flex-direction: column;

	&-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: var(--font-m);
		background-color: var(--color-highlight);
		color: white;

		h2 {
			margin: 0;
			font-size: var(--font-l);
		}

		&-close {
			padding: 4px;
			border-radius: 50%;
			background-color: rgba(255, 255, 255, 0.2);
			color: white;
			transition: background-color 0.2s;

			&:hover {
				background-color: rgba(255, 255, 255, 0.3);
			}

			span {
				font-family: var(--font-icon);
				font-size: var(--font-m);
			}
		}
	}

	&-content {
		flex: 1;
		padding: var(--font-m);
		overflow-y: auto;

		&::-webkit-scrollbar {
			width: 4px;
		}
		&::-webkit-scrollbar-thumb {
			border-radius: 4px;
			background-color: rgba(136, 135, 135, 0.5);
		}
		&::-webkit-scrollbar-thumb:hover {
			background-color: rgba(136, 135, 135, 1);
		}
	}

	&-section {
		margin-bottom: var(--font-l);

		&:last-child {
			margin-bottom: 0;
		}

		h3 {
			display: flex;
			align-items: center;
			margin-bottom: var(--font-m);
			color: var(--color-highlight);
			font-size: var(--font-m);

			.icon {
				margin-right: var(--font-s);
				font-family: var(--font-icon);
				font-size: var(--font-m);
			}
		}
	}

	&-events {
		display: flex;
		flex-direction: column;
		gap: var(--font-m);
	}

	&-event {
		padding: var(--font-m);
		border: 1px solid var(--color-border);
		border-radius: 5px;
		background-color: var(--color-component-background);
		transition: box-shadow 0.2s;

		&:hover {
			box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
		}

		&-header {
			display: flex;
			align-items: center;
			justify-content: space-between;
			margin-bottom: var(--font-s);

			h4 {
				margin: 0;
				color: var(--color-normal-text);
				font-size: var(--font-m);
				font-weight: 600;
			}

			.status {
				padding: 2px 8px;
				border-radius: 12px;
				font-size: var(--font-s);
				font-weight: 500;

				&.status-upcoming {
					background-color: #e3f2fd;
					color: #1976d2;
				}

				&.status-ongoing {
					background-color: #e8f5e8;
					color: #2e7d32;
				}

				&.status-ended {
					background-color: #fafafa;
					color: #616161;
				}
			}
		}

		&-details {
			p {
				display: flex;
				align-items: center;
				margin: var(--font-s) 0;
				color: var(--color-complement-text);
				font-size: var(--font-ms);

				.icon {
					margin-right: var(--font-s);
					color: var(--color-highlight);
					font-family: var(--font-icon);
					font-size: var(--font-ms);
				}

				&.description {
					margin-top: var(--font-s);
					padding-top: var(--font-s);
					border-top: 1px solid var(--color-border);
					line-height: 1.5;
				}
			}
		}
	}

	&-empty {
		text-align: center;
		padding: var(--font-xl) var(--font-m);
		color: var(--color-complement-text);

		.icon {
			font-family: var(--font-icon);
			font-size: 3rem;
			color: var(--color-border);
		}

		h3 {
			margin: var(--font-m) 0;
			color: var(--color-complement-text);
		}

		p {
			font-size: var(--font-ms);
		}
	}
}

@media (max-width: 768px) {
	.districtinfo {
		width: 90vw;

		&-event {
			&-header {
				flex-direction: column;
				align-items: flex-start;
				gap: var(--font-s);
			}
		}
	}
}
</style> 
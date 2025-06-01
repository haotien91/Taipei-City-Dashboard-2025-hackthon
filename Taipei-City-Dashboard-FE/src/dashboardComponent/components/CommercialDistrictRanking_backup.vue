<script setup lang="ts">
import { ref, computed, onMounted, watch, onUnmounted } from 'vue'
import { useTheme } from 'vuetify'

// 定義排序類型
type SortType = 'flow' | 'revenue' | 'stores'
type CityType = 'taipei' | 'new_taipei' | 'all'

// 定義數據接口
interface DistrictData {
  id: string
  rank: number
  name: string
  flowCount: number
  storeCount: number
  averageRevenue: number
  trend: number
  city: 'taipei' | 'new_taipei'
}

// 組件屬性
const props = defineProps<{
  data?: any[]
  config?: any
  height?: string | number
}>()

// 響應式狀態
const selectedCity = ref<CityType>('all')
const sortBy = ref<SortType>('flow')
const page = ref(1)
const itemsPerPage = 8
const currentDataSetIndex = ref(0)
const isTransitioning = ref(false)

// 初始化所有數據集
const initializeDataSets = () => {
  const baseData = [
    {
      id: '1',
      name: '信義商圈',
      flowCount: 15000,
      storeCount: 450,
      averageRevenue: 180,
      trend: 5.2,
      city: 'taipei'
    },
    {
      id: '2',
      name: '西門町商圈',
      flowCount: 12000,
      storeCount: 380,
      averageRevenue: 150,
      trend: -2.1,
      city: 'taipei'
    },
    {
      id: '3',
      name: '板橋商圈',
      flowCount: 10000,
      storeCount: 320,
      averageRevenue: 130,
      trend: 3.5,
      city: 'new_taipei'
    },
    {
      id: '4',
      name: '東區商圈',
      flowCount: 9500,
      storeCount: 300,
      averageRevenue: 145,
      trend: -1.8,
      city: 'taipei'
    },
    {
      id: '5',
      name: '中和環球商圈',
      flowCount: 8800,
      storeCount: 280,
      averageRevenue: 125,
      trend: 2.3,
      city: 'new_taipei'
    },
    {
      id: '6',
      name: '天母商圈',
      flowCount: 8500,
      storeCount: 260,
      averageRevenue: 135,
      trend: 1.5,
      city: 'taipei'
    },
    {
      id: '7',
      name: '三重商圈',
      flowCount: 8200,
      storeCount: 240,
      averageRevenue: 120,
      trend: -0.8,
      city: 'new_taipei'
    },
    {
      id: '8',
      name: '士林夜市商圈',
      flowCount: 8000,
      storeCount: 220,
      averageRevenue: 110,
      trend: 0.5,
      city: 'taipei'
    }
  ]

  // 生成5組數據，每組數據都基於基礎數據進行隨機變化
  return Array(5).fill(null).map(() => {
    return baseData.map(item => ({
      ...item,
      flowCount: Math.round(item.flowCount * (1 + (Math.random() * 0.2 - 0.1))), // ±10%變化
      storeCount: Math.round(item.storeCount * (1 + (Math.random() * 0.1 - 0.05))), // ±5%變化
      averageRevenue: Math.round(item.averageRevenue * (1 + (Math.random() * 0.15 - 0.075))), // ±7.5%變化
      trend: Number((Math.random() * 10 - 5).toFixed(1)) // -5%到+5%之間的趨勢
    }))
  })
}

// 初始化數據集
const dataSets = initializeDataSets()

// 當前數據集
const currentData = computed(() => dataSets[currentDataSetIndex.value])

// 計算屬性：排序字段映射
const sortByField = computed(() => {
  switch (sortBy.value) {
    case 'flow': return 'flowCount'
    case 'revenue': return 'averageRevenue'
    case 'stores': return 'storeCount'
    default: return 'flowCount'
  }
})

// 計算屬性：過濾和排序後的數據
const filteredDistricts = computed(() => {
  let districts = currentData.value
  if (selectedCity.value !== 'all') {
    districts = districts.filter(d => d.city === selectedCity.value)
  }
  return districts.sort((a, b) => b[sortByField.value] - a[sortByField.value])
})

// 計算屬性：當前顯示的數據
const displayedDistricts = computed(() => {
  return filteredDistricts.value.slice(0, page.value * itemsPerPage)
})

// 格式化數值
const formatValue = (value: number) => {
  if (value >= 10000) {
    return (value / 10000).toFixed(1) + '萬'
  }
  return value.toLocaleString()
}

// 格式化趨勢
const formatTrend = (trend: number) => {
  const sign = trend > 0 ? '+' : ''
  return `${sign}${trend.toFixed(1)}%`
}

// 獲取單位
const getUnit = () => {
  switch (sortBy.value) {
    case 'flow': return '人次'
    case 'revenue': return '萬元'
    case 'stores': return '家'
    default: return ''
  }
}

// 處理滾動加載
const rankingList = ref<HTMLElement | null>(null)
const handleScroll = () => {
  if (!rankingList.value) return
  
  const { scrollTop, scrollHeight, clientHeight } = rankingList.value
  if (scrollTop + clientHeight >= scrollHeight - 50) {
    if (page.value * itemsPerPage < filteredDistricts.value.length) {
      page.value++
    }
  }
}

// 監聽排序和篩選變化
watch([selectedCity, sortBy], () => {
  page.value = 1
})

// 數據輪播定時器
let dataRotationTimer: number | null = null

// 切換到下一組數據
const rotateData = () => {
  isTransitioning.value = true
  setTimeout(() => {
    currentDataSetIndex.value = (currentDataSetIndex.value + 1) % dataSets.length
    isTransitioning.value = false
  }, 300)
}

// 組件掛載時啟動輪播
onMounted(() => {
  dataRotationTimer = window.setInterval(rotateData, 20000)
})

// 組件卸載時清理定時器
onUnmounted(() => {
  if (dataRotationTimer) {
    clearInterval(dataRotationTimer)
  }
})
</script>

<template>
  <div class="commercial-district-ranking">
    <div class="header">
      <div class="filters">
        <div class="select-group">
          <!-- 城市選擇下拉選單 -->
          <select 
            v-model="selectedCity" 
            class="select-input"
          >
            <option value="all">雙北</option>
            <option value="taipei">台北</option>
            <option value="new_taipei">新北</option>
          </select>

          <!-- 排序方式下拉選單 -->
          <select 
            v-model="sortBy" 
            class="select-input"
          >
            <option value="flow">人流量</option>
            <option value="revenue">營業額</option>
            <option value="stores">商店數</option>
          </select>
        </div>
      </div>
    </div>

    <!-- 排行榜列表 -->
    <div class="ranking-list" ref="rankingList" @scroll="handleScroll">
      <TransitionGroup 
        name="list" 
        tag="div"
        :class="{ 'transitioning': isTransitioning }"
      >
        <div 
          v-for="(district, index) in displayedDistricts" 
          :key="district.id"
          class="ranking-item"
        >
          <div class="info">
            <div class="name">{{ district.name }}</div>
            <div class="city-tag" :class="district.city">
              {{ district.city === 'taipei' ? '台北' : '新北' }}
            </div>
          </div>
          <div class="value">
            <span class="number">{{ formatValue(district[sortByField]) }}</span>
            <span class="unit">{{ getUnit() }}</span>
          </div>
          <div class="trend" :class="{ up: district.trend > 0, down: district.trend < 0 }">
            {{ formatTrend(district.trend) }}
          </div>
        </div>
      </TransitionGroup>
    </div>
  </div>
</template>

<style scoped>
.commercial-district-ranking {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #1E1E1E;
  color: #FFFFFF;
  padding: 16px;
  border-radius: 8px;
  font-family: 'Noto Sans TC', sans-serif;
}

.header {
  margin-bottom: 12px;
}

.select-group {
  display: flex;
  gap: 8px;
}

.select-input {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  padding: 6px 12px;
  border-radius: 4px;
  color: #FFFFFF;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 0.9em;
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
  min-width: 100px;
  position: relative;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12' fill='none'%3E%3Cpath d='M2 4L6 8L10 4' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 8px center;
  padding-right: 28px;
}

.select-input:hover {
  background-color: rgba(255, 255, 255, 0.15);
}

.select-input:focus {
  outline: none;
  box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.5);
}

.select-input option {
  background: #2C2C2C;
  color: #FFFFFF;
}

.ranking-list {
  flex: 1;
  overflow-y: auto;
  padding-right: 8px;
  margin-top: 4px;
}

.ranking-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.05);
  margin-bottom: 8px;
  border-radius: 6px;
  transition: all 0.3s;
}

.ranking-item:hover {
  background: rgba(255, 255, 255, 0.08);
}

.info {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
  flex: 2;
}

.name {
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.city-tag {
  font-size: 0.8em;
  padding: 2px 8px;
  border-radius: 3px;
  background: rgba(255, 255, 255, 0.1);
  white-space: nowrap;
}

.city-tag.taipei {
  color: #4ECDC4;
}

.city-tag.new_taipei {
  color: #FF6B6B;
}

.value {
  flex: 1;
  text-align: right;
  white-space: nowrap;
  margin-right: 16px;
}

.number {
  font-size: 1.1em;
  font-weight: 500;
  margin-right: 4px;
}

.unit {
  font-size: 0.8em;
  color: #888;
}

.trend {
  min-width: 70px;
  text-align: right;
  font-size: 0.9em;
  font-weight: 500;
  white-space: nowrap;
}

.trend.up {
  color: #4ECDC4;
}

.trend.down {
  color: #FF6B6B;
}

/* 滾動條樣式 */
.ranking-list::-webkit-scrollbar {
  width: 4px;
}

.ranking-list::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 2px;
}

.ranking-list::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 2px;
}

.ranking-list::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* 排序動畫 */
.list-move,
.list-enter-active,
.list-leave-active {
  transition: all 0.5s ease;
}

.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

.list-leave-active {
  position: absolute;
}

.transitioning .ranking-item {
  transition: transform 0.3s ease-in-out;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .select-group {
    flex-direction: column;
    gap: 8px;
  }

  .select-input {
    width: 100%;
  }

  .ranking-item {
    padding: 10px 12px;
  }

  .value {
    margin: 0 12px;
  }

  .trend {
    min-width: 60px;
  }
}
</style> 
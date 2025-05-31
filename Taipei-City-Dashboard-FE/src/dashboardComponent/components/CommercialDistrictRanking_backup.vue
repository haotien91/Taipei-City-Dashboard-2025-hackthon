<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
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

// 計算屬性：排序字段映射
const sortByField = computed(() => {
  switch (sortBy.value) {
    case 'flow': return 'flowCount'
    case 'revenue': return 'averageRevenue'
    case 'stores': return 'storeCount'
    default: return 'flowCount'
  }
})

// 模擬數據
const mockData: DistrictData[] = [
  {
    id: '1',
    rank: 1,
    name: '信義商圈',
    flowCount: 15000,
    storeCount: 450,
    averageRevenue: 180,
    trend: 5.2,
    city: 'taipei'
  },
  {
    id: '2',
    rank: 2,
    name: '西門町商圈',
    flowCount: 12000,
    storeCount: 380,
    averageRevenue: 150,
    trend: -2.1,
    city: 'taipei'
  },
  {
    id: '3',
    rank: 3,
    name: '板橋商圈',
    flowCount: 10000,
    storeCount: 320,
    averageRevenue: 130,
    trend: 3.5,
    city: 'new_taipei'
  },
  {
    id: '4',
    rank: 4,
    name: '東區商圈',
    flowCount: 9500,
    storeCount: 300,
    averageRevenue: 145,
    trend: -1.8,
    city: 'taipei'
  },
  {
    id: '5',
    rank: 5,
    name: '中和環球商圈',
    flowCount: 8800,
    storeCount: 280,
    averageRevenue: 125,
    trend: 2.3,
    city: 'new_taipei'
  },
  {
    id: '6',
    rank: 6,
    name: '天母商圈',
    flowCount: 8500,
    storeCount: 260,
    averageRevenue: 135,
    trend: 1.5,
    city: 'taipei'
  },
  {
    id: '7',
    rank: 7,
    name: '三重商圈',
    flowCount: 8200,
    storeCount: 240,
    averageRevenue: 120,
    trend: -0.8,
    city: 'new_taipei'
  },
  {
    id: '8',
    rank: 8,
    name: '士林夜市商圈',
    flowCount: 8000,
    storeCount: 220,
    averageRevenue: 110,
    trend: 0.5,
    city: 'taipei'
  }
]

// 計算屬性：過濾和排序後的數據
const filteredDistricts = computed(() => {
  let districts = mockData
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
</script>

<template>
  <div class="commercial-district-ranking">
    <!-- 城市切換 -->
    <div class="city-filter">
      <button 
        :class="{ active: selectedCity === 'all' }" 
        @click="selectedCity = 'all'"
      >
        雙北
      </button>
      <button 
        :class="{ active: selectedCity === 'taipei' }" 
        @click="selectedCity = 'taipei'"
      >
        台北
      </button>
      <button 
        :class="{ active: selectedCity === 'new_taipei' }" 
        @click="selectedCity = 'new_taipei'"
      >
        新北
      </button>
    </div>

    <!-- 排序方式切換 -->
    <div class="sort-filter">
      <button 
        :class="{ active: sortBy === 'flow' }" 
        @click="sortBy = 'flow'"
      >
        人流量
      </button>
      <button 
        :class="{ active: sortBy === 'revenue' }" 
        @click="sortBy = 'revenue'"
      >
        營業額
      </button>
      <button 
        :class="{ active: sortBy === 'stores' }" 
        @click="sortBy = 'stores'"
      >
        商店數
      </button>
    </div>

    <!-- 排行榜列表 -->
    <div class="ranking-list" ref="rankingList" @scroll="handleScroll">
      <div 
        v-for="district in displayedDistricts" 
        :key="district.id"
        class="ranking-item"
      >
        <div class="rank">{{ district.rank }}</div>
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
}

.city-filter,
.sort-filter {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

button {
  background: #2C2C2C;
  border: none;
  padding: 6px 12px;
  border-radius: 4px;
  color: #FFFFFF;
  cursor: pointer;
  transition: all 0.3s;
}

button.active {
  background: #0066CC;
}

.ranking-list {
  flex: 1;
  overflow-y: auto;
  padding-right: 8px;
}

.ranking-item {
  display: flex;
  align-items: center;
  padding: 12px;
  background: #2C2C2C;
  margin-bottom: 8px;
  border-radius: 6px;
  transition: all 0.3s;
}

.ranking-item:hover {
  background: #363636;
}

.rank {
  width: 24px;
  height: 24px;
  background: #404040;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  font-weight: bold;
}

.info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
}

.name {
  font-weight: 500;
}

.city-tag {
  font-size: 0.8em;
  padding: 2px 6px;
  border-radius: 3px;
  background: #404040;
}

.city-tag.taipei {
  color: #4ECDC4;
}

.city-tag.new_taipei {
  color: #FF6B6B;
}

.value {
  margin: 0 16px;
  text-align: right;
}

.number {
  font-size: 1.1em;
  font-weight: bold;
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
}

.trend.up {
  color: #4ECDC4;
}

.trend.down {
  color: #FF6B6B;
}

/* 滾動條樣式 */
.ranking-list::-webkit-scrollbar {
  width: 6px;
}

.ranking-list::-webkit-scrollbar-track {
  background: #2C2C2C;
  border-radius: 3px;
}

.ranking-list::-webkit-scrollbar-thumb {
  background: #404040;
  border-radius: 3px;
}

.ranking-list::-webkit-scrollbar-thumb:hover {
  background: #505050;
}
</style> 
<script setup lang="ts">
import { ref, computed } from 'vue'

// 定義商圈類型
type DistrictType = '美食商圈' | '生活機能型' | '觀光休閒' | '觀光夜市' | '日常消費型' | '其他'

// 定義數據接口
interface DistrictData {
  name: string
  type: DistrictType
  city: '台北' | '新北'
}

// 組件屬性
const props = defineProps<{
  data?: any[]
  config?: any
  height?: string | number
}>()

// 商圈數據
const commercialDistricts: DistrictData[] = [
  { name: '新北投溫泉商圈', type: '觀光休閒', city: '台北' },
  { name: '行義路溫泉美食商圈', type: '觀光休閒', city: '台北' },
  { name: '石牌捷運商圈', type: '生活機能型', city: '台北' },
  { name: '士林捷運站周邊', type: '美食商圈', city: '台北' },
  { name: '士林觀光夜市商圈', type: '美食商圈', city: '台北' },
  { name: '天母商圈', type: '美食商圈', city: '台北' },
  { name: '承德路中古汽車商圈', type: '其他', city: '台北' },
  { name: '蘭雅商圈', type: '生活機能型', city: '台北' },
  { name: '朝陽服飾材料商圈', type: '日常消費型', city: '台北' },
  { name: '迪化街商圈', type: '其他', city: '台北' },
  { name: '後站商圈', type: '日常消費型', city: '台北' },
  { name: '華陰街商圈', type: '日常消費型', city: '台北' },
  { name: '大龍峒商圈', type: '其他', city: '台北' },
  { name: '臺北大橋頭延三商圈', type: '觀光夜市', city: '台北' },
  { name: '寧夏夜市商圈', type: '觀光夜市', city: '台北' },
  { name: '圓山商圈', type: '美食商圈', city: '台北' },
  { name: '赤峰街商圈', type: '日常消費型', city: '台北' },
  { name: '愛國東路婚紗商圈', type: '其他', city: '台北' },
  { name: '沅陵街商圈', type: '日常消費型', city: '台北' },
  { name: '中華路影音商圈', type: '其他', city: '台北' },
  { name: '北門相機商圈', type: '美食商圈', city: '台北' },
  { name: '重慶南路書店商圈', type: '美食商圈', city: '台北' },
  { name: '南昌家具商圈', type: '其他', city: '台北' },
  { name: '大光華商圈', type: '其他', city: '台北' },
  { name: '臺大公館商圈', type: '其他', city: '台北' },
  { name: '榮町商圈', type: '其他', city: '台北' },
  { name: '萬華街區商圈', type: '其他', city: '台北' },
  { name: '艋舺商圈', type: '美食商圈', city: '台北' },
  { name: '艋舺夜市商圈', type: '觀光夜市', city: '台北' },
  { name: '西門町商圈', type: '美食商圈', city: '台北' },
  { name: '和平西路鳥鋪聚集區', type: '其他', city: '台北' },
  { name: '晴光商圈', type: '美食商圈', city: '台北' },
  { name: '四平陽光商圈', type: '生活機能型', city: '台北' },
  { name: '中山北路婚紗商圈', type: '其他', city: '台北' },
  { name: '晶華酒店、欣欣百貨周邊', type: '其他', city: '台北' },
  { name: '條通商圈', type: '其他', city: '台北' },
  { name: '中山捷運站周邊', type: '美食商圈', city: '台北' },
  { name: '吉林路美食', type: '美食商圈', city: '台北' },
  { name: '中山國中捷運站周邊', type: '其他', city: '台北' },
  { name: '民族濱江汽車', type: '其他', city: '台北' },
  { name: '大直商圈', type: '生活機能型', city: '台北' },
  { name: '東湖哈拉影城周邊', type: '生活機能型', city: '台北' },
  { name: '內湖量販店區', type: '其他', city: '台北' },
  { name: '內湖737商圈', type: '美食商圈', city: '台北' },
  { name: '西湖商圈', type: '美食商圈', city: '台北' },
  { name: '民權水族聚集區', type: '其他', city: '台北' },
  { name: '南京復興捷運站周邊', type: '美食商圈', city: '台北' },
  { name: '民生社區周邊', type: '其他', city: '台北' },
  { name: '吳興街商圈', type: '美食商圈', city: '台北' },
  { name: '五分埔商圈', type: '日常消費型', city: '台北' },
  { name: '信義計畫區百貨', type: '其他', city: '台北' },
  { name: '永春捷運站周邊', type: '美食商圈', city: '台北' },
  { name: '東區商圈', type: '美食商圈', city: '台北' },
  { name: '永康商圈', type: '美食商圈', city: '台北' },
  { name: '建國南路藝品古玩', type: '其他', city: '台北' },
  { name: '龍泉商圈', type: '日常消費型', city: '台北' },
  { name: '文昌家具商圈', type: '其他', city: '台北' },
  { name: '景美夜市周邊', type: '美食商圈', city: '台北' },
  { name: '貓空商圈', type: '觀光夜市', city: '台北' },
  { name: '萬芳商圈', type: '生活機能型', city: '台北' },
  { name: '南港車站CITYLINK周邊', type: '美食商圈', city: '台北' },
  { name: '中國信託金融園區', type: '其他', city: '台北' },
  { name: '至聖花博商圈', type: '其他', city: '台北' },
  { name: '加蚋商圈', type: '美食商圈', city: '台北' },
  // 新北市商圈
  { name: '板橋商圈', type: '生活機能型', city: '新北' },
  { name: '中和環球商圈', type: '生活機能型', city: '新北' },
  { name: '新莊商圈', type: '生活機能型', city: '新北' },
  { name: '三重商圈', type: '美食商圈', city: '新北' },
  { name: '永和樂華夜市商圈', type: '觀光夜市', city: '新北' },
  { name: '淡水老街商圈', type: '觀光休閒', city: '新北' },
  { name: '林口三井商圈', type: '生活機能型', city: '新北' },
  { name: '汐止火車站商圈', type: '生活機能型', city: '新北' }
]

// 選擇的城市和類型
const selectedCity = ref<'台北' | '新北' | '全部'>('全部')
const selectedType = ref<DistrictType | '全部'>('全部')

// 商圈類型列表
const districtTypes: (DistrictType | '全部')[] = ['全部', '美食商圈', '生活機能型', '觀光休閒', '觀光夜市', '日常消費型', '其他']

// 過濾後的商圈列表
const filteredDistricts = computed(() => {
  let districts = commercialDistricts

  if (selectedCity.value !== '全部') {
    districts = districts.filter(d => d.city === selectedCity.value)
  }

  if (selectedType.value !== '全部') {
    districts = districts.filter(d => d.type === selectedType.value)
  }

  return districts
})

// 獲取類型的顏色
const getTypeColor = (type: DistrictType) => {
  const colors = {
    '美食商圈': '#FF6B6B',
    '生活機能型': '#4ECDC4',
    '觀光休閒': '#FFD93D',
    '觀光夜市': '#FF8B94',
    '日常消費型': '#95E1D3',
    '其他': '#A8E6CF'
  }
  return colors[type] || '#888888'
}
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
            <option value="全部">雙北</option>
            <option value="台北">台北</option>
            <option value="新北">新北</option>
          </select>

          <!-- 商圈類型下拉選單 -->
          <select 
            v-model="selectedType" 
            class="select-input"
          >
            <option v-for="type in districtTypes" :key="type" :value="type">
              {{ type }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- 商圈列表 -->
    <div class="ranking-list">
      <TransitionGroup 
        name="list" 
        tag="div"
      >
        <div 
          v-for="district in filteredDistricts" 
          :key="district.name"
          class="ranking-item"
        >
          <div class="info">
            <div class="name">{{ district.name }}</div>
            <div class="city-tag" :class="district.city === '台北' ? 'taipei' : 'new-taipei'">
              {{ district.city }}
            </div>
          </div>
          <div class="type-tag" :style="{ backgroundColor: getTypeColor(district.type) }">
            {{ district.type }}
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
  margin-bottom: 16px;
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
  min-width: 120px;
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
}

.ranking-item {
  display: flex;
  justify-content: space-between;
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
  gap: 12px;
}

.name {
  font-weight: 500;
}

.city-tag {
  font-size: 0.8em;
  padding: 2px 8px;
  border-radius: 3px;
  background: rgba(255, 255, 255, 0.1);
}

.city-tag.taipei {
  color: #4ECDC4;
}

.city-tag.new-taipei {
  color: #FF6B6B;
}

.type-tag {
  font-size: 0.8em;
  padding: 4px 12px;
  border-radius: 4px;
  color: #1E1E1E;
  font-weight: 500;
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
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .type-tag {
    align-self: flex-start;
  }
}

/* 列表動畫 */
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
</style> 
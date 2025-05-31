<template>
  <div class="commercial-district-map-test">
    <h2>商圈活化地圖測試</h2>
    <div id="test-map" class="map-container"></div>
    <div class="layer-controls">
      <h3>圖層控制</h3>
      <label v-for="layer in layers" :key="layer.id">
        <input 
          type="checkbox" 
          v-model="layer.visible"
          @change="toggleLayer(layer)"
        />
        {{ layer.name }}
      </label>
    </div>
    <div class="info-panel" v-if="selectedFeature">
      <h3>詳細資訊</h3>
      <pre>{{ JSON.stringify(selectedFeature, null, 2) }}</pre>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import mapboxgl from 'mapbox-gl'

// 設定 Mapbox token (需要替換為實際的 token)
mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN || 'YOUR_MAPBOX_TOKEN'

const map = ref(null)
const selectedFeature = ref(null)
const layers = ref([
  { id: 'commercial-districts', name: '商圈範圍', visible: true, type: 'fill' },
  { id: 'traffic-hotspots', name: '人流熱點', visible: true, type: 'circle' },
  { id: 'traffic-flows', name: '人流動線', visible: false, type: 'arc' }
])

onMounted(() => {
  // 初始化地圖
  map.value = new mapboxgl.Map({
    container: 'test-map',
    style: 'mapbox://styles/mapbox/light-v11',
    center: [121.535, 25.045],
    zoom: 12
  })

  map.value.on('load', () => {
    // 載入商圈範圍
    map.value.addSource('commercial-districts', {
      type: 'geojson',
      data: '/mapData/commercial-districts.geojson'
    })

    map.value.addLayer({
      id: 'commercial-districts',
      type: 'fill',
      source: 'commercial-districts',
      paint: {
        'fill-color': [
          'interpolate',
          ['linear'],
          ['get', 'visitor_count'],
          0, '#FFE4B5',
          30000, '#FFA500',
          50000, '#FF6347',
          70000, '#DC143C'
        ],
        'fill-opacity': 0.7
      }
    })

    // 載入人流熱點
    map.value.addSource('traffic-hotspots', {
      type: 'geojson',
      data: '/mapData/traffic-hotspots.geojson'
    })

    map.value.addLayer({
      id: 'traffic-hotspots',
      type: 'circle',
      source: 'traffic-hotspots',
      paint: {
        'circle-radius': [
          'interpolate',
          ['linear'],
          ['get', 'flow_intensity'],
          0, 5,
          50, 10,
          100, 20
        ],
        'circle-color': [
          'interpolate',
          ['linear'],
          ['get', 'flow_intensity'],
          0, '#00FF00',
          50, '#FFFF00',
          75, '#FFA500',
          100, '#FF0000'
        ],
        'circle-blur': 0.5,
        'circle-opacity': 0.8
      }
    })

    // 設定點擊事件
    map.value.on('click', 'commercial-districts', (e) => {
      selectedFeature.value = e.features[0].properties
    })

    map.value.on('click', 'traffic-hotspots', (e) => {
      selectedFeature.value = e.features[0].properties
    })

    // 設定游標樣式
    map.value.on('mouseenter', 'commercial-districts', () => {
      map.value.getCanvas().style.cursor = 'pointer'
    })

    map.value.on('mouseleave', 'commercial-districts', () => {
      map.value.getCanvas().style.cursor = ''
    })
  })
})

const toggleLayer = (layer) => {
  if (map.value.getLayer(layer.id)) {
    map.value.setLayoutProperty(
      layer.id,
      'visibility',
      layer.visible ? 'visible' : 'none'
    )
  }
}
</script>

<style scoped>
.commercial-district-map-test {
  padding: 20px;
}

.map-container {
  width: 100%;
  height: 600px;
  margin-bottom: 20px;
}

.layer-controls {
  background: #f5f5f5;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.layer-controls label {
  display: block;
  margin: 10px 0;
}

.info-panel {
  background: #f0f0f0;
  padding: 15px;
  border-radius: 8px;
}

.info-panel pre {
  background: white;
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
}
</style>

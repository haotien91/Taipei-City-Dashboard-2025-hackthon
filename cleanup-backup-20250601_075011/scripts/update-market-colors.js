#!/usr/bin/env node

// 市集活動顏色狀態更新腳本
// 根據活動時間狀態自動設定不同顏色
const fs = require('fs');
const path = require('path');

// 顏色配置
const STATUS_COLORS = {
  'not_started': '#2196F3',    // 藍色：尚未開始的活動
  'active': '#4CAF50',         // 綠色：正在進行的活動
  'ending_2weeks': '#FFEB3B',  // 黃色：活動剩2個禮拜結束
  'ending_1week': '#FF9800',   // 橘色：活動剩一個禮拜結束
  'ending_3days': '#F44336'    // 紅色：活動剩3天結束
};

function calculateEventStatus(startDate, endDate) {
  const today = new Date();
  const start = new Date(startDate);
  const end = new Date(endDate);
  
  // 設定時間為當天午夜，避免時區問題
  today.setHours(0, 0, 0, 0);
  start.setHours(0, 0, 0, 0);
  end.setHours(0, 0, 0, 0);
  
  // 尚未開始
  if (today < start) {
    return 'not_started';
  }
  
  // 已結束
  if (today > end) {
    return 'ended';
  }
  
  // 計算剩餘天數
  const timeLeft = end.getTime() - today.getTime();
  const daysLeft = Math.ceil(timeLeft / (1000 * 60 * 60 * 24));
  
  // 正在進行中
  if (daysLeft <= 3) {
    return 'ending_3days';
  } else if (daysLeft <= 7) {
    return 'ending_1week';
  } else if (daysLeft <= 14) {
    return 'ending_2weeks';
  } else {
    return 'active';
  }
}

function updateGeoJSONWithStatus(inputFile, outputFile) {
  console.log(`\n🔄 處理檔案: ${inputFile}`);
  
  try {
    const data = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
    let updatedCount = 0;
    let statusCounts = {
      'not_started': 0,
      'active': 0,
      'ending_2weeks': 0,
      'ending_1week': 0,
      'ending_3days': 0,
      'ended': 0
    };
    
    data.features.forEach(feature => {
      const startDate = feature.properties.start_date;
      const endDate = feature.properties.end_date;
      
      if (startDate && endDate) {
        const status = calculateEventStatus(startDate, endDate);
        feature.properties.event_status = status;
        feature.properties.status_color = STATUS_COLORS[status] || '#666666';
        
        statusCounts[status]++;
        updatedCount++;
        
        console.log(`  ✅ ${feature.properties.name}: ${status} (${STATUS_COLORS[status] || '#666666'})`);
      } else {
        console.log(`  ⚠️  ${feature.properties.name}: 缺少日期資訊`);
      }
    });
    
    fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));
    
    console.log(`\n📊 處理結果:`);
    console.log(`  更新特徵數: ${updatedCount}`);
    console.log(`  🔵 尚未開始: ${statusCounts.not_started}`);
    console.log(`  🟢 正在進行: ${statusCounts.active}`);
    console.log(`  🟡 剩2週結束: ${statusCounts.ending_2weeks}`);
    console.log(`  🟠 剩1週結束: ${statusCounts.ending_1week}`);
    console.log(`  🔴 剩3天結束: ${statusCounts.ending_3days}`);
    console.log(`  ⚫ 已結束: ${statusCounts.ended}`);
    
    return statusCounts;
    
  } catch (error) {
    console.error(`❌ 處理檔案錯誤: ${error.message}`);
    return null;
  }
}

function createUpdatedMapConfig() {
  return {
    index: 'market_events_taipei_dynamic',
    title: '市集活動分佈 - 動態狀態',
    type: 'circle',
    source: 'geojson',
    size: 'big',
    icon: null,
    paint: {
      "circle-color": [
        "match",
        ["get", "event_status"],
        "not_started", "#2196F3",      // 藍色：尚未開始
        "active", "#4CAF50",           // 綠色：正在進行
        "ending_2weeks", "#FFEB3B",    // 黃色：剩2週結束
        "ending_1week", "#FF9800",     // 橘色：剩1週結束
        "ending_3days", "#F44336",     // 紅色：剩3天結束
        "#666666"                      // 灰色：其他狀態
      ],
      "circle-radius": [
        "interpolate",
        ["linear"],
        ["zoom"],
        11.99, 4,
        12, 5,
        13.5, 6,
        15, 8,
        22, 12
      ],
      "circle-stroke-width": 2,
      "circle-stroke-color": "#FFFFFF",
      "circle-opacity": 0.85
    },
    property: [
      {"key": "name", "name": "市集名稱"},
      {"key": "type", "name": "活動類型"},
      {"key": "district", "name": "行政區"},
      {"key": "start_date", "name": "開始日期"},
      {"key": "end_date", "name": "結束日期"},
      {"key": "event_status", "name": "活動狀態"},
      {"key": "description", "name": "活動描述"}
    ]
  };
}

function createDynamicMapSQL() {
  const mapConfig = createUpdatedMapConfig();
  
  return `-- 動態顏色市集活動地圖配置
-- 根據活動狀態顯示不同顏色的圓點
-- 創建時間：${new Date().toISOString()}

-- 新增動態顏色地圖配置
INSERT INTO public.component_maps (index, title, type, source, size, icon, paint, property) 
VALUES (
    '${mapConfig.index}',
    '${mapConfig.title}',
    '${mapConfig.type}',
    '${mapConfig.source}',
    '${mapConfig.size}',
    NULL,
    '${JSON.stringify(mapConfig.paint)}',
    '${JSON.stringify(mapConfig.property)}'
) 
ON CONFLICT (index) DO UPDATE SET
    title = EXCLUDED.title,
    type = EXCLUDED.type,
    source = EXCLUDED.source,
    size = EXCLUDED.size,
    icon = EXCLUDED.icon,
    paint = EXCLUDED.paint,
    property = EXCLUDED.property;

-- 更新台北市集活動組件使用新的動態地圖配置
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = '${mapConfig.index}')
]
WHERE index = 'commercial_district_density' AND city = 'taipei';

-- 同時更新雙北市集活動組件
UPDATE public.query_charts 
SET map_config_ids = ARRAY[
    (SELECT id FROM public.component_maps WHERE index = '${mapConfig.index}')
]
WHERE index = 'commercial_district_density_metrotaipei' AND city = 'metrotaipei';

-- 顯示配置結果
DO $$
DECLARE
    map_config_id INTEGER;
BEGIN
    SELECT id INTO map_config_id FROM public.component_maps WHERE index = '${mapConfig.index}';
    
    RAISE NOTICE '=== 動態顏色市集地圖配置完成 ===';
    RAISE NOTICE '地圖配置ID: %', map_config_id;
    RAISE NOTICE '配置名稱: ${mapConfig.title}';
    RAISE NOTICE '圖層類型: circle (動態顏色圓點)';
    RAISE NOTICE '';
    RAISE NOTICE '🎨 顏色對應:';
    RAISE NOTICE '  🔵 藍色 (#2196F3): 尚未開始的活動';
    RAISE NOTICE '  🟢 綠色 (#4CAF50): 正在進行的活動';
    RAISE NOTICE '  🟡 黃色 (#FFEB3B): 活動剩2個禮拜結束';
    RAISE NOTICE '  🟠 橘色 (#FF9800): 活動剩1個禮拜結束';
    RAISE NOTICE '  🔴 紅色 (#F44336): 活動剩3天結束';
    RAISE NOTICE '';
    RAISE NOTICE '💡 請重啟後端服務並重新整理前端頁面';
END $$;`;
}

function main() {
  console.log('🎨 台北城市儀表板 - 市集活動動態顏色配置工具');
  console.log('='.repeat(60));
  
  const files = [
    {
      input: 'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson',
      output: 'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson'
    },
    {
      input: 'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson',
      output: 'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson'
    }
  ];
  
  let totalStats = {
    not_started: 0,
    active: 0,
    ending_2weeks: 0,
    ending_1week: 0,
    ending_3days: 0,
    ended: 0
  };
  
  // 更新所有 GeoJSON 檔案
  files.forEach(({ input, output }) => {
    if (fs.existsSync(input)) {
      const stats = updateGeoJSONWithStatus(input, output);
      if (stats) {
        Object.keys(stats).forEach(key => {
          totalStats[key] += stats[key];
        });
      }
    } else {
      console.log(`⚠️  檔案不存在: ${input}`);
    }
  });
  
  // 創建 SQL 配置檔案
  const sqlContent = createDynamicMapSQL();
  const sqlFile = 'db-sample-data/market-events-dynamic-map.sql';
  fs.writeFileSync(sqlFile, sqlContent);
  
  console.log(`\n📄 SQL 配置檔案已創建: ${sqlFile}`);
  
  // 顯示總體統計
  console.log(`\n🎯 總體統計:`);
  console.log(`  🔵 尚未開始: ${totalStats.not_started} 個活動`);
  console.log(`  🟢 正在進行: ${totalStats.active} 個活動`);
  console.log(`  🟡 剩2週結束: ${totalStats.ending_2weeks} 個活動`);
  console.log(`  🟠 剩1週結束: ${totalStats.ending_1week} 個活動`);
  console.log(`  🔴 剩3天結束: ${totalStats.ending_3days} 個活動`);
  console.log(`  ⚫ 已結束: ${totalStats.ended} 個活動`);
  
  // 部署說明
  console.log(`\n🚀 部署步驟:`);
  console.log(`  1. 執行 SQL 配置:`);
  console.log(`     docker exec postgres-manager psql -U postgres -d dashboardmanager -f /shared/${sqlFile}`);
  console.log(`  2. 重啟後端服務:`);
  console.log(`     docker restart dashboard-be`);
  console.log(`  3. 重新整理前端頁面`);
  
  console.log(`\n✨ 處理完成！現在地圖上的圓點將根據活動狀態顯示不同顏色。`);
}

if (require.main === module) {
  main();
} 
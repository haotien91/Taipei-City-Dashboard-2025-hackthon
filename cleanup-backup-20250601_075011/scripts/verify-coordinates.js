#!/usr/bin/env node

// 座標驗證腳本 - 檢查市集活動座標是否在合理範圍內
const fs = require('fs');
const path = require('path');

// 台北市和新北市的合理座標範圍
const VALID_BOUNDS = {
  // 擴大範圍以涵蓋雙北地區
  minLat: 24.90,  // 最南（新店、中和）
  maxLat: 25.30,  // 最北（淡水、北投）
  minLng: 121.35, // 最西（林口）
  maxLng: 121.70  // 最東（南港、汐止）
};

function validateCoordinates(geojsonPath) {
  console.log(`\n🔍 驗證檔案: ${geojsonPath}`);
  
  try {
    const data = JSON.parse(fs.readFileSync(geojsonPath, 'utf8'));
    const features = data.features || [];
    
    let validCount = 0;
    let invalidCount = 0;
    let outOfBoundsPoints = [];
    
    features.forEach((feature, index) => {
      const coords = feature.geometry.coordinates;
      const lng = coords[0];
      const lat = coords[1];
      const name = feature.properties.name;
      const type = feature.properties.type;
      const city = feature.properties.city || '台北市';
      
      // 檢查座標是否在有效範圍內
      if (lat >= VALID_BOUNDS.minLat && lat <= VALID_BOUNDS.maxLat &&
          lng >= VALID_BOUNDS.minLng && lng <= VALID_BOUNDS.maxLng) {
        validCount++;
        console.log(`✅ [${index + 1}] ${name} (${type}) - ${city}`);
        console.log(`   座標: [${lng}, ${lat}]`);
      } else {
        invalidCount++;
        outOfBoundsPoints.push({
          index: index + 1,
          name,
          type,
          city,
          coordinates: [lng, lat],
          issues: []
        });
        
        if (lat < VALID_BOUNDS.minLat) outOfBoundsPoints[outOfBoundsPoints.length - 1].issues.push('緯度過低');
        if (lat > VALID_BOUNDS.maxLat) outOfBoundsPoints[outOfBoundsPoints.length - 1].issues.push('緯度過高');
        if (lng < VALID_BOUNDS.minLng) outOfBoundsPoints[outOfBoundsPoints.length - 1].issues.push('經度過低');
        if (lng > VALID_BOUNDS.maxLng) outOfBoundsPoints[outOfBoundsPoints.length - 1].issues.push('經度過高');
        
        console.log(`❌ [${index + 1}] ${name} (${type}) - ${city}`);
        console.log(`   座標: [${lng}, ${lat}] - ${outOfBoundsPoints[outOfBoundsPoints.length - 1].issues.join(', ')}`);
      }
    });
    
    console.log(`\n📊 驗證結果:`);
    console.log(`   總點數: ${features.length}`);
    console.log(`   有效座標: ${validCount}`);
    console.log(`   無效座標: ${invalidCount}`);
    
    if (outOfBoundsPoints.length > 0) {
      console.log(`\n⚠️  需要修正的座標:`);
      outOfBoundsPoints.forEach(point => {
        console.log(`   • ${point.name} - ${point.issues.join(', ')}`);
        
        // 提供建議座標
        let suggestedLat = point.coordinates[1];
        let suggestedLng = point.coordinates[0];
        
        if (suggestedLat < VALID_BOUNDS.minLat) suggestedLat = VALID_BOUNDS.minLat + 0.01;
        if (suggestedLat > VALID_BOUNDS.maxLat) suggestedLat = VALID_BOUNDS.maxLat - 0.01;
        if (suggestedLng < VALID_BOUNDS.minLng) suggestedLng = VALID_BOUNDS.minLng + 0.01;
        if (suggestedLng > VALID_BOUNDS.maxLng) suggestedLng = VALID_BOUNDS.maxLng - 0.01;
        
        console.log(`     建議座標: [${suggestedLng}, ${suggestedLat}]`);
      });
    }
    
    return {
      total: features.length,
      valid: validCount,
      invalid: invalidCount,
      outOfBounds: outOfBoundsPoints
    };
    
  } catch (error) {
    console.error(`❌ 讀取檔案錯誤: ${error.message}`);
    return null;
  }
}

function validateMapBounds() {
  console.log('🗺️  台北城市儀表板 - 座標驗證工具');
  console.log('=======================================');
  console.log(`有效座標範圍:`);
  console.log(`  緯度: ${VALID_BOUNDS.minLat} ~ ${VALID_BOUNDS.maxLat}`);
  console.log(`  經度: ${VALID_BOUNDS.minLng} ~ ${VALID_BOUNDS.maxLng}`);
  
  const files = [
    'Taipei-City-Dashboard-FE/public/mapData/market_events_taipei.geojson',
    'Taipei-City-Dashboard-FE/public/mapData/market_events_metrotaipei.geojson'
  ];
  
  let totalStats = {
    total: 0,
    valid: 0,
    invalid: 0,
    files: 0
  };
  
  files.forEach(file => {
    if (fs.existsSync(file)) {
      const result = validateCoordinates(file);
      if (result) {
        totalStats.total += result.total;
        totalStats.valid += result.valid;
        totalStats.invalid += result.invalid;
        totalStats.files++;
      }
    } else {
      console.log(`⚠️  檔案不存在: ${file}`);
    }
  });
  
  console.log(`\n🎯 總體統計:`);
  console.log(`   檢查檔案: ${totalStats.files}`);
  console.log(`   總點數: ${totalStats.total}`);
  console.log(`   有效座標: ${totalStats.valid}`);
  console.log(`   無效座標: ${totalStats.invalid}`);
  console.log(`   成功率: ${((totalStats.valid / totalStats.total) * 100).toFixed(1)}%`);
  
  if (totalStats.invalid === 0) {
    console.log(`\n🎉 所有座標都在有效範圍內！地圖應該能正確顯示所有點位。`);
  } else {
    console.log(`\n🔧 建議修正 ${totalStats.invalid} 個無效座標以確保完整顯示。`);
  }
}

// 執行驗證
validateMapBounds(); 
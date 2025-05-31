// 經緯度轉台北市行政區工具
// 台北市各行政區的大概經緯度範圍

const taipeiDistrictBoundaries = {
  // 台北市各區的經緯度範圍 [南緯, 北緯, 西經, 東經]
  '北投區': { minLat: 25.08, maxLat: 25.15, minLng: 121.45, maxLng: 121.53 },
  '士林區': { minLat: 25.08, maxLat: 25.15, minLng: 121.50, maxLng: 121.55 },
  '內湖區': { minLat: 25.06, maxLat: 25.10, minLng: 121.55, maxLng: 121.62 },
  '南港區': { minLat: 25.02, maxLat: 25.08, minLng: 121.58, maxLng: 121.65 },
  '松山區': { minLat: 25.03, maxLat: 25.08, minLng: 121.54, maxLng: 121.58 },
  '信義區': { minLat: 25.01, maxLat: 25.05, minLng: 121.54, maxLng: 121.58 },
  '中山區': { minLat: 25.04, maxLat: 25.09, minLng: 121.51, maxLng: 121.55 },
  '大同區': { minLat: 25.04, maxLat: 25.08, minLng: 121.50, maxLng: 121.52 },
  '中正區': { minLat: 25.01, maxLat: 25.05, minLng: 121.50, maxLng: 121.53 },
  '萬華區': { minLat: 25.01, maxLat: 25.05, minLng: 121.48, maxLng: 121.51 },
  '大安區': { minLat: 25.01, maxLat: 25.05, minLng: 121.52, maxLng: 121.55 },
  '文山區': { minLat: 24.98, maxLat: 25.03, minLng: 121.54, maxLng: 121.60 }
};

// 特殊地點的精確對應（基於知名地標）
const landmarkMapping = {
  // 天文館 - 士林區
  '25.0958,121.518': '士林區',
  // 士林區相關
  '25.0978,121.526': '士林區',
  // 北投相關
  '25.1371,121.506': '北投區',
  // 松山文創園區 - 信義區
  '25.0438,121.561': '信義區',
  // 萬興分館 - 文山區
  '24.9887,121.577': '文山區',
  // 中正區相關
  '25.0158,121.527': '中正區',
  '25.0468,121.511': '中正區',
  '25.0178,121.535': '中正區',
  // 大安區相關
  '25.0539,121.508': '大安區',
  '25.0345,121.543': '大安區',
  '25.0388,121.524': '大安區',
  // 中山區相關
  '25.0708,121.521': '中山區',
  '25.0674,121.519': '中山區',
  // 信義區相關
  '25.0468,121.556': '信義區',
  '25.0466,121.549': '信義區'
};

/**
 * 將經緯度轉換為台北市行政區
 * @param {string} coordinateString - 經緯度字串，格式："25.0978,121.526"
 * @returns {string} 對應的行政區名稱
 */
export function coordinateToDistrict(coordinateString) {
  // 移除引號並分割經緯度
  const cleanCoordinate = coordinateString.replace(/"/g, '');
  
  // 首先檢查是否有精確的地標對應
  if (landmarkMapping[cleanCoordinate]) {
    return landmarkMapping[cleanCoordinate];
  }
  
  const [latStr, lngStr] = cleanCoordinate.split(',');
  const lat = parseFloat(latStr);
  const lng = parseFloat(lngStr);
  
  // 檢查是否在台北市範圍內
  if (lat < 24.95 || lat > 25.20 || lng < 121.45 || lng > 121.65) {
    return '中正區'; // 預設值
  }
  
  // 遍歷各行政區找到匹配的
  for (const [district, boundary] of Object.entries(taipeiDistrictBoundaries)) {
    if (lat >= boundary.minLat && lat <= boundary.maxLat &&
        lng >= boundary.minLng && lng <= boundary.maxLng) {
      return district;
    }
  }
  
  // 如果沒有找到匹配的區域，根據經緯度做簡單判斷
  if (lat >= 25.08) {
    return lng < 121.52 ? '北投區' : '士林區';
  } else if (lat >= 25.05) {
    if (lng < 121.51) return '大同區';
    if (lng < 121.54) return '中山區';
    if (lng < 121.57) return '松山區';
    return '內湖區';
  } else if (lat >= 25.01) {
    if (lng < 121.50) return '萬華區';
    if (lng < 121.52) return '中正區';
    if (lng < 121.55) return '大安區';
    if (lng < 121.58) return '信義區';
    return '南港區';
  } else {
    return lng < 121.57 ? '文山區' : '文山區';
  }
}

/**
 * 處理 taipei_travel.csv 資料並轉換為組件格式
 * @param {Array} travelData - 旅遊活動原始資料
 * @returns {Object} 按行政區分組的活動資料
 */
export function processTravelData(travelData) {
  const districtTravelEvents = {};
  let eventId = 1000; // 使用不同的起始ID避免衝突
  
  travelData.forEach(event => {
    const district = coordinateToDistrict(event.location);
    
    if (!districtTravelEvents[district]) {
      districtTravelEvents[district] = [];
    }
    
    // 轉換為組件期望的格式
    const formattedEvent = {
      id: eventId++,
      name: event.name,
      type: '展覽活動', // 區分於市集活動
      location: event.location, // 保留原始經緯度
      startTime: event.start_date + 'T09:00:00',
      endTime: event.end_date + 'T18:00:00',
      description: `文化展覽活動：${event.name}`,
      coordinates: event.location // 額外保存經緯度資訊
    };
    
    districtTravelEvents[district].push(formattedEvent);
  });
  
  return districtTravelEvents;
} 
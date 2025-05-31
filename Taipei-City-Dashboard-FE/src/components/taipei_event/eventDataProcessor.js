// 資料處理工具，將CSV市集資料轉換為組件所需的格式

// 區域對應表，將活動地點對應到行政區
const locationDistrictMapping = {
  // 台北市
  '台北市': {
    '圓山花博': '中山區',
    '南港瓶蓋工廠': '南港區',
    '龍山': '萬華區',
    '安森町': '中山區',
    '大安森': '大安區',
    '忠孝敦化': '大安區',
    '東區地下街': '大安區',
    '東森廣場': '內湖區',
    '風格酒食': '信義區',
    '夢想寄售店': '大安區'
  },
  // 新北市
  '新北市': {
    '小碧潭': '新店區',
    '汐止': '汐止區',
    '板橋府中': '板橋區',
    '新店': '新店區',
    '淡水': '淡水區',
    '中和': '中和區',
    '美河市': '新店區'
  }
};

// 將地點對應到具體行政區的函數
function mapLocationToDistrict(location) {
  const taipeiCityPattern = /台北市/;
  const newTaipeiCityPattern = /新北市/;
  
  if (taipeiCityPattern.test(location)) {
    // 針對台北市的地點進行匹配
    for (const [keyword, district] of Object.entries(locationDistrictMapping.台北市)) {
      if (location.includes(keyword)) {
        return district;
      }
    }
    // 如果無法對應，預設為中正區
    return '中正區';
  } else if (newTaipeiCityPattern.test(location)) {
    // 針對新北市的地點進行匹配
    for (const [keyword, district] of Object.entries(locationDistrictMapping.新北市)) {
      if (location.includes(keyword)) {
        return district;
      }
    }
    // 如果無法對應，預設為板橋區
    return '板橋區';
  }
  
  // 如果地點字串中沒有台北市或新北市，根據內容推測
  for (const [keyword, district] of Object.entries(locationDistrictMapping.台北市)) {
    if (location.includes(keyword)) {
      return district;
    }
  }
  
  for (const [keyword, district] of Object.entries(locationDistrictMapping.新北市)) {
    if (location.includes(keyword)) {
      return district;
    }
  }
  
  // 預設回傳台北市中正區
  return '中正區';
}

// 解析CSV資料的函數
function parseCSVData(csvText) {
  const lines = csvText.trim().split('\n');
  const headers = lines[0].split(',');
  
  const events = [];
  for (let i = 1; i < lines.length; i++) {
    const values = lines[i].split(',');
    const event = {};
    
    headers.forEach((header, index) => {
      event[header.trim()] = values[index]?.trim() || '';
    });
    
    events.push(event);
  }
  
  return events;
}

// 轉換事件資料格式
function convertEventsToDistrictFormat(csvEvents) {
  const districtEventsMap = {};
  let eventId = 1;
  
  csvEvents.forEach(event => {
    const district = mapLocationToDistrict(event.location);
    
    if (!districtEventsMap[district]) {
      districtEventsMap[district] = [];
    }
    
    // 轉換為組件期望的格式
    const formattedEvent = {
      id: eventId++,
      name: event.name,
      type: '市集', // 所有事件都標記為市集類型
      location: event.location,
      startTime: event.start_date + 'T09:00:00', // 假設開始時間為上午9點
      endTime: event.end_date + 'T18:00:00',     // 假設結束時間為下午6點
      description: `市集活動：${event.name}`
    };
    
    districtEventsMap[district].push(formattedEvent);
  });
  
  return districtEventsMap;
}

// 主要的資料處理函數
export async function processMarketData() {
  try {
    // 讀取台北市活動資料
    const taipeiResponse = await fetch('/data/taipei_events.csv');
    const taipeiCSV = await taipeiResponse.text();
    const taipeiEvents = parseCSVData(taipeiCSV);
    
    // 讀取雙北市活動資料
    const doubleNorthResponse = await fetch('/data/double_north_events.csv');
    const doubleNorthCSV = await doubleNorthResponse.text();
    const doubleNorthEvents = parseCSVData(doubleNorthCSV);
    
    // 轉換資料格式
    const taipeiDistrictEvents = convertEventsToDistrictFormat(taipeiEvents);
    const doubleNorthDistrictEvents = convertEventsToDistrictFormat(doubleNorthEvents);
    
    return {
      taipei: taipeiDistrictEvents,
      doubleNorth: doubleNorthDistrictEvents
    };
  } catch (error) {
    console.error('處理市集資料時發生錯誤:', error);
    return null;
  }
}

// 獲取特定區域的活動資料
export function getDistrictEvents(district, dataSource = 'doubleNorth') {
  // 這個函數將在組件中使用，用於獲取特定行政區的活動
  return processMarketData().then(data => {
    if (!data) return [];
    return data[dataSource][district] || [];
  });
} 
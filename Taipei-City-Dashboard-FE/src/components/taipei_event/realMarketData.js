// 真實市集活動資料 - 來自台北市集CSV檔案
import { coordinateToDistrict, processTravelData } from './coordinateToDistrict.js';

// 原始市集資料
const rawMarketEvents = [
  {
    name: "圓山花博x168幸福市集",
    location: "台北市",
    start_date: "2025-11-28",
    end_date: "2025-11-30"
  },
  {
    name: "圓山花博x168幸福市集", 
    location: "台北市",
    start_date: "2025-10-24",
    end_date: "2025-10-26"
  },
  {
    name: "圓山花博x168幸福市集",
    location: "台北市", 
    start_date: "2025-10-03",
    end_date: "2025-10-05"
  },
  {
    name: "東森廣場k區東廣場(寄售)",
    location: "台北市",
    start_date: "2025-09-01", 
    end_date: "2025-10-31"
  },
  {
    name: "南港瓶蓋工廠-吉刻市集Ｘ文博浪潮市集",
    location: "台北市",
    start_date: "2025-08-08",
    end_date: "2025-08-10"
  },
  {
    name: "眾樂樂文創市集",
    location: "台北市",
    start_date: "2025-07-25",
    end_date: "2025-07-27"
  },
  {
    name: "小小地球人市集｜龍山文創",
    location: "台北市",
    start_date: "2025-07-12",
    end_date: "2025-07-13"
  },
  {
    name: "蜜香紅茶與手作的相遇-安森町主題市集",
    location: "台北市",
    start_date: "2025-07-12",
    end_date: "2025-07-13"
  },
  {
    name: "風格酒食之夜",
    location: "台北市",
    start_date: "2025-07-11",
    end_date: "2025-07-13"
  },
  {
    name: "大暑升級 LEVEL UP ~ 龍山夏日市集",
    location: "台北市",
    start_date: "2025-07-05",
    end_date: "2025-07-06"
  },
  {
    name: "心靈綠洲 療癒日",
    location: "台北市",
    start_date: "2025-07-05",
    end_date: "2025-07-06"
  },
  {
    name: "忠孝敦化第四廣場(寄售)",
    location: "台北市",
    start_date: "2025-07-01",
    end_date: "2025-12-31"
  },
  {
    name: "日式花火祭典",
    location: "台北市",
    start_date: "2025-06-28",
    end_date: "2025-06-29"
  },
  {
    name: "漢堡大學-漢堡的多重宇宙",
    location: "台北市",
    start_date: "2025-06-21",
    end_date: "2025-06-22"
  },
  {
    name: "耍廢。甩廢 天生廢材必有用 大安森環保市集",
    location: "台北市",
    start_date: "2025-06-21",
    end_date: "2025-06-22"
  },
  {
    name: "June Together 年中大會師",
    location: "台北市",
    start_date: "2025-06-14",
    end_date: "2025-06-15"
  },
  {
    name: "JAZZ UP! 爵士樂生活",
    location: "台北市",
    start_date: "2025-06-07",
    end_date: "2025-06-08"
  },
  {
    name: "南村夏日子-兩場次",
    location: "台北市",
    start_date: "2025-05-01",
    end_date: "2025-06-30"
  },
  {
    name: "長期櫃位~夢想寄售店-東區地下街20-1",
    location: "台北市",
    start_date: "2025-04-01",
    end_date: "2025-08-31"
  },
  {
    name: "///斜槓自由市/// (免攤位費)",
    location: "台北市",
    start_date: "2025-04-01",
    end_date: "2025-11-30"
  },
  // 新北市活動
  {
    name: "小碧潭捷運站4樓&1樓",
    location: "新北市",
    start_date: "2025-11-21",
    end_date: "2025-11-23"
  },
  {
    name: "小碧潭捷運站4樓&1樓",
    location: "新北市",
    start_date: "2025-11-14",
    end_date: "2025-11-16"
  },
  {
    name: "小碧潭捷運站4樓&1樓",
    location: "新北市",
    start_date: "2025-08-29",
    end_date: "2025-08-31"
  },
  {
    name: "集光市 × 日月光【EP.4 日常療癒計畫】",
    location: "新北市",
    start_date: "2025-07-19",
    end_date: "2025-07-20"
  },
  {
    name: "集光市 #汐光市集｜與汐止一起生活的在地提案",
    location: "新北市",
    start_date: "2025-07-12",
    end_date: "2025-07-13"
  },
  {
    name: "板橋府中後站廣場",
    location: "新北市",
    start_date: "2025-06-27",
    end_date: "2025-06-29"
  },
  {
    name: "板橋府中後站廣場",
    location: "新北市",
    start_date: "2025-06-20",
    end_date: "2025-06-22"
  },
  {
    name: "新店捷運站出口廣場-夏日微光市集",
    location: "新北市",
    start_date: "2025-06-13",
    end_date: "2025-06-15"
  },
  {
    name: "無邊境經典市集-夏日版",
    location: "新北市",
    start_date: "2025-06-13",
    end_date: "2025-06-15"
  },
  {
    name: "淡水捷運2號出口廣場",
    location: "新北市",
    start_date: "2025-06-06",
    end_date: "2025-06-08"
  },
  {
    name: "中和四號公園",
    location: "新北市",
    start_date: "2025-06-06",
    end_date: "2025-06-08"
  },
  {
    name: "美河市新店IKEA 1F&4F",
    location: "新北市",
    start_date: "2025-04-01",
    end_date: "2025-06-30"
  }
];

// 台北旅遊活動資料（來自 taipei_travel.csv）
const rawTravelEvents = [
  {
    name: "燭龍現身臺北天文館！端午連假別錯過神話與科學的奇幻旅程",
    location: "25.0958,121.518",
    start_date: "2025-05-30",
    end_date: "2025-06-01"
  },
  {
    name: "2025臺北文學館籌備處「想像一間 #______文學館」展覽今日開展 邀您一起填空文學館的想像關鍵字！",
    location: "25.0158,121.527",
    start_date: "2025-05-28",
    end_date: "2025-07-20"
  },
  {
    name: "士林好神！2025再出發：打造文化共感X永續生活圈 手作體驗日、走透透影片、福運抽獎接力開跑",
    location: "25.0978,121.526",
    start_date: "2025-05-23",
    end_date: "2025-07-31"
  },
  {
    name: "此身，未竟之境 BODY–Where we are at",
    location: "25.0539,121.508",
    start_date: "2025-05-22",
    end_date: "2025-06-22"
  },
  {
    name: "「那天，我掉進了兔子洞」 2025後生文學獎徵文活動熱烈進行中",
    location: "25.0345,121.543",
    start_date: "2025-05-20",
    end_date: "2025-08-31"
  },
  {
    name: "《平衡的輪廓》李芷筠 張舫少芹 雙個展",
    location: "25.0468,121.556",
    start_date: "2025-05-16",
    end_date: "2025-06-28"
  },
  {
    name: "五月臺北花博農民市集 溫馨五月情 禮親情意濃",
    location: "25.0708,121.521",
    start_date: "2025-05-10",
    end_date: "2025-06-01"
  },
  {
    name: "榮枯盛衰-堉泉個展  Wax and Wane - Yu Chuan Solo Exhibition",
    location: "25.0388,121.524",
    start_date: "2025-05-10",
    end_date: "2025-07-04"
  },
  {
    name: "羅智信：番茄種子通過身體發芽",
    location: "25.0466,121.549",
    start_date: "2025-05-03",
    end_date: "2025-07-19"
  },
  {
    name: "「你來顧著火吧」——以傳家寶串聯臺灣原住民族文化記憶，凱達格蘭文化館全新特展即將登場！",
    location: "25.1371,121.506",
    start_date: "2025-04-25",
    end_date: "2025-08-03"
  },
  {
    name: "蔡瑜 創作個展【凝望•日常幻景】Tsai Yu Solo Exhibition: Gazing Into the Daily Mirage",
    location: "25.0674,121.519",
    start_date: "2025-04-15",
    end_date: "2025-06-01"
  },
  {
    name: "林恩崙 創作個展 【Kick the Can to the Playground】",
    location: "25.0674,121.519",
    start_date: "2025-04-15",
    end_date: "2025-06-01"
  },
  {
    name: "游智涵 創作個展【精神時光屋】 Yu Chih-Han Solo Exhibition: Room of Spirit and Time",
    location: "25.0674,121.519",
    start_date: "2025-04-15",
    end_date: "2025-06-01"
  },
  {
    name: "2025松山文創學園祭 逐光啟程：Highlight",
    location: "25.0438,121.561",
    start_date: "2025-04-09",
    end_date: "2025-06-17"
  },
  {
    name: "北市圖萬興分館「四季讀書樂」系列主題書展伴您隨著季節的節奏 享受閱讀的樂趣",
    location: "24.9887,121.577",
    start_date: "2025-02-14",
    end_date: "2025-12-15"
  },
  {
    name: "郵政博物館臺北館「幸福滋味－美食郵票特展」",
    location: "25.0468,121.511",
    start_date: "2025-01-11",
    end_date: "2025-06-29"
  },
  {
    name: "bulabulay原民之耀特展-臺灣原住民族經典文物聯展暨巡迴展",
    location: "25.0178,121.535",
    start_date: "2024-11-15",
    end_date: "2025-07-31"
  }
];

// 地點與行政區的對應關係
const locationToDistrictMap = {
  "圓山花博": "中山區",
  "南港瓶蓋工廠": "南港區", 
  "龍山": "萬華區",
  "安森町": "中山區",
  "大安森": "大安區",
  "忠孝敦化": "大安區",
  "東區地下街": "大安區",
  "東森廣場": "內湖區",
  "風格酒食": "信義區",
  "夢想寄售": "大安區",
  "南村": "信義區",
  "斜槓自由": "中正區",
  "小碧潭": "新店區",
  "集光市": "汐止區",
  "汐光市集": "汐止區",
  "板橋府中": "板橋區",
  "新店捷運": "新店區",
  "無邊境": "新店區",
  "淡水捷運": "淡水區",
  "中和四號": "中和區",
  "美河市": "新店區"
};

// 將地點對應到行政區
function mapLocationToDistrict(eventName, location) {
  // 首先檢查活動名稱中的關鍵詞
  for (const [keyword, district] of Object.entries(locationToDistrictMap)) {
    if (eventName.includes(keyword)) {
      return district;
    }
  }
  
  // 如果是台北市但無法對應具體地點，預設為中正區
  if (location.includes("台北市")) {
    return "中正區";
  }
  
  // 如果是新北市但無法對應具體地點，預設為板橋區
  if (location.includes("新北市")) {
    return "板橋區";
  }
  
  return "中正區"; // 預設值
}

// 轉換市集活動為組件所需的格式
function convertMarketEventsToDistrictFormat() {
  const districtEvents = {};
  let eventId = 1;
  
  rawMarketEvents.forEach(event => {
    const district = mapLocationToDistrict(event.name, event.location);
    
    if (!districtEvents[district]) {
      districtEvents[district] = [];
    }
    
    // 轉換為組件期望的格式
    const formattedEvent = {
      id: eventId++,
      name: event.name,
      type: "市集",
      location: event.name, // 使用活動名稱作為詳細地點
      startTime: event.start_date + "T09:00:00",
      endTime: event.end_date + "T18:00:00",
      description: `真實市集活動：${event.name}`
    };
    
    districtEvents[district].push(formattedEvent);
  });
  
  return districtEvents;
}

// 轉換並合併所有活動資料
function convertAllEventsToDistrictFormat() {
  // 獲取市集活動資料
  const marketEvents = convertMarketEventsToDistrictFormat();
  
  // 獲取旅遊展覽活動資料
  const travelEvents = processTravelData(rawTravelEvents);
  
  // 合併兩種類型的活動
  const allDistrictEvents = { ...marketEvents };
  
  Object.keys(travelEvents).forEach(district => {
    if (!allDistrictEvents[district]) {
      allDistrictEvents[district] = [];
    }
    allDistrictEvents[district] = [...allDistrictEvents[district], ...travelEvents[district]];
  });
  
  return allDistrictEvents;
}

// 導出整合後的活動資料
export const realDistrictEvents = convertAllEventsToDistrictFormat();

// 導出處理函數
export function getRealMarketData() {
  return realDistrictEvents;
} 
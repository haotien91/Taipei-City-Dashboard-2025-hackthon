import requests
from bs4 import BeautifulSoup
import re
import csv
import calendar
from datetime import datetime

def parse_event_info(text):
    # 格式一：2025.07.11~13 台北市-市集名稱
    match = re.match(r"(\d{4})\.(\d{2})\.(\d{2})~(\d{2}) (.+?)\-(.+)", text)
    if match:
        year, month, start_day, end_day, city, name = match.groups()
        start_date = f"{year}-{month}-{start_day}"
        end_date = f"{year}-{month}-{end_day}"
        return {
            "name": name.strip(),
            "location": city.strip(),
            "start_date": start_date,
            "end_date": end_date
        }

    # 格式二：2025.07~12月 新北市-市集名稱
    match_month_range = re.match(r"(\d{4})\.(\d{2})~(\d{1,2})月 (.+?)\-(.+)", text)
    if match_month_range:
        year, start_month, end_month, city, name = match_month_range.groups()
        start_date = f"{year}-{start_month}-01"
        end_month = end_month.zfill(2)
        last_day = calendar.monthrange(int(year), int(end_month))[1]
        end_date = f"{year}-{end_month}-{last_day:02d}"
        return {
            "name": name.strip(),
            "location": city.strip(),
            "start_date": start_date,
            "end_date": end_date
        }

    return None

def fetch_market_events(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    content = soup.find('div', class_='entry-content')
    lines = content.get_text(separator='\n').splitlines()

    today = datetime.strptime("2025-05-31", "%Y-%m-%d")
    events = []
    seen = set()

    for line in lines:
        line = line.strip()
        if re.search(r"\d{4}\.\d{2}", line):
            event = parse_event_info(line)
            if event:
                # 僅保留雙北
                if "台北市" in event["location"] or "新北市" in event["location"]:
                    try:
                        end_date = datetime.strptime(event["end_date"], "%Y-%m-%d")
                        if end_date >= today:
                            key = (event["name"], event["location"], event["start_date"], event["end_date"])
                            if key not in seen:
                                seen.add(key)
                                events.append(event)
                    except ValueError as e:
                        print(f"⚠️ 日期錯誤略過：{event}，錯誤：{e}")

    # 開始日期由未來到過去排序
    events.sort(key=lambda e: datetime.strptime(e["start_date"], "%Y-%m-%d"), reverse=True)
    return events

def save_to_csv(events, filename):
    with open(filename, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=["name", "location", "start_date", "end_date"])
        writer.writeheader()
        writer.writerows(events)

# 主程式
if __name__ == "__main__":
    url = "https://www.twmarket.tw/?page_id=179"
    all_events = fetch_market_events(url)

    # 拆分兩份：台北市與雙北
    taipei_events = [e for e in all_events if e["location"] == "台北市"]
    double_north_events = all_events  # 台北 + 新北

    save_to_csv(taipei_events, "taipei_events.csv")
    save_to_csv(double_north_events, "double_north_events.csv")

    print(f"✅ 已儲存 {len(taipei_events)} 筆 台北市活動於 taipei_events.csv")
    print(f"✅ 已儲存 {len(double_north_events)} 筆 雙北活動於 double_north_events.csv")

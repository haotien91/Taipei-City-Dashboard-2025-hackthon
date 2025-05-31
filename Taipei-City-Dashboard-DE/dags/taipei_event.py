import cloudscraper
import csv
from datetime import datetime, timedelta

def fetch_events():
    scraper = cloudscraper.create_scraper()
    base_url = "https://www.travel.taipei/open-api/zh-tw/Events/Activity"
    headers = {"Accept": "application/json"}

    today = datetime.today()
    begin_date = (today - timedelta(days=30)).strftime("%Y-%m-%d")
    end_date = (today + timedelta(days=90)).strftime("%Y-%m-%d")

    events = []
    page = 1

    while True:
        params = {
            "begin": begin_date,
            "end": end_date,
            "page": page
        }

        print(f"🔍 請求第 {page} 頁：{base_url}")
        response = scraper.get(base_url, headers=headers, params=params)
        print("Status Code:", response.status_code)

        try:
            data = response.json()
        except Exception as e:
            print(f"⚠️ 第 {page} 頁 JSON 解析失敗：{e}")
            break

        items = data.get("data", [])
        print(f"🔢 第 {page} 頁包含 {len(items)} 筆資料")

        if not items:
            print("📭 無更多活動，結束。")
            break

        for item in items:
            try:
                name = item.get("title", "").strip()

                # 保留經緯度為 location
                lat = item.get("nlat", "").strip()
                lon = item.get("elong", "").strip()
                location = f"{lat},{lon}" if lat and lon else ""

                start_str = item.get("begin", "").split()[0]
                end_str = item.get("end", "").split()[0]

                if not start_str or not end_str:
                    continue

                start_date = datetime.strptime(start_str, "%Y-%m-%d")
                end_date_obj = datetime.strptime(end_str, "%Y-%m-%d")

                if end_date_obj >= today:
                    events.append({
                        "name": name,
                        "location": location,
                        "start_date": start_date.strftime("%Y-%m-%d"),
                        "end_date": end_date_obj.strftime("%Y-%m-%d")
                    })
            except Exception as e:
                print(f"⚠️ 處理活動資料時錯誤：{e}")
                continue

        page += 1

    events.sort(key=lambda e: e["start_date"], reverse=True)
    return events

def save_to_csv(events, filename):
    with open(filename, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=["name", "location", "start_date", "end_date"])
        writer.writeheader()
        writer.writerows(events)

if __name__ == "__main__":
    events = fetch_events()
    print(f"\n📦 共抓到 {len(events)} 筆未結束活動")
    save_to_csv(events, "taipei_travel.csv")
    print(f"✅ 活動已儲存至 taipei_travel.csv")

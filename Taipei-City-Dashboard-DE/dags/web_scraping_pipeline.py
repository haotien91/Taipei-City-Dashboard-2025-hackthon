from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.configuration import conf
import pandas as pd
import logging
import os

# 設置數據目錄路徑
DAG_FOLDER = conf.get('core', 'dags_folder')
DATA_FOLDER = os.path.join(os.path.dirname(DAG_FOLDER), 'data')

# DAG 的默認參數
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 3, 27),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# 創建 DAG
dag = DAG(
    'web_scraping_pipeline',
    default_args=default_args,
    description='Web scraping pipeline for collecting and processing data',
    schedule_interval='0 * * * *',  # 每小時整點執行
    catchup=False
)

def scrape_data(**context):
    """執行爬蟲並保存數據到 CSV"""
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

        today = datetime.now()  # 使用當前日期而不是固定日期
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
                            logging.warning(f"⚠️ 日期錯誤略過：{event}，錯誤：{e}")

        # 開始日期由未來到過去排序
        events.sort(key=lambda e: datetime.strptime(e["start_date"], "%Y-%m-%d"), reverse=True)
        return events

    # 確保數據目錄存在
    data_dir = os.path.join(DATA_FOLDER, 'scraped_data')
    os.makedirs(data_dir, exist_ok=True)
    
    # 設置輸出文件路徑
    taipei_events_csv = os.path.join(data_dir, 'taipei_events.csv')
    double_north_events_csv = os.path.join(data_dir, 'double_north_events.csv')
    
    # 執行爬蟲
    url = "https://www.twmarket.tw/?page_id=179"
    try:
        all_events = fetch_market_events(url)
        
        # 拆分兩份：台北市與雙北
        taipei_events = [e for e in all_events if e["location"] == "台北市"]
        double_north_events = all_events  # 台北 + 新北

        # 保存到 CSV
        with open(taipei_events_csv, mode='w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=["name", "location", "start_date", "end_date"])
            writer.writeheader()
            writer.writerows(taipei_events)
        
        with open(double_north_events_csv, mode='w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=["name", "location", "start_date", "end_date"])
            writer.writeheader()
            writer.writerows(double_north_events)
        
        logging.info(f"✅ 已儲存 {len(taipei_events)} 筆 台北市活動於 {taipei_events_csv}")
        logging.info(f"✅ 已儲存 {len(double_north_events)} 筆 雙北活動於 {double_north_events_csv}")
        
        # 返回兩個文件路徑，供後續任務使用
        return {
            'taipei_events': taipei_events_csv,
            'double_north_events': double_north_events_csv
        }
        
    except Exception as e:
        logging.error(f"爬蟲過程發生錯誤: {str(e)}")
        raise

def process_data(**context):
    """處理爬取的數據"""
    ti = context['task_instance']
    csv_paths = ti.xcom_pull(task_ids='scrape_data')
    
    processed_files = {}
    
    try:
        for file_type, csv_path in csv_paths.items():
            # 讀取 CSV 文件
            df = pd.read_csv(csv_path)
            
            # 數據處理邏輯
            # 1. 轉換日期格式
            df['start_date'] = pd.to_datetime(df['start_date'])
            df['end_date'] = pd.to_datetime(df['end_date'])
            
            # 2. 添加額外的計算列
            df['duration_days'] = (df['end_date'] - df['start_date']).dt.days + 1
            df['is_active'] = df['end_date'] >= pd.Timestamp.now()
            
            # 3. 添加唯一識別碼
            df['event_id'] = range(1, len(df) + 1)
            
            # 保存處理後的數據
            processed_csv = csv_path.replace('.csv', '_processed.csv')
            df.to_csv(processed_csv, index=False)
            logging.info(f"已處理並保存 {file_type} 數據到 {processed_csv}")
            
            processed_files[file_type] = processed_csv
        
        return processed_files
        
    except Exception as e:
        logging.error(f"處理數據時發生錯誤: {str(e)}")
        raise

def load_to_database(**context):
    """將處理後的數據載入 PostgreSQL"""
    ti = context['task_instance']
    processed_files = ti.xcom_pull(task_ids='process_data')
    
    try:
        # 連接到 PostgreSQL
        pg_hook = PostgresHook(postgres_conn_id='postgres_default')
        engine = pg_hook.get_sqlalchemy_engine()
        
        total_rows = 0
        for file_type, processed_csv in processed_files.items():
            # 讀取處理後的數據
            df = pd.read_csv(processed_csv)
            
            # 創建表格並插入數據
            table_name = f'market_events_{file_type}'
            df.to_sql(
                table_name,
                engine,
                if_exists='replace',  # 每次更新整個表格
                index=False,
                schema='public'
            )
            
            # 驗證數據已被插入
            result = engine.execute(f"SELECT COUNT(*) FROM {table_name}").scalar()
            total_rows += result
            logging.info(f"✅ 已成功載入 {result} 筆資料到 {table_name}")
        
        logging.info(f"✅ 總共載入 {total_rows} 筆資料到資料庫")
        
    except Exception as e:
        logging.error(f"載入資料到 PostgreSQL 時發生錯誤: {str(e)}")
        raise

def cleanup_files(**context):
    """清理臨時文件"""
    ti = context['task_instance']
    original_files = ti.xcom_pull(task_ids='scrape_data')
    processed_files = ti.xcom_pull(task_ids='process_data')
    
    try:
        # 刪除原始 CSV
        for file_type, file_path in original_files.items():
            if os.path.exists(file_path):
                os.remove(file_path)
                logging.info(f"已刪除原始檔案: {file_path}")
        
        # 刪除處理後的 CSV
        for file_type, file_path in processed_files.items():
            if os.path.exists(file_path):
                os.remove(file_path)
                logging.info(f"已刪除處理後檔案: {file_path}")
            
    except Exception as e:
        logging.error(f"清理檔案時發生錯誤: {str(e)}")
        raise

# 定義任務
scrape_task = PythonOperator(
    task_id='scrape_data',
    python_callable=scrape_data,
    provide_context=True,
    dag=dag,
)

process_task = PythonOperator(
    task_id='process_data',
    python_callable=process_data,
    provide_context=True,
    dag=dag,
)

load_db_task = PythonOperator(
    task_id='load_to_database',
    python_callable=load_to_database,
    provide_context=True,
    dag=dag,
)

cleanup_task = PythonOperator(
    task_id='cleanup_files',
    python_callable=cleanup_files,
    provide_context=True,
    dag=dag,
)

# 設定任務依賴關係
scrape_task >> process_task >> load_db_task >> cleanup_task 
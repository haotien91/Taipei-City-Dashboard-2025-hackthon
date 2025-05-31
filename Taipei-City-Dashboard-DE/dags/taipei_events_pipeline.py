from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.configuration import conf
import pandas as pd
import logging
import os
import requests
import csv

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
    'taipei_events_pipeline',
    default_args=default_args,
    description='Pipeline for scraping Taipei events data',
    schedule_interval='0 0 * * *',  # 每天午夜執行
    catchup=False
)

def scrape_data(**context):
    """執行爬蟲並保存數據到 CSV"""
    # 確保數據目錄存在
    data_dir = os.path.join(DATA_FOLDER, 'scraped_data')
    os.makedirs(data_dir, exist_ok=True)
    
    # 設置輸出文件路徑
    events_csv = os.path.join(data_dir, 'taipei_events_data.csv')
    
    try:
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

            logging.info(f"🔍 請求第 {page} 頁：{base_url}")
            response = requests.get(base_url, headers=headers, params=params)
            logging.info(f"Status Code: {response.status_code}")

            try:
                data = response.json()
            except Exception as e:
                logging.warning(f"⚠️ 第 {page} 頁 JSON 解析失敗：{e}")
                break

            items = data.get("data", [])
            logging.info(f"🔢 第 {page} 頁包含 {len(items)} 筆資料")

            if not items:
                logging.info("📭 無更多活動，結束。")
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
                    logging.warning(f"⚠️ 處理活動資料時錯誤：{e}")
                    continue

            page += 1

        events.sort(key=lambda e: e["start_date"], reverse=True)
        
        # 保存到 CSV
        with open(events_csv, mode='w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=["name", "location", "start_date", "end_date"])
            writer.writeheader()
            writer.writerows(events)
        
        logging.info(f"✅ 已儲存 {len(events)} 筆活動資料於 {events_csv}")
        
        return {'events': events_csv}
        
    except Exception as e:
        logging.error(f"爬蟲過程發生錯誤: {str(e)}")
        raise

def process_data(**context):
    """處理爬取的數據"""
    ti = context['task_instance']
    csv_paths = ti.xcom_pull(task_ids='scrape_data')
    
    try:
        events_csv = csv_paths['events']
        # 讀取 CSV 文件
        df = pd.read_csv(events_csv)
        
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
        processed_csv = events_csv.replace('.csv', '_processed.csv')
        df.to_csv(processed_csv, index=False)
        logging.info(f"已處理並保存數據到 {processed_csv}")
        
        return {'events': processed_csv}
        
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
        
        processed_csv = processed_files['events']
        # 讀取處理後的數據
        df = pd.read_csv(processed_csv)
        
        # 創建表格並插入數據
        table_name = 'taipei_events'
        df.to_sql(
            table_name,
            engine,
            if_exists='replace',  # 每次更新整個表格
            index=False,
            schema='public'
        )
        
        # 驗證數據已被插入
        result = engine.execute(f"SELECT COUNT(*) FROM {table_name}").scalar()
        logging.info(f"✅ 已成功載入 {result} 筆資料到 {table_name}")
        
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
        if os.path.exists(original_files['events']):
            os.remove(original_files['events'])
            logging.info(f"已刪除原始檔案: {original_files['events']}")
        
        # 刪除處理後的 CSV
        if os.path.exists(processed_files['events']):
            os.remove(processed_files['events'])
            logging.info(f"已刪除處理後檔案: {processed_files['events']}")
            
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
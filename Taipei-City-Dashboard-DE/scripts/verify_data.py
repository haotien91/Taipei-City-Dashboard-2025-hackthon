import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import sys
from tabulate import tabulate

def connect_to_db():
    """連接到數據庫"""
    try:
        conn = psycopg2.connect(
            dbname="taipei_dashboard",
            user="airflow",
            password="airflow",
            host="localhost",
            port="5432"
        )
        return conn
    except Exception as e:
        print(f"❌ 連接數據庫失敗: {e}")
        sys.exit(1)

def check_table_data(cursor, table_name):
    """檢查表格數據"""
    print(f"\n📊 檢查 {table_name} 表格:")
    
    # 檢查記錄總數
    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    count = cursor.fetchone()['count']
    print(f"總記錄數: {count}")
    
    if count == 0:
        print("⚠️ 警告：表格中沒有數據")
        return
    
    # 檢查最新的記錄
    cursor.execute(f"""
        SELECT 
            event_id,
            name,
            location,
            start_date,
            end_date,
            duration_days,
            is_active,
            created_at
        FROM {table_name}
        ORDER BY created_at DESC
        LIMIT 5
    """)
    records = cursor.fetchall()
    
    print("\n最新的5筆記錄:")
    headers = records[0].keys()
    table_data = [[str(record[col]) for col in headers] for record in records]
    print(tabulate(table_data, headers=headers, tablefmt="grid"))
    
    # 檢查活動狀態分佈
    cursor.execute(f"""
        SELECT 
            is_active,
            COUNT(*) as count,
            ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
        FROM {table_name}
        GROUP BY is_active
    """)
    status_dist = cursor.fetchall()
    print("\n活動狀態分佈:")
    for status in status_dist:
        print(f"{'活動中' if status['is_active'] else '已結束'}: "
              f"{status['count']} 筆 ({status['percentage']}%)")

def main():
    """主函數"""
    conn = connect_to_db()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # 檢查兩個表格的數據
        check_table_data(cursor, "market_events_taipei_events")
        check_table_data(cursor, "market_events_double_north_events")
        
        # 檢查視圖數據
        print("\n📊 檢查 active_markets 視圖:")
        cursor.execute("""
            SELECT 
                source,
                COUNT(*) as count
            FROM active_markets
            GROUP BY source
        """)
        view_stats = cursor.fetchall()
        print("\n當前活動市集統計:")
        for stat in view_stats:
            print(f"{stat['source']}: {stat['count']} 筆活動")
            
    except Exception as e:
        print(f"❌ 查詢執行失敗: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main() 
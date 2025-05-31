#!/bin/bash

# 顯示執行的命令
set -x

# 確保腳本在錯誤時停止
set -e

echo "開始設置環境..."

# 創建必要的目錄
mkdir -p data/scraped_data

# 設置 PostgreSQL
echo "設置 PostgreSQL..."

# 檢查 PostgreSQL 服務是否運行
if ! pg_isready; then
    echo "PostgreSQL 未運行，請先啟動 PostgreSQL 服務"
    exit 1
fi

# 創建數據庫和用戶
psql -U postgres <<EOF
CREATE DATABASE taipei_dashboard;
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE taipei_dashboard TO airflow;
EOF

# 執行初始化 SQL
psql -U postgres -d taipei_dashboard -f migrations/init.sql

# 設置 Airflow
echo "設置 Airflow..."

# 設置 Airflow 環境變數
export AIRFLOW_HOME=~/airflow

# 安裝 Airflow 和必要的依賴
pip install "apache-airflow[postgres]==2.8.1" psycopg2-binary

# 初始化 Airflow 數據庫
airflow db init

# 創建 Airflow 管理員用戶
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin

# 創建 Airflow PostgreSQL 連接
airflow connections add 'postgres_default' \
    --conn-type 'postgres' \
    --conn-login 'airflow' \
    --conn-password 'airflow' \
    --conn-host 'localhost' \
    --conn-port '5432' \
    --conn-schema 'taipei_dashboard'

# 啟動 Airflow 服務
echo "啟動 Airflow 服務..."
airflow webserver -D
airflow scheduler -D

echo "環境設置完成！"
echo "Airflow 網頁界面：http://localhost:8080"
echo "用戶名：admin"
echo "密碼：admin" 
#!/bin/bash

# 創建包含商圈活化配置的永久初始化SQL文件
# 作者: Taipei City Dashboard Team
# 目的：解決每次系統初始化會清除商圈活化配置的問題

set -e

echo "🔧 開始創建包含商圈活化配置的永久初始化SQL文件..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查容器狀態
check_containers() {
    if ! docker ps | grep -q "postgres-manager"; then
        print_error "postgres-manager 容器未運行"
        exit 1
    fi
    print_success "容器狀態正常"
}

# 創建新的初始化SQL文件
create_permanent_init() {
    print_status "創建包含商圈活化配置的永久初始化SQL文件..."
    
    # 輸出文件
    OUTPUT_FILE="db-sample-data/dashboardmanager-with-commercial.sql"
    
    # 開始構建新的SQL文件
    cat > "$OUTPUT_FILE" << 'EOF'
--
-- PostgreSQL database dump with Commercial District Configuration
-- 包含商圈活化配置的資料庫初始化文件
-- 自動生成時間：$(date)
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- 清理現有資料（但保留表結構）
TRUNCATE TABLE public.component_charts RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.component_maps RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.components RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.dashboards RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.dashboard_groups RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.query_charts RESTART IDENTITY CASCADE;

-- 插入基礎配置資料
EOF

    # 從原始檔案中提取基礎配置（排除TRUNCATE部分）
    print_status "提取基礎配置資料..."
    sed '/TRUNCATE TABLE public.query_charts/d' db-sample-data/dashboardmanager-demo.sql | \
    sed '/^--.*PostgreSQL database dump complete.*$/,$d' >> "$OUTPUT_FILE"
    
    # 添加商圈活化的額外配置
    print_status "添加商圈活化配置..."
    cat >> "$OUTPUT_FILE" << 'EOF'

-- ========================================
-- 商圈活化配置 (Auto-generated)
-- ========================================
EOF

    # 匯出當前的商圈活化相關配置
    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
    SELECT 'INSERT INTO public.dashboards (id, index, name, components, icon, updated_at, created_at) VALUES (' ||
           id || ', ''' || index || ''', ''' || name || ''', ''' || 
           COALESCE(array_to_string(components, ','), '') || ''', ''' || icon || ''', ''' ||
           updated_at || ''', ''' || created_at || ''');'
    FROM public.dashboards 
    WHERE index LIKE '%commercial%';
    " -t | grep -v "^$" >> "$OUTPUT_FILE"

    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
    SELECT 'INSERT INTO public.components (id, index, name) VALUES (' ||
           id || ', ''' || index || ''', ''' || name || ''');'
    FROM public.components 
    WHERE index LIKE '%commercial%';
    " -t | grep -v "^$" >> "$OUTPUT_FILE"

    docker exec postgres-manager psql -U postgres -d dashboardmanager -c "
    SELECT 'INSERT INTO public.component_maps (id, index, title, type, source, size, icon, paint, property) VALUES (' ||
           id || ', ''' || index || ''', ''' || title || ''', ''' || type || ''', ''' || 
           source || ''', ' || COALESCE('''' || size || '''', 'NULL') || ', ' || 
           COALESCE('''' || icon || '''', 'NULL') || ', ''' || paint::text || ''', ''' || 
           property::text || ''');'
    FROM public.component_maps 
    WHERE index LIKE '%market_events%';
    " -t | grep -v "^$" >> "$OUTPUT_FILE"

    # 完成SQL文件
    cat >> "$OUTPUT_FILE" << 'EOF'

-- 更新序列值
SELECT pg_catalog.setval('public.dashboards_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.dashboards), true);
SELECT pg_catalog.setval('public.components_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.components), true);
SELECT pg_catalog.setval('public.component_maps_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.component_maps), true);

-- PostgreSQL database dump complete (with Commercial District)
EOF

    print_success "永久初始化SQL文件已創建：$OUTPUT_FILE"
}

# 更新當前配置到新文件
update_with_current_config() {
    print_status "將當前完整配置匯出到新初始化文件..."
    
    # 匯出完整的當前狀態
    docker exec postgres-manager pg_dump -U postgres dashboardmanager \
        --inserts --data-only \
        -t component_charts \
        -t component_maps \
        -t components \
        -t dashboards \
        -t dashboard_groups \
        -t query_charts \
        -t contributors \
        -t groups \
        > db-sample-data/dashboardmanager-complete-current.sql
    
    # 添加必要的SQL指令
    cat > db-sample-data/dashboardmanager-permanent.sql << 'EOF'
--
-- PostgreSQL database dump with Complete Configuration including Commercial District
-- 包含完整商圈活化配置的資料庫初始化文件
-- 
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- 清理現有資料（但保留表結構）
TRUNCATE TABLE public.component_charts RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.component_maps RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.components RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.dashboards RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.dashboard_groups RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.query_charts RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.contributors RESTART IDENTITY CASCADE;
TRUNCATE TABLE public.groups RESTART IDENTITY CASCADE;

EOF

    # 添加當前完整配置
    cat db-sample-data/dashboardmanager-complete-current.sql >> db-sample-data/dashboardmanager-permanent.sql
    
    # 添加序列更新
    cat >> db-sample-data/dashboardmanager-permanent.sql << 'EOF'

-- 更新序列值
SELECT pg_catalog.setval('public.dashboards_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.dashboards), true);
SELECT pg_catalog.setval('public.components_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.components), true);
SELECT pg_catalog.setval('public.component_maps_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.component_maps), true);
SELECT pg_catalog.setval('public.contributors_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.contributors), true);
SELECT pg_catalog.setval('public.groups_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.groups), true);

-- PostgreSQL database dump complete
EOF

    print_success "完整永久初始化文件已創建：db-sample-data/dashboardmanager-permanent.sql"
}

# 創建環境變數更新腳本
create_env_update_script() {
    print_status "創建環境變數更新腳本..."
    
    cat > scripts/switch-to-permanent-init.sh << 'EOF'
#!/bin/bash

# 切換到包含商圈活化配置的永久初始化文件
echo "🔄 切換到永久初始化配置..."

# 備份原始 .env 文件
if [ -f ".env" ]; then
    cp .env .env.backup
    echo "✅ 已備份原始 .env 文件為 .env.backup"
fi

# 更新 .env 文件中的 MANAGER_SAMPLE_FILE
if [ -f ".env" ]; then
    # 檢查是否已有 MANAGER_SAMPLE_FILE 設定
    if grep -q "MANAGER_SAMPLE_FILE" .env; then
        # 更新現有設定
        sed -i.bak 's/MANAGER_SAMPLE_FILE=.*/MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql/' .env
        echo "✅ 已更新 .env 中的 MANAGER_SAMPLE_FILE 設定"
    else
        # 添加新設定
        echo "MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql" >> .env
        echo "✅ 已新增 MANAGER_SAMPLE_FILE 設定到 .env"
    fi
else
    echo "⚠️  未找到 .env 文件，請手動設定 MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql"
fi

echo ""
echo "🎉 配置更新完成！"
echo ""
echo "📋 後續步驟："
echo "  1. 重啟容器以應用新配置："
echo "     docker-compose -f docker/docker-compose-init.yaml up dashboard-be-init-manager"
echo ""
echo "  2. 或者如果要完全重新初始化："
echo "     docker-compose -f docker/docker-compose-db.yaml down"
echo "     docker volume rm postgres_manager_data"
echo "     docker-compose -f docker/docker-compose-db.yaml up -d"
echo "     docker-compose -f docker/docker-compose-init.yaml up"
echo ""
echo "🚀 現在系統啟動時將自動包含商圈活化配置！"
EOF

    chmod +x scripts/switch-to-permanent-init.sh
    print_success "環境變數更新腳本已創建：scripts/switch-to-permanent-init.sh"
}

# 顯示完成訊息
show_completion_message() {
    echo ""
    echo "🎉 永久解決方案已準備完成！"
    echo ""
    echo "📁 創建的文件："
    echo "  • db-sample-data/dashboardmanager-permanent.sql - 包含商圈活化的永久初始化文件"
    echo "  • scripts/switch-to-permanent-init.sh - 環境變數切換腳本"
    echo ""
    echo "🚀 使用方法："
    echo ""
    echo "方案 A：自動切換（推薦）"
    echo "  ./scripts/switch-to-permanent-init.sh"
    echo ""
    echo "方案 B：手動設定"
    echo "  1. 編輯 .env 文件，設定："
    echo "     MANAGER_SAMPLE_FILE=dashboardmanager-permanent.sql"
    echo ""
    echo "  2. 重新初始化資料庫："
    echo "     docker-compose -f docker/docker-compose-init.yaml up dashboard-be-init-manager"
    echo ""
    echo "✅ 優勢："
    echo "  • 🔒 永久保存商圈活化配置"
    echo "  • 🚀 系統啟動時自動載入"
    echo "  • 🛡️ 不需要手動執行腳本"
    echo "  • 🔄 支援重複初始化"
    echo ""
}

# 主執行流程
main() {
    echo "=================================================="
    echo "     商圈活化配置永久化解決方案               "
    echo "  🔧 解決系統重啟後需要重新執行腳本的問題      "
    echo "=================================================="
    echo ""
    
    check_containers
    update_with_current_config
    create_env_update_script
    show_completion_message
}

# 執行主函數
main "$@" 
#!/bin/bash

# 清理不需要的腳本和SQL文件
# 保留核心永久化解決方案的文件

set -e

echo "🧹 開始清理不需要的腳本和SQL文件..."

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

# 創建備份目錄
create_backup() {
    BACKUP_DIR="cleanup-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR/scripts"
    mkdir -p "$BACKUP_DIR/db-sample-data"
    echo "$BACKUP_DIR"
}

# 清理舊版腳本文件
cleanup_old_scripts() {
    print_status "清理舊版腳本文件..."
    
    # 需要刪除的舊腳本文件
    OLD_SCRIPTS=(
        "動態地圖功能使用指南.md"
        "restore-dynamic-map-config.sh"
        "setup-commercial-district-metrotaipei-with-dynamic.sh"
        "setup-commercial-district-with-dynamic.sh"
        "update-market-colors.js"
        "test_dynamic_colors.py"
        "update_market_colors.py"
        "check_map_status.py"
        "verify_coordinates.py"
        "verify-coordinates.js"
        "setup-metrotaipei-market-map.sh"
        "setup-market-map.sh"
        "setup-commercial-district-metrotaipei.sh"
        "setup-commercial-district.sh"
        "setup-commercial-district-with-data.sh"
    )
    
    for file in "${OLD_SCRIPTS[@]}"; do
        if [ -f "scripts/$file" ]; then
            # 備份文件
            cp "scripts/$file" "$1/scripts/"
            # 刪除文件
            rm "scripts/$file"
            print_success "已刪除: scripts/$file"
        fi
    done
}

# 清理舊版SQL文件
cleanup_old_sql() {
    print_status "清理舊版SQL文件..."
    
    # 需要刪除的臨時/重複SQL文件
    OLD_SQL_FILES=(
        "dashboardmanager-complete-current.sql"
        "current-additional-configs.sql"
        "current-query-charts.sql"
        "dashboardmanager-demo-backup.sql"
        "market-events-dynamic-map.sql"
        "commercial-district-metrotaipei-init.sql"
        "restore-dynamic-map-temp.sql"
        "market-events-metrotaipei-map-init.sql"
        "market-events-map-init.sql"
        "commercial-district-init.sql"
    )
    
    for file in "${OLD_SQL_FILES[@]}"; do
        if [ -f "db-sample-data/$file" ]; then
            # 備份文件
            cp "db-sample-data/$file" "$1/db-sample-data/"
            # 刪除文件
            rm "db-sample-data/$file"
            print_success "已刪除: db-sample-data/$file"
        fi
    done
}

# 清理空目錄
cleanup_empty_dirs() {
    print_status "清理空目錄..."
    
    # 檢查並清理空的modules目錄
    if [ -d "scripts/modules" ] && [ -z "$(ls -A scripts/modules)" ]; then
        rmdir "scripts/modules"
        print_success "已刪除空目錄: scripts/modules"
    fi
}

# 顯示保留的核心文件
show_retained_files() {
    print_status "保留的核心文件："
    
    echo ""
    echo "📁 Scripts (保留的核心文件):"
    echo "  ✅ create-permanent-init.sh - 生成永久配置"
    echo "  ✅ switch-to-permanent-init.sh - 環境變數切換"
    echo "  ✅ test-permanent-solution.sh - 測試腳本"
    echo "  ✅ 商圈活化永久化解決方案.md - 完整文檔"
    echo "  ✅ cleanup-unused-files.sh - 本清理腳本"
    
    echo ""
    echo "📁 SQL文件 (保留的核心文件):"
    echo "  ✅ dashboardmanager-permanent.sql - 永久初始化文件"
    echo "  ✅ dashboardmanager-demo.sql - 原始演示文件"
    echo "  ✅ dashboard-demo.sql - 完整資料庫備份"
}

# 顯示清理統計
show_cleanup_stats() {
    local backup_dir=$1
    
    echo ""
    echo "📊 清理統計："
    echo "  🗑️ 已刪除 Scripts: $(ls $backup_dir/scripts/ 2>/dev/null | wc -l) 個文件"
    echo "  🗑️ 已刪除 SQL文件: $(ls $backup_dir/db-sample-data/ 2>/dev/null | wc -l) 個文件"
    echo "  📁 剩餘 Scripts: $(ls scripts/ | wc -l) 個文件"
    echo "  📁 剩餘 SQL文件: $(ls db-sample-data/ | wc -l) 個文件"
    echo ""
    echo "💾 備份位置: $backup_dir"
    echo "📝 如需恢復，可從備份目錄中復制文件"
}

# 主執行流程
main() {
    echo "=================================================="
    echo "     清理不需要的腳本和SQL文件                "
    echo "  🧹 保留核心永久化解決方案文件              "
    echo "=================================================="
    echo ""
    
    # 顯示清理前狀態
    print_status "清理前狀態："
    echo "  📁 Scripts目錄: $(ls scripts/ | wc -l) 個文件"
    echo "  📁 SQL文件: $(ls db-sample-data/ | wc -l) 個文件"
    echo ""
    
    # 確認操作
    print_warning "這將刪除舊版本的腳本和臨時SQL文件"
    print_warning "所有被刪除的文件都會先備份"
    echo ""
    read -p "確定要繼續清理嗎？(y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        print_status "取消清理操作"
        exit 0
    fi
    
    # 創建備份
    backup_dir=$(create_backup)
    print_success "已創建備份目錄: $backup_dir"
    
    # 執行清理
    cleanup_old_scripts "$backup_dir"
    cleanup_old_sql "$backup_dir"
    cleanup_empty_dirs
    
    # 顯示結果
    show_retained_files
    show_cleanup_stats "$backup_dir"
    
    print_success "🎉 清理完成！系統現在只保留核心功能文件"
}

# 執行主函數
main "$@" 
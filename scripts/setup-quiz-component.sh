#!/bin/bash

# 心理測驗組件一鍵部署腳本
# 作者: Taipei City Dashboard Team
# 版本: 1.0
# 日期: 2024-12-19

set -e  # 任何命令失敗就退出

echo "🧠 開始部署心理測驗組件..."

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：輸出彩色訊息
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

# 檢查 Docker 是否運行
check_docker() {
    print_status "檢查 Docker 狀態..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker 未運行，請先啟動 Docker"
        exit 1
    fi
    print_success "Docker 狀態正常"
}

# 檢查必要的容器是否運行
check_containers() {
    print_status "檢查必要容器狀態..."
    
    # 檢查 postgres-manager 容器
    if ! docker ps | grep -q "postgres-manager"; then
        print_error "postgres-manager 容器未運行"
        print_warning "請先執行: docker-compose -f docker/docker-compose-db.yaml up -d"
        exit 1
    fi
    
    print_success "資料庫容器狀態正常"
}

# 檢查必要文件是否存在
check_files() {
    print_status "檢查必要文件..."
    
    # 檢查 SQL 初始化文件
    if [ ! -f "db-sample-data/quiz-component-init.sql" ]; then
        print_error "找不到 quiz-component-init.sql 文件"
        exit 1
    fi
    
    # 檢查 Docker Compose 文件
    if [ ! -f "docker/docker-compose-quiz-component.yaml" ]; then
        print_error "找不到 docker-compose-quiz-component.yaml 文件"
        exit 1
    fi
    
    # 檢查前端組件文件
    if [ ! -f "Taipei-City-Dashboard-FE/src/components/charts/QuizChart.vue" ]; then
        print_warning "找不到 QuizChart.vue 組件，請確認前端組件已正確安裝"
    fi
    
    print_success "文件檢查完成"
}

# 部署心理測驗組件
deploy_quiz_component() {
    print_status "開始部署心理測驗組件到資料庫..."
    
    # 執行 Docker Compose 初始化
    docker-compose -f docker/docker-compose-quiz-component.yaml up
    
    # 等待容器完成
    print_status "等待初始化完成..."
    docker wait dashboard-be-init-quiz > /dev/null 2>&1
    
    # 檢查初始化結果
    if [ $? -eq 0 ]; then
        print_success "心理測驗組件資料庫初始化完成"
    else
        print_error "初始化失敗，請檢查日誌"
        docker logs dashboard-be-init-quiz
        exit 1
    fi
    
    # 清理臨時容器
    docker-compose -f docker/docker-compose-quiz-component.yaml down
}

# 重啟服務以載入新配置
restart_services() {
    print_status "重啟相關服務..."
    
    # 檢查 dashboard-be 容器是否存在
    if docker ps -a | grep -q "dashboard-be"; then
        print_status "重啟後端服務..."
        docker restart dashboard-be
        sleep 5
    fi
    
    # 檢查 dashboard-fe 容器是否存在
    if docker ps -a | grep -q "dashboard-fe"; then
        print_status "重啟前端服務..."
        docker restart dashboard-fe
        sleep 3
    fi
    
    print_success "服務重啟完成"
}

# 驗證部署結果
verify_deployment() {
    print_status "驗證部署結果..."
    
    # 檢查組件是否成功插入
    COMPONENT_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c \
        "SELECT COUNT(*) FROM components WHERE index = 'quiz_component';" 2>/dev/null | tr -d ' ')
    
    if [ "$COMPONENT_COUNT" = "1" ]; then
        print_success "心理測驗組件已成功註冊到資料庫"
    else
        print_error "組件註冊失敗，請檢查資料庫狀態"
        exit 1
    fi
    
    # 檢查儀表板是否創建
    DASHBOARD_COUNT=$(docker exec postgres-manager psql -U postgres -d dashboardmanager -t -c \
        "SELECT COUNT(*) FROM dashboards WHERE index IN ('quiz_dashboard', 'commercial_district');" 2>/dev/null | tr -d ' ')
    
    if [ "$DASHBOARD_COUNT" -ge "1" ]; then
        print_success "儀表板配置正常"
    else
        print_warning "儀表板可能需要手動檢查"
    fi
}

# 顯示訪問指南
show_access_guide() {
    echo ""
    echo "🎉 心理測驗組件部署完成！"
    echo ""
    echo "📖 使用指南："
    echo "  1. 開啟瀏覽器前往 http://localhost"
    echo "  2. 登入系統（需要有適當權限）"
    echo "  3. 在儀表板列表中找到「商圈探索測驗」或「商圈活化」"
    echo "  4. 點擊進入儀表板即可看到心理測驗組件"
    echo ""
    echo "🔧 如果看不到組件，請嘗試："
    echo "  - 強制刷新瀏覽器 (Ctrl+Shift+R 或 Cmd+Shift+R)"
    echo "  - 檢查使用者是否有 taipei 群組權限"
    echo "  - 重啟相關 Docker 容器"
    echo ""
    echo "📊 組件特色："
    echo "  ✨ 互動式心理測驗"
    echo "  🎯 12種性格類型分析"
    echo "  🗺️ 個人化商圈推薦"
    echo "  📱 響應式設計"
    echo "  🎨 紫色漸層主題"
    echo ""
}

# 主執行流程
main() {
    echo "=========================="
    echo "🧠 心理測驗組件部署工具"
    echo "=========================="
    echo ""
    
    check_docker
    check_containers
    check_files
    deploy_quiz_component
    restart_services
    verify_deployment
    show_access_guide
    
    print_success "部署流程全部完成！"
}

# 錯誤處理
trap 'print_error "部署過程中發生錯誤，請檢查上述輸出訊息"' ERR

# 執行主程序
main "$@" 
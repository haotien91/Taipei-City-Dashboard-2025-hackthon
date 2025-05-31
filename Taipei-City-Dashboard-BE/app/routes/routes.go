package routes

import (
    "github.com/gin-gonic/gin"
    "TaipeiCityDashboardBE/app/handlers"
)

func SetupRoutes(r *gin.Engine, dataHandler *handlers.DataHandler) {
    // API 版本組
    v1 := r.Group("/api/v1")
    {
        // 數據相關路由
        data := v1.Group("/data")
        {
            data.GET("/visitors", dataHandler.GetVisitorCounts)
        }
    }
} 
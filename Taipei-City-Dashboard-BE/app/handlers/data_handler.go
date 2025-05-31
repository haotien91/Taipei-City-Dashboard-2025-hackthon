package handlers

import (
    "net/http"
    "time"
    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

type VisitorCount struct {
    Location     string    `json:"location"`
    VisitorCount int       `json:"visitor_count"`
    Timestamp    time.Time `json:"timestamp"`
}

type DataHandler struct {
    db *gorm.DB
}

func NewDataHandler(db *gorm.DB) *DataHandler {
    return &DataHandler{db: db}
}

// GetVisitorCounts 獲取遊客數據
func (h *DataHandler) GetVisitorCounts(c *gin.Context) {
    var data []VisitorCount
    
    result := h.db.Table("visitor_counts").Find(&data)
    if result.Error != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to fetch visitor counts from database",
            "details": result.Error.Error(),
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "data": data,
        "total": len(data),
        "timestamp": time.Now(),
    })
} 
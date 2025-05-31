-- 創建市集活動表（台北市）
CREATE TABLE IF NOT EXISTS market_events_taipei_events (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration_days INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 創建市集活動表（雙北市）
CREATE TABLE IF NOT EXISTS market_events_double_north_events (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration_days INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 創建索引以優化查詢性能
CREATE INDEX IF NOT EXISTS idx_taipei_start_date ON market_events_taipei_events(start_date);
CREATE INDEX IF NOT EXISTS idx_taipei_end_date ON market_events_taipei_events(end_date);
CREATE INDEX IF NOT EXISTS idx_taipei_is_active ON market_events_taipei_events(is_active);
CREATE INDEX IF NOT EXISTS idx_taipei_location ON market_events_taipei_events(location);

CREATE INDEX IF NOT EXISTS idx_double_north_start_date ON market_events_double_north_events(start_date);
CREATE INDEX IF NOT EXISTS idx_double_north_end_date ON market_events_double_north_events(end_date);
CREATE INDEX IF NOT EXISTS idx_double_north_is_active ON market_events_double_north_events(is_active);
CREATE INDEX IF NOT EXISTS idx_double_north_location ON market_events_double_north_events(location);

-- 創建更新時間戳的觸發器函數
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 為兩個表添加更新時間戳的觸發器
CREATE TRIGGER update_taipei_events_updated_at
    BEFORE UPDATE ON market_events_taipei_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_double_north_events_updated_at
    BEFORE UPDATE ON market_events_double_north_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 創建視圖來顯示當前活動的市集
CREATE OR REPLACE VIEW active_markets AS
SELECT 
    event_id,
    name,
    location,
    start_date,
    end_date,
    duration_days,
    'taipei' as source
FROM market_events_taipei_events
WHERE is_active = true
UNION ALL
SELECT 
    event_id,
    name,
    location,
    start_date,
    end_date,
    duration_days,
    'double_north' as source
FROM market_events_double_north_events
WHERE is_active = true
ORDER BY start_date; 
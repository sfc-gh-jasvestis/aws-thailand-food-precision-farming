-- ============================================================================
-- 01_MARKETPLACE_INSTALL.SQL — Install marketplace data for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA RAW;

-- Free listings to install from Snowflake Marketplace:
-- Install: Snowflake Public Data (Free)
--   https://app.snowflake.com/marketplace/listing/GZTSZ290BV255

-- Paid listing (mock): OnPoint Historical Weather
--   Real data: https://app.snowflake.com/marketplace/listing/GZSOZBT22EH
--   Using mock table: WEATHER_STATIONS
CREATE TABLE IF NOT EXISTS RAW.WEATHER_STATIONS (
  ID INT AUTOINCREMENT, DATA VARIANT, LOADED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Paid listing (mock): CEIC ASEAN Macro
--   Real data: https://app.snowflake.com/marketplace/listing/GZTSZRC7HPI
--   Using mock table: THAI_AGRICULTURE
CREATE TABLE IF NOT EXISTS RAW.THAI_AGRICULTURE (
  ID INT AUTOINCREMENT, DATA VARIANT, LOADED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);


-- ============================================================================
-- 04_DYNAMIC_TABLES.SQL — Curated layer for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA CURATED;

-- FIELD_HEALTH_STATUS: Real-time field health combining sensor + satellite data
-- Source: FIELD_BLOCKS, SENSOR_READINGS, SATELLITE_INDICES
CREATE OR REPLACE DYNAMIC TABLE CURATED.FIELD_HEALTH_STATUS
  TARGET_LAG = '5 minutes'
  WAREHOUSE = FARMING_WH
AS
SELECT * FROM RAW.FIELD_BLOCKS;
-- TODO: Replace with actual join/aggregation logic per demo

-- YIELD_TIMESERIES: Yield development timeseries for ML.FORECAST input
-- Source: SATELLITE_INDICES, HARVEST_RECORDS
CREATE OR REPLACE DYNAMIC TABLE CURATED.YIELD_TIMESERIES
  TARGET_LAG = '5 minutes'
  WAREHOUSE = FARMING_WH
AS
SELECT * FROM RAW.SATELLITE_INDICES;
-- TODO: Replace with actual join/aggregation logic per demo

-- IRRIGATION_RECOMMENDATIONS: AI-optimized irrigation scheduling by field block
-- Source: SENSOR_READINGS, WEATHER_STATIONS, FIELD_BLOCKS
CREATE OR REPLACE DYNAMIC TABLE CURATED.IRRIGATION_RECOMMENDATIONS
  TARGET_LAG = '5 minutes'
  WAREHOUSE = FARMING_WH
AS
SELECT * FROM RAW.SENSOR_READINGS;
-- TODO: Replace with actual join/aggregation logic per demo

-- PEST_DISEASE_ALERTS: Detected pest and disease events from imagery analysis
-- Source: CROP_IMAGERY
CREATE OR REPLACE DYNAMIC TABLE CURATED.PEST_DISEASE_ALERTS
  TARGET_LAG = '5 minutes'
  WAREHOUSE = FARMING_WH
AS
SELECT * FROM RAW.CROP_IMAGERY;
-- TODO: Replace with actual join/aggregation logic per demo


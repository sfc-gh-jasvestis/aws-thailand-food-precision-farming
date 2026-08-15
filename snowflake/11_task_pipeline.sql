-- ============================================================================
-- 11_TASK_PIPELINE.SQL — Task DAG for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA APP;

CREATE OR REPLACE TASK APP.TASK_INGEST_SENSORS
  WAREHOUSE = FARMING_WH
  SCHEDULE = 'USING CRON 0 * * * * UTC'
  COMMENT = 'Ingest and process hourly sensor readings'
AS
  SELECT 1; -- Replace with actual refresh logic

CREATE OR REPLACE TASK APP.TASK_ANALYZE_IMAGERY
  WAREHOUSE = FARMING_WH
  SCHEDULE = 'USING CRON 0 8 * * * UTC'
  COMMENT = 'Analyze new crop imagery with Cortex Complete (multimodal)'
AS
  SELECT 1; -- Replace with actual refresh logic

CREATE OR REPLACE TASK APP.TASK_UPDATE_FORECASTS
  WAREHOUSE = FARMING_WH
  SCHEDULE = 'USING CRON 0 6 * * 1 UTC'
  COMMENT = 'Refresh weekly yield forecasts for all blocks'
AS
  SELECT 1; -- Replace with actual refresh logic

ALTER TASK APP.TASK_UPDATE_FORECASTS RESUME;
ALTER TASK APP.TASK_ANALYZE_IMAGERY RESUME;
ALTER TASK APP.TASK_INGEST_SENSORS RESUME;

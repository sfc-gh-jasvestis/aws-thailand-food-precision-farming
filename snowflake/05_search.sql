-- ============================================================================
-- 05_SEARCH.SQL — Cortex Search for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA SEARCH;

CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH.AGRONOMY_KNOWLEDGE_SEARCH
  ON ANALYSIS_NOTES
  ATTRIBUTES CROP_TYPE, ISSUE_TYPE, REGION
  WAREHOUSE = FARMING_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT * FROM RAW.CROP_IMAGERY
);

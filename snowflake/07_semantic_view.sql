-- ============================================================================
-- 07_SEMANTIC_VIEW.SQL — Semantic View for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA APP;

CREATE OR REPLACE SEMANTIC VIEW APP.FARMING_ANALYTICS
  COMMENT = 'Precision agriculture, yield forecasting, and crop health analytics'
AS
  TABLES (
    CURATED.FIELD_HEALTH_STATUS AS field_health_status,CURATED.YIELD_TIMESERIES AS yield_timeseries,CURATED.IRRIGATION_RECOMMENDATIONS AS irrigation_recommendations,CURATED.PEST_DISEASE_ALERTS AS pest_disease_alerts
  );

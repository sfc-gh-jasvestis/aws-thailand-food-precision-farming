-- ============================================================================
-- 10_ALERTS_NOTIFICATIONS.SQL — Alerts for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA APP;

-- Notification integration (email)
CREATE OR REPLACE NOTIFICATION INTEGRATION aws_thailand_food_precision_farming_EMAIL_INT
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('<YOUR_EMAIL>');

-- Alert: MOISTURE_STRESS_ALERT
CREATE OR REPLACE ALERT APP.MOISTURE_STRESS_ALERT
  WAREHOUSE = FARMING_WH
  SCHEDULE = '5 MINUTE'
  COMMENT = 'Critical moisture stress — irrigation needed immediately'
IF (EXISTS (
  SELECT 1 FROM CURATED.FIELD_HEALTH_STATUS
  WHERE 1=1 -- Condition: SOIL_MOISTURE < WILTING_POINT for any block for > 24 hours
))
THEN
  CALL SYSTEM$SEND_EMAIL(
    'aws_thailand_food_precision_farming_EMAIL_INT',
    '<YOUR_EMAIL>',
    '[ALERT] Precision Farming & Crop Analytics: Critical moisture stress — irrigation needed immediately',
    'Critical moisture stress — irrigation needed immediately'
  );

ALTER ALERT APP.MOISTURE_STRESS_ALERT RESUME;

-- Alert: DISEASE_DETECTION_ALERT
CREATE OR REPLACE ALERT APP.DISEASE_DETECTION_ALERT
  WAREHOUSE = FARMING_WH
  SCHEDULE = '5 MINUTE'
  COMMENT = 'Crop disease detected with high confidence — agronomist review needed'
IF (EXISTS (
  SELECT 1 FROM CURATED.FIELD_HEALTH_STATUS
  WHERE 1=1 -- Condition: DISEASE_CONFIDENCE > 0.85 from crop imagery analysis
))
THEN
  CALL SYSTEM$SEND_EMAIL(
    'aws_thailand_food_precision_farming_EMAIL_INT',
    '<YOUR_EMAIL>',
    '[ALERT] Precision Farming & Crop Analytics: Crop disease detected with high confidence — agronomist review needed',
    'Crop disease detected with high confidence — agronomist review needed'
  );

ALTER ALERT APP.DISEASE_DETECTION_ALERT RESUME;


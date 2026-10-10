-- ============================================================================
-- 06_INTELLIGENCE.SQL - search, anomaly detection, semantic view, agent,
-- live-telemetry alert and on-demand refresh DAG.
-- Run with snowflake/run_intelligence.py (substitutes checked __DEMO_DB__ /
-- __DEMO_WH__ / __ALERT_EMAIL__). Requires 00-05, plus 08 (Snowflake only) or
-- aws/setup_aws.py (AWS build) for RAW.LIVE_TELEMETRY.
-- Alerts and tasks are created SUSPENDED; run them with EXECUTE ALERT / EXECUTE TASK.
-- ============================================================================
USE DATABASE __DEMO_DB__;
CREATE SCHEMA IF NOT EXISTS SEARCH;
CREATE SCHEMA IF NOT EXISTS APP;

-- ---------- Synthetic agronomy knowledge base (clearly synthetic SOPs) ----------
CREATE OR REPLACE TABLE SEARCH.AGRONOMY_SOP_DOCS AS
WITH causes AS (
  SELECT DISTINCT r.ROOT_CAUSE, s.CATEGORY
  FROM RAW.FIELD_DAILY r JOIN RAW.FIELDS s ON s.ID = r.ENTITY_ID
  WHERE r.ROOT_CAUSE IS NOT NULL AND r.CROP_STRESS_COUNT > 0
)
SELECT
  'SOP-' || LPAD(ROW_NUMBER() OVER (ORDER BY CATEGORY, ROOT_CAUSE)::VARCHAR, 3, '0') AS DOC_ID,
  'SOP' AS DOC_TYPE,
  CATEGORY,
  ROOT_CAUSE,
  CATEGORY || ' - ' || ROOT_CAUSE || ' crop-stress response' AS TITLE,
  'Synthetic demo SOP. Crop: ' || CATEGORY || '. Crop-stress cause: ' || ROOT_CAUSE || '. '
  || 'Step 1: tell the field agronomist on duty, record the event in the field log and have the field supervisor confirm it on the ground. '
  || 'Step 2: ' || CASE
       WHEN ROOT_CAUSE ILIKE '%planthopper%' THEN 'count hoppers per hill at ten points across the paddy, drain the field for three to four days and agree any control with the field agronomist.'
       WHEN ROOT_CAUSE ILIKE '%blast%' THEN 'mark lesion hotspots, hold back nitrogen top-dressing and rescout the paddy after 5 days.'
       WHEN ROOT_CAUSE ILIKE '%weed%' THEN 'bring the weeding round forward and clear weeds along the bunds and canal edges.'
       WHEN ROOT_CAUSE ILIKE '%white leaf%' THEN 'tag affected stools, plan their removal and confirm that the next planting uses clean seed cane.'
       WHEN ROOT_CAUSE ILIKE '%ratoon%' THEN 'record stool counts in the ratoon rows and flag the field for the replanting review.'
       WHEN ROOT_CAUSE ILIKE '%phytophthora%' THEN 'mark affected trees, improve drainage around the root zone and census neighbouring trees for early symptoms.'
       WHEN ROOT_CAUSE ILIKE '%fruit drop%' THEN 'check irrigation timing and soil moisture under the canopy, and count dropped fruit per tree for 7 days.'
       WHEN ROOT_CAUSE ILIKE '%mealybug%' THEN 'map infested rows, remove heavily infested tips and check that planting stakes come from clean stock.'
       WHEN ROOT_CAUSE ILIKE '%mosaic%' THEN 'rogue symptomatic plants, record their positions and source clean planting stakes for the next cycle.'
       WHEN ROOT_CAUSE ILIKE '%armyworm%' THEN 'scout whorls for fresh feeding damage across the field and agree targeted control with the field agronomist.'
       WHEN ROOT_CAUSE ILIKE '%nitrogen%' THEN 'take leaf and soil samples, and schedule a corrective fertilizer round once the samples are back.'
       WHEN ROOT_CAUSE ILIKE '%dry spell%' THEN 'move the field up the irrigation schedule, delay fertilizer until moisture recovers and watch soil moisture sensors.'
       WHEN ROOT_CAUSE ILIKE '%flood%' THEN 'open outlet gates in sequence, pause field work on flooded plots and recheck the canal level after 48 hours.'
       ELSE 'document the issue, isolate the source and raise it with the regional agronomy manager.'
     END
  || ' Step 3: if the soil moisture deficit stays above 80 mm or the canal level above 90% after the response, keep the field on the watch list. '
  || 'Step 4: confirm that the plant health rate has recovered and record the root cause in the field register.' AS CONTENT
FROM causes;

CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH.AGRONOMY_SOP_SEARCH
  ON CONTENT
  ATTRIBUTES CATEGORY, ROOT_CAUSE
  WAREHOUSE = __DEMO_WH__
  TARGET_LAG = '7 days'
AS (SELECT DOC_ID, TITLE, CATEGORY, ROOT_CAUSE, CONTENT FROM SEARCH.AGRONOMY_SOP_DOCS);

-- ---------- Soil moisture deficit anomaly detection (train first 75 days, detect last 15) ----------
CREATE OR REPLACE VIEW ML.MOISTURE_SERIES AS
SELECT ENTITY_ID, EVENT_DATE::TIMESTAMP_NTZ AS TS, MOISTURE_DEFICIT_MM::FLOAT AS MOISTURE_DEFICIT
FROM RAW.FIELD_DAILY;
CREATE OR REPLACE VIEW ML.MOISTURE_TRAIN AS
SELECT * FROM ML.MOISTURE_SERIES WHERE TS < (SELECT DATEADD(day, -15, MAX(TS)) FROM ML.MOISTURE_SERIES);
CREATE OR REPLACE VIEW ML.MOISTURE_DETECT AS
SELECT * FROM ML.MOISTURE_SERIES WHERE TS >= (SELECT DATEADD(day, -15, MAX(TS)) FROM ML.MOISTURE_SERIES);

CREATE OR REPLACE SNOWFLAKE.ML.ANOMALY_DETECTION ML.MOISTURE_ANOMALY_MODEL(
  INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'ML.MOISTURE_TRAIN'),
  SERIES_COLNAME => 'ENTITY_ID', TIMESTAMP_COLNAME => 'TS', TARGET_COLNAME => 'MOISTURE_DEFICIT',
  LABEL_COLNAME => '');

CREATE OR REPLACE TABLE ML.MOISTURE_ANOMALIES AS
SELECT SERIES::VARCHAR AS ENTITY_ID, TS::DATE AS EVENT_DATE, Y AS MOISTURE_DEFICIT, FORECAST AS EXPECTED,
       LOWER_BOUND, UPPER_BOUND, IS_ANOMALY, PERCENTILE
FROM TABLE(ML.MOISTURE_ANOMALY_MODEL!DETECT_ANOMALIES(
  INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'ML.MOISTURE_DETECT'),
  SERIES_COLNAME => 'ENTITY_ID', TIMESTAMP_COLNAME => 'TS', TARGET_COLNAME => 'MOISTURE_DEFICIT'));

-- ---------- Semantic view ----------
CREATE OR REPLACE SEMANTIC VIEW APP.AGRONOMY_ANALYTICS
  TABLES (
    fields AS CURATED.PERFORMANCE_SUMMARY PRIMARY KEY (ENTITY_ID)
      WITH SYNONYMS = ('entities', 'fields', 'farm fields', 'plots')
      COMMENT = 'One row per farm field (entity), 90-day totals',
    risk AS ML.CROP_STRESS_RISK_SCORES PRIMARY KEY (ENTITY_ID)
      COMMENT = 'Latest next-7-day crop-stress event probability per field',
    causes AS CURATED.CROP_STRESS_CAUSES PRIMARY KEY (ROOT_CAUSE)
      COMMENT = 'Crop-stress events by root cause, 90 days',
    daily AS CURATED.TREND_ANALYSIS PRIMARY KEY (METRIC_DATE)
      COMMENT = 'Grower-wide totals per day'
  )
  RELATIONSHIPS (risk_field AS risk (ENTITY_ID) REFERENCES fields)
  FACTS (
    fields.healthy_plants_f AS HEALTHY_PLANTS,
    fields.plants_scouted_f AS PLANTS_SCOUTED,
    fields.harvest_tonnes_f AS HARVEST_TONNES,
    fields.fertilizer_kg_f AS FERTILIZER_KG,
    fields.pest_alerts_f AS PEST_ALERTS,
    fields.crop_stresses_f AS CROP_STRESS_COUNT,
    fields.downtime_hours_f AS DOWNTIME_HOURS,
    fields.operating_hours_f AS OPERATING_HOURS,
    fields.planned_hours_f AS PLANNED_HOURS,
    risk.crop_stress_prob_f AS CROP_STRESS_PROB_7D,
    causes.cause_crop_stresses_f AS CROP_STRESS_COUNT,
    causes.cause_stressed_f AS STRESSED_PLANTS,
    causes.cause_hours_f AS DOWNTIME_HOURS,
    daily.day_healthy_f AS HEALTHY_PLANTS,
    daily.day_scouted_f AS PLANTS_SCOUTED,
    daily.day_harvest_f AS HARVEST_TONNES,
    daily.day_crop_stresses_f AS CROP_STRESS_COUNT
  )
  DIMENSIONS (
    fields.field_id AS ENTITY_ID WITH SYNONYMS = ('field', 'entity', 'entity id', 'field id'),
    fields.field_name AS ENTITY_NAME,
    fields.farm_region AS REGION WITH SYNONYMS = ('region', 'province', 'farm region') COMMENT = 'Thai province the farm is in',
    fields.field_category AS CATEGORY WITH SYNONYMS = ('crop', 'crop type', 'category'),
    risk.risk_band AS RISK_BAND COMMENT = 'High >= 0.5, Medium >= 0.25, else Low',
    risk.scored_as_of AS SCORED_AS_OF,
    causes.root_cause AS ROOT_CAUSE,
    daily.metric_date AS METRIC_DATE
  )
  METRICS (
    fields.field_count AS COUNT(fields.field_id) WITH SYNONYMS = ('number of entities', 'entity count', 'number of fields'),
    fields.plant_health_rate_pct AS 100 * SUM(fields.healthy_plants_f) / NULLIF(SUM(fields.plants_scouted_f), 0)
      WITH SYNONYMS = ('plant health rate', 'healthy plant share', 'plants scouted healthy') COMMENT = 'Plants scouted healthy / plants scouted',
    fields.total_crop_stresses AS SUM(fields.crop_stresses_f) WITH SYNONYMS = ('crop stress events', 'stress events'),
    fields.fertilizer_intensity_kg_per_t AS SUM(fields.fertilizer_kg_f) / NULLIF(SUM(fields.harvest_tonnes_f), 0)
      WITH SYNONYMS = ('fertilizer intensity', 'fertilizer per tonne') COMMENT = 'kg fertilizer per tonne of crops harvested',
    fields.total_fertilizer_kg AS SUM(fields.fertilizer_kg_f) WITH SYNONYMS = ('fertilizer applied', 'total fertilizer'),
    fields.total_harvest_tonnes AS SUM(fields.harvest_tonnes_f) WITH SYNONYMS = ('crops harvested', 'harvest tonnes', 'yield'),
    fields.total_pest_alerts AS SUM(fields.pest_alerts_f) WITH SYNONYMS = ('pest alerts', 'scouting alerts'),
    fields.sensor_network_uptime_pct AS 100 * SUM(fields.operating_hours_f) / NULLIF(SUM(fields.planned_hours_f), 0),
    fields.total_downtime_hours AS SUM(fields.downtime_hours_f),
    risk.avg_crop_stress_prob AS AVG(risk.crop_stress_prob_f),
    causes.cause_crop_stresses AS SUM(causes.cause_crop_stresses_f),
    causes.cause_stressed_plants AS SUM(causes.cause_stressed_f),
    causes.cause_downtime_hours AS SUM(causes.cause_hours_f),
    daily.daily_plant_health_rate_pct AS 100 * SUM(daily.day_healthy_f) / NULLIF(SUM(daily.day_scouted_f), 0),
    daily.daily_harvest_tonnes AS SUM(daily.day_harvest_f),
    daily.daily_crop_stresses AS SUM(daily.day_crop_stresses_f)
  )
  COMMENT = 'Synthetic Thailand precision farming analytics (demo)';

-- ---------- Cortex Agent ----------
CREATE OR REPLACE AGENT APP.AGRONOMY_AGENT
  COMMENT = 'Agronomy assistant over a synthetic Thai crop grower'
  FROM SPECIFICATION
$$
models:
  orchestration: claude-sonnet-4-5
instructions:
  response: "Use only what the tools return. Say that the data is synthetic and that thresholds are demo settings, not agronomic standards. Quote field IDs, and give every number with its unit."
  orchestration: "Use agronomy_analyst for plant health rate, crop-stress events, crops harvested, fertilizer intensity, pest alerts, sensor network uptime, fields, regions, risk and root causes. Use sop_search for crop-stress response procedures."
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: agronomy_analyst
      description: "Plant health rate, crop-stress events, crops harvested, fertilizer applied and intensity, pest alerts, sensor network uptime, root causes and crop-stress risk scores per field"
  - tool_spec:
      type: cortex_search
      name: sop_search
      description: "Synthetic crop-stress response SOPs by crop and cause"
tool_resources:
  agronomy_analyst:
    semantic_view: __DEMO_DB__.APP.AGRONOMY_ANALYTICS
    execution_environment:
      type: warehouse
      warehouse: __DEMO_WH__
  sop_search:
    name: __DEMO_DB__.SEARCH.AGRONOMY_SOP_SEARCH
    max_results: 3
    id_column: DOC_ID
    title_column: TITLE
$$;

-- ---------- Live-telemetry alert ----------
CREATE TABLE IF NOT EXISTS APP.ALERT_LOG (
  ALERTED_AT TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(), FIELD_ID VARCHAR,
  EVENT_TS TIMESTAMP_NTZ, MOISTURE_DEFICIT_MM FLOAT, CANAL_LEVEL_PCT FLOAT, SOP_HINT VARCHAR);

CREATE OR REPLACE NOTIFICATION INTEGRATION TH_FOOD_PRECISION_FARMING_EMAIL_INT
  TYPE = EMAIL ENABLED = TRUE ALLOWED_RECIPIENTS = ('__ALERT_EMAIL__');

CREATE OR REPLACE PROCEDURE APP.LOG_LIVE_ALARMS()
RETURNS NUMBER
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
  n NUMBER;
BEGIN
  INSERT INTO APP.ALERT_LOG (FIELD_ID, EVENT_TS, MOISTURE_DEFICIT_MM, CANAL_LEVEL_PCT, SOP_HINT)
    SELECT t.FIELD_ID, t.EVENT_TS, t.MOISTURE_DEFICIT_MM, t.CANAL_LEVEL_PCT,
           'Check ' || s.CATEGORY || ' SOPs; current risk band ' || COALESCE(r.RISK_BAND, 'n/a')
    FROM RAW.LIVE_TELEMETRY t
    JOIN RAW.FIELDS s ON s.ID = t.FIELD_ID
    LEFT JOIN ML.CROP_STRESS_RISK_SCORES r ON r.ENTITY_ID = t.FIELD_ID
    WHERE t.STATUS = 'ALARM'
      AND NOT EXISTS (SELECT 1 FROM APP.ALERT_LOG l WHERE l.FIELD_ID = t.FIELD_ID AND l.EVENT_TS = t.EVENT_TS);
  n := SQLROWCOUNT;
  IF (n > 0) THEN
    CALL SYSTEM$SEND_EMAIL('TH_FOOD_PRECISION_FARMING_EMAIL_INT', '__ALERT_EMAIL__',
      '[Demo] Thailand precision farming field-sensor alarm',
      'New live-telemetry alarms logged in APP.ALERT_LOG: ' || :n || '. Data is synthetic.');
  END IF;
  RETURN n;
END;
$$;

CREATE OR REPLACE ALERT APP.LIVE_ALARM_ALERT
  WAREHOUSE = __DEMO_WH__
  SCHEDULE = '5 MINUTE'
  IF (EXISTS (
    SELECT 1 FROM RAW.LIVE_TELEMETRY t
    WHERE t.STATUS = 'ALARM'
      AND NOT EXISTS (SELECT 1 FROM APP.ALERT_LOG l WHERE l.FIELD_ID = t.FIELD_ID AND l.EVENT_TS = t.EVENT_TS)))
  THEN CALL APP.LOG_LIVE_ALARMS();

-- ---------- On-demand refresh DAG (suspended; run with EXECUTE TASK APP.TASK_REFRESH_CURATED) ----------
CREATE OR REPLACE PROCEDURE APP.REFRESH_CURATED()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
  ALTER DYNAMIC TABLE CURATED.PERFORMANCE_SUMMARY REFRESH;
  ALTER DYNAMIC TABLE CURATED.TREND_ANALYSIS REFRESH;
  ALTER DYNAMIC TABLE CURATED.CROP_STRESS_CAUSES REFRESH;
  ALTER DYNAMIC TABLE CURATED.KPI_SUMMARY REFRESH;
  RETURN 'refreshed';
END;
$$;

CREATE OR REPLACE TASK APP.TASK_REFRESH_CURATED
  WAREHOUSE = __DEMO_WH__
AS
  CALL APP.REFRESH_CURATED();

CREATE OR REPLACE TASK APP.TASK_RESCORE_RISK
  WAREHOUSE = __DEMO_WH__
  AFTER APP.TASK_REFRESH_CURATED
AS
  CREATE OR REPLACE TABLE ML.CROP_STRESS_RISK_SCORES COPY GRANTS AS
  WITH latest AS (
    SELECT * FROM ML.CROP_STRESS_FEATURES QUALIFY ROW_NUMBER() OVER (PARTITION BY ENTITY_ID ORDER BY EVENT_DATE DESC) = 1
  ), p AS (
    SELECT ENTITY_ID, EVENT_DATE,
           ML.CROP_STRESS_RISK_MODEL!PREDICT(INPUT_DATA => OBJECT_CONSTRUCT(
             'CATEGORY', CATEGORY, 'YEARS_CROPPED', YEARS_CROPPED, 'MOISTURE_DEFICIT_MM', MOISTURE_DEFICIT_MM,
             'CANAL_LEVEL_PCT', CANAL_LEVEL_PCT, 'MOISTURE_DEFICIT_7D', MOISTURE_DEFICIT_7D, 'CROP_STRESSES_30D', CROP_STRESSES_30D)) AS PRED
    FROM latest
  )
  SELECT ENTITY_ID, EVENT_DATE AS SCORED_AS_OF, ROUND(PRED:probability:CROP_STRESS::FLOAT, 4) AS CROP_STRESS_PROB_7D,
         CASE WHEN PRED:probability:CROP_STRESS::FLOAT >= 0.5 THEN 'High'
              WHEN PRED:probability:CROP_STRESS::FLOAT >= 0.25 THEN 'Medium' ELSE 'Low' END AS RISK_BAND,
         CURRENT_TIMESTAMP() AS SCORED_AT
  FROM p;

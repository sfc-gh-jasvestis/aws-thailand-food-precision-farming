-- Synthetic field-day agronomy observations for a fictional Thai crop grower
-- with farms in four Thai provinces. Nothing is seeded as a
-- prediction. Randomness is HASH-seeded, so every rebuild is reproducible:
-- per-field area, years cropped and crop-stress propensity, weekly harvest
-- seasonality and a peak-harvest day, field stress between scouting rounds,
-- crop-weighted crop-stress causes, and two regional weather events.
-- Thresholds are internal demo thresholds, not agronomic standards.
USE DATABASE IDENTIFIER($DEMO_DB);
USE SCHEMA RAW;
USE WAREHOUSE IDENTIFIER($DEMO_WH);

CREATE TABLE RAW.FIELDS AS
WITH fields AS (
  SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS FIELD_INDEX
  FROM TABLE(GENERATOR(ROWCOUNT => 30))
), draws AS (
  SELECT FIELD_INDEX,
         MOD(ABS(HASH(FIELD_INDEX, 'thpf_age')), 1000000) / 1e6 AS U_AGE,
         MOD(ABS(HASH(FIELD_INDEX, 'thpf_rate')), 1000000) / 1e6 AS U_RATE,
         MOD(ABS(HASH(FIELD_INDEX, 'thpf_insp')), 1000000) / 1e6 AS U_INSP,
         MOD(ABS(HASH(FIELD_INDEX, 'thpf_discipline')), 1000000) / 1e6 AS U_DISCIPLINE,
         MOD(ABS(HASH(FIELD_INDEX, 'thpf_capacity')), 1000000) / 1e6 AS U_CAPACITY
  FROM fields
)
SELECT 'FLD-' || LPAD(FIELD_INDEX::VARCHAR, 4, '0') AS ID,
       'Synthetic field ' || LPAD(FIELD_INDEX::VARCHAR, 4, '0') AS NAME,
       -- Deterministic spread (7 and 5 are coprime): every region and field
       -- crop is present, with Khon Kaen and Nakhon Sawan largest.
       CASE MOD(FIELD_INDEX, 7) WHEN 0 THEN 'Khon Kaen' WHEN 1 THEN 'Khon Kaen'
            WHEN 2 THEN 'Nakhon Sawan' WHEN 3 THEN 'Nakhon Sawan'
            WHEN 4 THEN 'Chiang Rai' ELSE 'Chanthaburi' END AS REGION,
       CASE MOD(FIELD_INDEX, 5) WHEN 0 THEN 'Jasmine Rice' WHEN 1 THEN 'Sugarcane'
            WHEN 2 THEN 'Durian Orchard' WHEN 3 THEN 'Cassava'
            ELSE 'Maize' END AS CATEGORY,
       FIELD_INDEX,
       -- Years under continuous cropping, by crop.
       ROUND(CASE MOD(FIELD_INDEX, 5) WHEN 0 THEN 4 + U_AGE * 3 WHEN 1 THEN 8 + U_AGE * 7
                  WHEN 2 THEN 18 + U_AGE * 7 ELSE 6 + U_AGE * 12 END, 1) AS YEARS_CROPPED,
       ROUND(25 + U_CAPACITY * 30, 1) AS AREA_HA,
       -- Base daily crop-stress probability 0.5%-3.5%; ~15% of fields are chronic (x3).
       (0.005 + U_RATE * 0.03) * IFF(U_RATE > 0.85, 3, 1) AS BASE_CROP_STRESS_RATE,
       7 * (1 + FLOOR(U_INSP * 3)) AS SCOUTING_INTERVAL_DAYS,
       0.55 + U_DISCIPLINE * 0.45 AS SCOUTING_COMPLETION_PROB,
       -- Potential harvest per day (tonnes): area x synthetic yield potential by crop.
       ROUND((25 + U_CAPACITY * 30) * 22 / 365
             * CASE MOD(FIELD_INDEX, 5) WHEN 0 THEN 0.60 WHEN 1 THEN 1.00 WHEN 2 THEN 0.70
                    WHEN 3 THEN 0.85 ELSE 0.65 END, 3) AS DAILY_CAPACITY,
       -- Fertilizer applied (kg per tonne harvested), synthetic and by crop.
       CASE MOD(FIELD_INDEX, 5) WHEN 0 THEN 68 WHEN 1 THEN 48 WHEN 2 THEN 72
            WHEN 3 THEN 58 ELSE 80 END * (0.9 + U_AGE * 0.2) AS FERT_RATE,
       'Active' AS STATUS
FROM draws;

CREATE TABLE RAW.FIELD_DAILY AS
WITH days AS (
  SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS DAY_INDEX
  FROM TABLE(GENERATOR(ROWCOUNT => 90))
), regional_events AS (
  -- Two region-wide weather events in the window.
  SELECT * FROM VALUES (31, 'Khon Kaen', 'Prolonged dry spell', 7.0),
                       (58, 'Nakhon Sawan', 'River flooding', 8.0)
    AS o(DAY_INDEX, REGION, EVENT_CAUSE, HOURS)
), base AS (
  SELECT s.ID AS ENTITY_ID, s.FIELD_INDEX, s.CATEGORY, s.REGION, s.YEARS_CROPPED,
         s.BASE_CROP_STRESS_RATE, s.SCOUTING_INTERVAL_DAYS, s.SCOUTING_COMPLETION_PROB,
         s.DAILY_CAPACITY, s.FERT_RATE, d.DAY_INDEX,
         DATEADD('day', d.DAY_INDEX - 89, CURRENT_DATE()) AS EVENT_DATE,
         24.0 AS PLANNED_HOURS,
         MOD(d.DAY_INDEX + s.FIELD_INDEX * 5, s.SCOUTING_INTERVAL_DAYS) AS DAYS_SINCE_SCOUTING,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_exc')), 1000000) / 1e6 AS U_EXC,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_down')), 1000000) / 1e6 + 1e-6 AS U_DOWN,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_cause')), 1000000) / 1e6 AS U_CAUSE,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_inspdone')), 1000000) / 1e6 AS U_INSPDONE,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_volume')), 1000000) / 1e6 AS U_VOLUME,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_noise')), 1000000) / 1e6 AS U_NOISE,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_hit')), 1000000) / 1e6 AS U_HIT,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'thpf_grv')), 1000000) / 1e6 AS U_GRV,
         e.EVENT_CAUSE, e.HOURS AS EVENT_HOURS
  FROM RAW.FIELDS s CROSS JOIN days d
  LEFT JOIN regional_events e ON e.DAY_INDEX = d.DAY_INDEX AND e.REGION = s.REGION
), loaded AS (
  SELECT *,
         IFF(DAYS_SINCE_SCOUTING = 0, 1, 0) AS SCOUTING_DUE,
         IFF(DAYS_SINCE_SCOUTING = 0 AND U_INSPDONE < SCOUTING_COMPLETION_PROB, 1, 0) AS SCOUTING_DONE,
         -- Field stress builds between scouting rounds; skipped rounds carry it over.
         DAYS_SINCE_SCOUTING / SCOUTING_INTERVAL_DAYS + (1 - SCOUTING_COMPLETION_PROB) AS WEAR,
         -- Dry-spell stress episode: 9 of every 28 days per field (staggered).
         IFF(MOD(DAY_INDEX + FIELD_INDEX * 11, 28) < 9, 1, 0) AS STRESS,
         -- Harvest: weekly low day and a peak-harvest push on day 45 (+60%) easing over 3 days.
         ROUND(DAILY_CAPACITY * (0.70 + 0.25 * U_VOLUME)
               * IFF(MOD(DAY_INDEX, 7) = 6, 0.75, 1.0)
               * CASE DAY_INDEX - 45 WHEN 0 THEN 1.6 WHEN 1 THEN 1.4 WHEN 2 THEN 1.2 ELSE 1.0 END, 3) AS HARVEST_TONNES
  FROM base
), crop_stresses AS (
  SELECT *, HARVEST_TONNES / DAILY_CAPACITY AS LOAD_RATIO,
         LEAST(0.5, BASE_CROP_STRESS_RATE * (0.4 + 1.6 * WEAR) * (0.3 + HARVEST_TONNES / DAILY_CAPACITY)
                    * (1 + YEARS_CROPPED / 20) * (1 + 2.5 * STRESS)) AS P_EXC
  FROM loaded
), counted AS (
  SELECT *,
         CASE WHEN EVENT_HOURS IS NOT NULL THEN 1
              WHEN U_EXC < P_EXC / 4 THEN 2
              WHEN U_EXC < P_EXC THEN 1
              ELSE 0 END AS CROP_STRESS_COUNT
  FROM crop_stresses
)
, timed AS (
  SELECT *,
         -- Field sensor network offline hours: exponential, mean depends on crop.
         CASE WHEN CROP_STRESS_COUNT = 0 THEN 0.0
              WHEN EVENT_HOURS IS NOT NULL THEN EVENT_HOURS
              ELSE LEAST(20.0, ROUND(CROP_STRESS_COUNT * (0.5 - LN(U_DOWN) *
                   CASE CATEGORY WHEN 'Jasmine Rice' THEN 3.0 WHEN 'Sugarcane' THEN 2.0
                                 WHEN 'Durian Orchard' THEN 4.0 WHEN 'Cassava' THEN 2.5 ELSE 3.5 END), 1))
         END AS DOWNTIME_HOURS,
         -- Share of scouted plants recorded healthy.
         LEAST(0.995, GREATEST(0.50,
           CASE CATEGORY WHEN 'Jasmine Rice' THEN 0.946 WHEN 'Sugarcane' THEN 0.963
                         WHEN 'Durian Orchard' THEN 0.936 WHEN 'Cassava' THEN 0.951 ELSE 0.942 END
           - 0.025 * WEAR - 0.04 * GREATEST(0, LOAD_RATIO - 0.9) - 0.006 * U_NOISE
           - CROP_STRESS_COUNT * (0.08 + 0.12 * U_HIT))) AS HEALTH_RATE,
         12 + FLOOR(U_VOLUME * 13) AS PLANTS_SCOUTED
  FROM counted
)
SELECT ENTITY_ID || '-' || TO_CHAR(EVENT_DATE, 'YYYYMMDD') AS EVENT_ID,
       ENTITY_ID, EVENT_DATE, PLANNED_HOURS, DOWNTIME_HOURS,
       PLANNED_HOURS - DOWNTIME_HOURS AS OPERATING_HOURS,
       CROP_STRESS_COUNT,
       CASE WHEN CROP_STRESS_COUNT = 0 THEN 'None'
            WHEN EVENT_CAUSE IS NOT NULL THEN EVENT_CAUSE
            WHEN CATEGORY = 'Jasmine Rice' THEN IFF(U_CAUSE < 0.5, 'Brown planthopper', IFF(U_CAUSE < 0.8, 'Rice blast', 'Weed competition'))
            WHEN CATEGORY = 'Sugarcane' THEN IFF(U_CAUSE < 0.55, 'White leaf disease', 'Ratoon stunting')
            WHEN CATEGORY = 'Durian Orchard' THEN IFF(U_CAUSE < 0.6, 'Phytophthora root rot', 'Premature fruit drop')
            WHEN CATEGORY = 'Cassava' THEN IFF(U_CAUSE < 0.6, 'Cassava mealybug', 'Cassava mosaic disease')
            ELSE IFF(U_CAUSE < 0.6, 'Fall armyworm', 'Nitrogen deficiency') END AS ROOT_CAUSE,
       SCOUTING_DUE, SCOUTING_DONE,
       PLANTS_SCOUTED,
       FLOOR(PLANTS_SCOUTED * HEALTH_RATE) AS HEALTHY_PLANTS,
       HARVEST_TONNES,
       ROUND(HARVEST_TONNES * FERT_RATE * (1 + 0.05 * U_NOISE + 0.03 * WEAR), 1) AS FERTILIZER_KG,
       IFF(U_GRV < 0.02 + 0.04 * CROP_STRESS_COUNT + 0.01 * STRESS, 1, 0) AS PEST_ALERTS,
       ROUND(12 + 18 * WEAR + 25 * GREATEST(0, LOAD_RATIO - 0.8) + 10 * STRESS + 30 * CROP_STRESS_COUNT + U_NOISE * 5, 1) AS MOISTURE_DEFICIT_MM,
       ROUND(LEAST(100, 100 * LOAD_RATIO * (0.75 + 0.1 * U_NOISE) + 7 * STRESS + 4 * CROP_STRESS_COUNT), 1) AS CANAL_LEVEL_PCT,
       CURRENT_TIMESTAMP() AS LOADED_AT
FROM timed;

-- Sensor and drone mapping coverage per field (snapshot): field hectares versus mapped hectares.
CREATE TABLE RAW.SENSOR_COVERAGE AS
SELECT ID AS ENTITY_ID,
       CASE CATEGORY WHEN 'Jasmine Rice' THEN 'Paddy lowland' WHEN 'Sugarcane' THEN 'Upland loam'
                     WHEN 'Durian Orchard' THEN 'Orchard slope' WHEN 'Cassava' THEN 'Sandy upland'
                     ELSE 'Rainfed plain' END AS TERRAIN,
       AREA_HA AS FIELD_HA,
       FLOOR(AREA_HA * (0.30 + MOD(ABS(HASH(ID, 'thpf_avail')), 1000) / 1000 * 0.45)) AS MAPPED_HA,
       MOD(ABS(HASH(ID, 'thpf_order')), 8) AS PLANNED_HA,
       CURRENT_DATE() AS SNAPSHOT_DATE
FROM RAW.FIELDS;

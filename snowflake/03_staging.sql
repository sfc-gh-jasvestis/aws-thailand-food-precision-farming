-- ============================================================================
-- 03_STAGING.SQL — Generate synthetic data for Precision Farming & Crop Analytics
-- Country: THAILAND | Currency: THB
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA RAW;

-- Data generation scripts are demo-specific.
-- See the handcrafted SQL in the aws-malaysia-semiconductor-yield demo for
-- the full pattern: GENERATOR + UNIFORM + LATERAL for distribution,
-- Cortex Complete for text generation, engineered key demo numbers.

-- Target row counts:
-- FARMS: 85 rows — Contract and owned farms across 3 regions (rice, sugarcane, durian, mango)
-- FIELD_BLOCKS: 2,400 rows — Individual field blocks with crop type, area, and soil profile
-- SENSOR_READINGS: 1,500,000 rows — IoT soil moisture, temperature, humidity, rainfall sensors (hourly)
-- SATELLITE_INDICES: 72,000 rows — NDVI, EVI vegetation indices from satellite imagery (weekly × blocks)
-- CROP_IMAGERY: 15,000 rows — Drone and satellite crop images for disease/pest detection
-- HARVEST_RECORDS: 9,600 rows — Historical yield data by block and season (4 seasons × 2400 blocks)
-- WEATHER_STATIONS: 250,000 rows — Local weather data (temperature, rainfall, wind, solar radiation)
-- THAI_AGRICULTURE: 10 rows — Thailand agriculture sector statistics

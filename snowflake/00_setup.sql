-- ============================================================================
-- Precision Farming & Crop Analytics
-- Precision farming intelligence for Thailand's rice, sugarcane, and fruit plantations — IoT sensors feed Snowflake ML for yield forecasting, SageMaker vision models via Cortex Complete analyze crop imagery, and ML.FORECAST predicts harvest timing.
-- ============================================================================
USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS PRECISION_FARMING;
CREATE WAREHOUSE IF NOT EXISTS FARMING_WH WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 120 AUTO_RESUME = TRUE;
USE DATABASE PRECISION_FARMING;
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS CURATED;
CREATE SCHEMA IF NOT EXISTS ML;
CREATE SCHEMA IF NOT EXISTS AI;
CREATE SCHEMA IF NOT EXISTS SEARCH;
CREATE SCHEMA IF NOT EXISTS APP;

USE WAREHOUSE FARMING_WH;

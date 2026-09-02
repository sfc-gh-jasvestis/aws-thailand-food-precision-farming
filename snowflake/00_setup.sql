-- Generated from generator/demo_specs/aws-thailand-food-precision-farming.json
-- Regenerate with: python3 generator/gen_repo_docs.py aws-thailand-food-precision-farming
-- This is the schema that is actually deployed for THAILAND_FOOD_PRECISION_FARMING.

-- THAILAND_FOOD_PRECISION_FARMING  (Precision Farming & Crop Analytics)
-- generated from generator/demo_specs/aws-thailand-food-precision-farming.json - do not hand-edit
CREATE DATABASE IF NOT EXISTS THAILAND_FOOD_PRECISION_FARMING;
CREATE SCHEMA IF NOT EXISTS THAILAND_FOOD_PRECISION_FARMING.RAW;
CREATE SCHEMA IF NOT EXISTS THAILAND_FOOD_PRECISION_FARMING.CURATED;
CREATE SCHEMA IF NOT EXISTS THAILAND_FOOD_PRECISION_FARMING.APP;
USE DATABASE THAILAND_FOOD_PRECISION_FARMING;

-- 5 real regions; entity names carry their region so the two always agree

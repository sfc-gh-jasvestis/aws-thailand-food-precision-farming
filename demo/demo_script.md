# Demo Script: Precision Farming & Crop Analytics
## ~4-Minute Recorded Walkthrough
**Format**: Screen recording with voiceover
**Target**: Customer meeting / booth loop / social share
**Narrative**: "Snowflake ingests field sensor data, analyzes crop imagery with multimodal AI, forecasts yields and harvest timing, and alerts agronomists — replacing fragmented farm management with unified precision agriculture"
**Demo Mode**: Open app with `?demo=true` for presenter notes

---

## Two Personas

| Persona | Role | Tool | What they care about |
|---|---|---|---|
| **Suraphon Charoensuk** | Chief Agricultural Officer | React App (SPCS) | Crop yield predictions, resource efficiency, climate risk, investment returns |
| **Chanida Thongsaen** | Senior Agronomist | Amazon QuickSight | Soil moisture, pest pressure, nutrient levels, irrigation scheduling, disease detection |

---

## What's Built

| Layer | Component | Detail |
|---|---|---|
| **RAW** | 8 tables | FARMS (85), FIELD_BLOCKS (2400), SENSOR_READINGS (1500000), SATELLITE_INDICES (72000), CROP_IMAGERY (15000), HARVEST_RECORDS (9600), WEATHER_STATIONS (250000), THAI_AGRICULTURE (10) |
| **CURATED** | 4 Dynamic Tables | FIELD_HEALTH_STATUS, YIELD_TIMESERIES, IRRIGATION_RECOMMENDATIONS, PEST_DISEASE_ALERTS |
| **ML** | ML.FORECAST + ML.ANOMALY_DETECTION | Forecasting + anomaly detection |
| **AI** | COMPLETE_MULTIMODAL, COMPLETE, AI_CLASSIFY | Classification + extraction |
| **Search** | Cortex Search | 15000 documents indexed |
| **Agent** | PRECISION_FARMING_AGENT | Semantic View + Search tools |


---

## The Story

Thailand's agricultural conglomerate manages 85 farms growing rice, sugarcane, and tropical fruits across 2,400 field blocks. Traditional farming relies on delayed satellite reports and manual field visits — missing moisture stress, disease outbreaks, and yield opportunities worth ฿280M annually. Precision farming with IoT sensors, crop imagery AI, and ML yield forecasting closes the gap.

---

## Script

### [0:00–0:45] EXECUTIVE COCKPIT

**Show**: Executive Cockpit tab

> "Predicted harvest yield at 94% of target across 2,400 blocks — ฿280M potential shortfall."

**Action**: Point at yield vs target KPI gauge

### [0:45–1:30] CROP HEALTH & IMAGERY

**Show**: Crop Health & Imagery tab

> "Cortex Complete (multimodal) analyzes 15,000 crop images — detecting blast disease in rice Block-47."

**Action**: Show crop imagery with AI annotations

### [1:30–2:15] YIELD FORECASTING

**Show**: Yield Forecasting tab

> "ML.FORECAST generates per-block yield predictions 90 days before harvest."

**Action**: Show yield forecast dashboard by crop and region

### [2:15–3:00] ASK AI

**Show**: Ask AI tab

> "Suraphon asks: 'What's the yield shortfall by crop and what interventions can close the gap?'"

**Action**: Type: 'Yield shortfall by crop with intervention options'

### [3:00–3:45] ARCHITECTURE & DATA

**Show**: Architecture & Data tab

> "Eight Snowflake capabilities, six AWS services."

**Action**: Walk through architecture diagram


---

## Key Demo Differentiators

1. **Cortex Complete (multimodal) for crop disease detection** — Only demo analyzing agricultural drone imagery for disease classification natively in Snowflake
2. **ML.FORECAST for per-block yield prediction** — Block-level yield forecasting 90 days ahead at 87% accuracy
3. **IoT sensor + satellite + imagery fusion** — Three data streams unified: soil sensors, vegetation indices, and crop photography
4. **Thai agriculture context** — Rice paddies, sugarcane, and tropical fruit across Central Plains, Isaan, and Eastern regions
5. **Irrigation optimization via Dynamic Tables** — Real-time irrigation recommendations combining soil moisture, weather forecast, and crop stage
6. **ML.ANOMALY_DETECTION for crop stress** — Early detection of stress patterns across 2,400 blocks before visible symptoms appear


---

## Demo Prep Checklist

### Data Verification
- [ ] `SELECT COUNT(*) FROM PRECISION_FARMING.RAW.SENSOR_READINGS` → 1500000
- [ ] `SELECT COUNT(*) FROM PRECISION_FARMING.RAW.CROP_IMAGERY` → 15000
- [ ] `SELECT COUNT(*) FROM PRECISION_FARMING.CURATED.FIELD_HEALTH_STATUS WHERE STRESS_LEVEL = 'HIGH'` → >500

### ML Model Verification
- [ ] `SELECT COUNT(*) FROM PRECISION_FARMING.ML.YIELD_FORECAST_RESULTS` → >0
- [ ] `SELECT SUM(CASE WHEN IS_ANOMALY THEN 1 ELSE 0 END) FROM PRECISION_FARMING.ML.CROP_STRESS_RESULTS` → >=100

### AI/Agent Verification
- [ ] `SELECT COUNT(*) FROM PRECISION_FARMING.AI.CROP_DISEASE_DETECTIONS WHERE CONFIDENCE > 0.85` → >50


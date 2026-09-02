# Precision Farming & Crop Analytics

**Thailand - Food & Agribusiness**
Use case: Precision Agriculture & Crop Intelligence

> Precision farming intelligence for Thailand's rice, sugarcane, and fruit plantations — IoT sensors feed Snowflake ML for yield forecasting, SageMaker vision models via Cortex Complete analyze crop imagery, and ML.FORECAST predicts harvest timing.

## Why Snowflake

Snowflake ingests field sensor data, analyzes crop imagery with multimodal AI, forecasts yields and harvest timing, and alerts agronomists — replacing fragmented farm management with unified precision agriculture

- **Cortex Complete (multimodal) for crop disease detection** - Only demo analyzing agricultural drone imagery for disease classification natively in Snowflake
- **ML.FORECAST for per-block yield prediction** - Block-level yield forecasting 90 days ahead at 87% accuracy
- **IoT sensor + satellite + imagery fusion** - Three data streams unified: soil sensors, vegetation indices, and crop photography
- **Thai agriculture context** - Rice paddies, sugarcane, and tropical fruit across Central Plains, Isaan, and Eastern regions
- **Irrigation optimization via Dynamic Tables** - Real-time irrigation recommendations combining soil moisture, weather forecast, and crop stage
- **ML.ANOMALY_DETECTION for crop stress** - Early detection of stress patterns across 2,400 blocks before visible symptoms appear

## What is deployed

| | |
|---|---|
| Database | `THAILAND_FOOD_PRECISION_FARMING` |
| Service | `THAILAND_FOOD_PRECISION_FARMING_APP` |
| Compute pool | `SEA_DEMOS_THAILAND_POOL` |
| Dimension table | `RAW.THAI_AGRICULTURE` (20 rows) |
| Fact table | `RAW.SENSOR_READINGS` (250,000 rows, 90 days) |
| Curated layer | `CURATED.PERFORMANCE_SUMMARY`, `CURATED.TREND_ANALYSIS`, `CURATED.KPI_SUMMARY` |
| Currency | THB (฿) |

Regions in play: Bangkok, Chonburi, Rayong, Chiang Mai, Songkhla
Segments: Jasmine Rice, Sugarcane, Cassava, Tropical Fruit

Dynamic tables are created suspended and refreshed on demand:

```bash
./refresh_demo_data.sh THAILAND_FOOD_PRECISION_FARMING
```

## KPI cards

Every card below is served live from `CURATED.KPI_SUMMARY`. The app keeps the
original literal as a fallback, so it still renders if Snowflake is unreachable.

| Card | Value | Backed by |
|---|---|---|
| Yield Forecast | `4.8 T/rai` | average per event |
| Water Stress Alerts | `23` | total across Thai Agriculture |
| Pest Risk Zones | `7` | average per event |
| Monitored Farms | `1,450` | total across Thai Agriculture |
| Soil Moisture Avg | `42%` | average per event |
| Fertilizer Efficiency | `87%` | average per event |
| Days to Harvest | `34` | average per event |


## Demo flow

1. Executive Cockpit
2. Crop Health & Imagery
3. Yield Forecasting
4. Ask AI
5. Architecture & Data

## Talking points

- **฿280M** - potential yield shortfall vs target (US$8M)
- **23% of blocks** - showing moisture stress in Isaan (drought risk)
- **87% accuracy** - yield forecast within 10% of actual at 60 days
- **1.5M readings** - IoT sensor data points ingested monthly
- **15,000 images** - analyzed by multimodal Cortex Complete for disease detection
- **2,400 blocks** - monitored with per-block yield predictions

## Business impact

- Thailand's agriculture sector contributes ฿1.4 trillion to GDP, employing 12 million people (31% of workforce) (Bank of Thailand)
- Precision agriculture increases crop yields by 15-25% while reducing water and fertilizer use by 20-30% (McKinsey Agriculture)
- AI-powered crop disease detection achieves 90%+ accuracy and detects outbreaks 7-14 days earlier (Nature Food)
- CP Group (Thailand) manages 400,000+ rai of integrated farms using smart agriculture technology (CP Group)

---
Generated from `generator/demo_specs/aws-thailand-food-precision-farming.json`. Do not hand-edit: run
`python3 generator/gen_repo_docs.py aws-thailand-food-precision-farming` instead.

# Thailand Precision Farming

**Thailand - Field Crops**
Use case: Field agronomy and crop-stress risk

> Field agronomy for a fictional Thai crop grower: 30 synthetic rice, sugarcane, cassava, maize and durian fields in Khon Kaen, Nakhon Sawan, Chiang Rai and Chanthaburi, curated by dynamic tables, ranked by a holdout-tested crop-stress risk model, with a harvest forecast and AI answers that cite their SQL and SOPs. All thresholds are demo settings, not agronomic standards.

## Why Snowflake

- **Dynamic tables** reconcile plant health rate, crop-stress events, fertilizer intensity and sensor uptime from RAW field data, with checks in `run_core.py`
- **Crop-stress risk classification** gives a holdout-evaluated next-7-day crop-stress probability per field
- **Harvest forecast** projects 14 days of grower-wide harvested tonnes with prediction intervals
- **Grounded AI**: the Cortex Agent (Analyst over a semantic view, plus Search over SOPs) shows its SQL and SOP citations
- **Live telemetry**: a native simulator (Snowflake only) or IoT Core, S3 and Snowpipe (AWS build), then an alert and email

## What is built

| | |
|---|---|
| Dimension table | `RAW.FIELDS` (30 rows) |
| Fact table | `RAW.FIELD_DAILY` (2,700 field-days, 90 days) |
| Curated layer | `CURATED.KPI_SUMMARY`, `PERFORMANCE_SUMMARY`, `CROP_STRESS_CAUSES`, `TREND_ANALYSIS` |
| ML | `ML.CROP_STRESS_RISK_SCORES`, `ML.CROP_STRESS_RISK_HOLDOUT_METRICS`, `ML.HARVEST_FORECAST`, `ML.MOISTURE_ANOMALIES` |

Provinces: Khon Kaen, Nakhon Sawan, Chiang Rai, Chanthaburi.
Crops: Jasmine Rice, Sugarcane, Cassava, Maize, Durian Orchard.

## KPI cards (live from `CURATED.KPI_SUMMARY`; no fallback values)

| Card | Value from the seeded data |
|---|---|
| Plant Health Rate | 87.5% |
| Crop-Stress Events | 436 |
| Fertilizer Intensity | 65.9 kg/t harvested |
| Crop Harvested (t) | 4,166 |
| Sensor Network Uptime | 97.5% |
| Fields Monitored | 30 |
| Sensor Mapping Coverage | 52.1% |
| Pest Alerts | 89 |

Values are synthetic. A rebuild reproduces them because the data is HASH-seeded; dates are relative to the build day.

## Demo flow

1. Executive Cockpit: KPIs, daily plant health rate, stressed plants by crop-stress cause, field table
2. Predictive: holdout metrics, risk bands, 14-day crop harvest forecast, soil moisture deficit anomalies
3. Field Health: sensor network uptime, sensor mapping coverage, scouting completion against plant health rate, then generate the action memo
4. Live IoT: run `CALL APP.SIMULATE_TELEMETRY(20)` (Snowflake only) or `python aws/publish_telemetry.py --count 20` (AWS build). Then run `EXECUTE ALERT APP.LIVE_ALARM_ALERT` and show the alert log and email.
5. Ask AI: the Cortex Agent answers metric questions through the semantic view and cites SOPs from Cortex Search. The SQL is shown.
6. QuickSight (AWS build): the same Snowflake tables through DIRECT_QUERY
7. Architecture: both builds side by side

## Talking points

- Field-level plant health rate spans 81.4% to 91.4%; Nakhon Sawan trails the other provinces at 86.9%.
- Of the 13 crop-stress causes, Phytophthora root rot in the durian orchards accounts for the most stressed plants.
- In the synthetic rates, Maize fields use the most fertilizer per tonne harvested (83.9 kg/t) and Sugarcane fields the least (49.0 kg/t).
- On a time-based holdout the risk model scores precision 0.58 and recall 0.72 at 0.5, against a 0.50 base rate. Position it as a triage list, not a guarantee.
- The Khon Kaen dry spell and the Nakhon Sawan river flooding are regional weather events, so they are left out of the crop-stress labels.
- No figure is a field recommendation; all thresholds are internal to the demo.

## Business impact

Use only the sourced references in `README.md` (Business Impact).

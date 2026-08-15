-- ============================================================================
-- 08_AGENT.SQL — Cortex Agent for Precision Farming & Crop Analytics
-- ============================================================================
USE DATABASE PRECISION_FARMING;
USE SCHEMA APP;

CREATE OR REPLACE CORTEX AGENT APP.PRECISION_FARMING_AGENT
  COMMENT = 'Precision Farming & Crop Analytics AI Assistant'
  MODEL = 'claude-opus-4-8'
  TOOLS = (
    SEMANTIC_VIEW_TOOL(SEMANTIC_VIEW => 'PRECISION_FARMING.APP.FARMING_ANALYTICS'),    CORTEX_SEARCH_TOOL(CORTEX_SEARCH_SERVICE => 'PRECISION_FARMING.SEARCH.AGRONOMY_KNOWLEDGE_SEARCH', TOOL_DESCRIPTION => 'Search documents for Food & Agribusiness information')
  )
  SYSTEM_PROMPT = 'You are the Precision Farming Agent for 85 farms and 2,400 field blocks growing rice, sugarcane, and tropical fruits across Thailand.';

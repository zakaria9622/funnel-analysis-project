-- =============================================================================
-- 03_clean_events.sql — Cleaned events for funnel analysis
-- =============================================================================
-- Builds a view used by all funnel queries (04–06).
-- Run after 02_load_duckdb.sql (table ecommerce_events must exist).
-- =============================================================================

CREATE OR REPLACE VIEW clean_funnel_events AS
SELECT
    event_time,
    LOWER(TRIM(event_type)) AS event_type,
    product_id,
    category_id,
    category_code,
    brand,
    price,
    user_id,
    user_session
FROM ecommerce_events
WHERE user_id IS NOT NULL
  AND event_time IS NOT NULL
  AND LOWER(TRIM(event_type)) IN ('view', 'cart', 'purchase');

-- Preview
-- SELECT event_type, COUNT(*) AS rows FROM clean_funnel_events GROUP BY 1;

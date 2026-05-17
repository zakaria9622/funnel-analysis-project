-- =============================================================================
-- 07_qa_checks.sql — Data quality checks on raw loaded data
-- =============================================================================
-- Run after 02_load_duckdb.sql. Uses table ecommerce_events (raw load).
-- Each block is independent; run the file or execute sections one by one.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Total row count
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM ecommerce_events;

-- -----------------------------------------------------------------------------
-- 2. Rows by event_type
-- -----------------------------------------------------------------------------
SELECT
  LOWER(TRIM(event_type)) AS event_type,
  COUNT(*) AS row_count
FROM ecommerce_events
GROUP BY 1
ORDER BY row_count DESC;

-- -----------------------------------------------------------------------------
-- 3. Null user_id count
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS null_user_id_rows
FROM ecommerce_events
WHERE user_id IS NULL;

-- -----------------------------------------------------------------------------
-- 4. Null event_time count
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS null_event_time_rows
FROM ecommerce_events
WHERE event_time IS NULL;

-- -----------------------------------------------------------------------------
-- 5. Distinct users and products
-- -----------------------------------------------------------------------------
SELECT
  COUNT(DISTINCT user_id) AS distinct_users,
  COUNT(DISTINCT product_id) AS distinct_products
FROM ecommerce_events;

-- -----------------------------------------------------------------------------
-- 6. Event date range
-- -----------------------------------------------------------------------------
SELECT
  MIN(event_time) AS min_event_time,
  MAX(event_time) AS max_event_time
FROM ecommerce_events;

-- -----------------------------------------------------------------------------
-- 7. Sample: top categories by view events (raw, not funnel)
-- -----------------------------------------------------------------------------
SELECT
  category_id,
  category_code,
  COUNT(*) AS view_events
FROM ecommerce_events
WHERE LOWER(TRIM(event_type)) = 'view'
GROUP BY category_id, category_code
ORDER BY view_events DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- 8. Sample: top brands by view events (raw, not funnel)
-- -----------------------------------------------------------------------------
SELECT
  brand,
  COUNT(*) AS view_events
FROM ecommerce_events
WHERE LOWER(TRIM(event_type)) = 'view'
  AND brand IS NOT NULL
  AND TRIM(brand) <> ''
GROUP BY brand
ORDER BY view_events DESC
LIMIT 10;

-- -----------------------------------------------------------------------------
-- Optional: funnel-ready row count (after cleaning rules)
-- -----------------------------------------------------------------------------
-- SELECT COUNT(*) AS clean_funnel_rows FROM clean_funnel_events;

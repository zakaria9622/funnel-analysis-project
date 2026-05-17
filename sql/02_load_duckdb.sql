-- =============================================================================
-- 02_load_duckdb.sql — Load raw CSV into DuckDB
-- =============================================================================
-- Prerequisites:
--   1. Run this project from the repository root (so relative paths work).
--   2. Place the full dataset locally at: data/ecommerce_events.csv
--
-- The ~5 GB raw file is ignored by Git (.gitignore). Only you have it locally.
-- Small aggregated results for Tableau will be exported later to outputs/.
-- =============================================================================

-- Drop existing table if you need a full reload (uncomment when re-importing)
-- DROP TABLE IF EXISTS ecommerce_events;

-- Load CSV with automatic type inference (DuckDB)
-- Adjust path if your DuckDB working directory differs.
CREATE OR REPLACE TABLE ecommerce_events AS
SELECT *
FROM read_csv_auto(
    'data/ecommerce_events.csv',
    header = true
);

-- Quick sanity check after load
-- SELECT COUNT(*) AS row_count FROM ecommerce_events;
-- SELECT * FROM ecommerce_events LIMIT 5;

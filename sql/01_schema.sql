-- =============================================================================
-- 01_schema.sql — Raw events table definition (DuckDB)
-- =============================================================================
-- Defines the structure for event-level e-commerce data loaded from CSV.
--
-- NOTE: The full raw CSV (multi-GB) is NOT committed to GitHub.
--       Place it locally at: data/ecommerce_events.csv
--       See .gitignore and data/README.md for details.
-- =============================================================================

CREATE TABLE IF NOT EXISTS ecommerce_events (
    event_time    TIMESTAMP,
    event_type    VARCHAR,
    product_id    BIGINT,
    category_id   BIGINT,
    category_code VARCHAR,
    brand         VARCHAR,
    price         DOUBLE,
    user_id       BIGINT,
    user_session  VARCHAR
);

-- Optional: inspect structure after load
-- DESCRIBE ecommerce_events;

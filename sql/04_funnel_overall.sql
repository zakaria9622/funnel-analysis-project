-- =============================================================================
-- 04_funnel_overall.sql — Strict user-level funnel (overall)
-- =============================================================================
-- Logic (same as sql/funnel_queries.sql and docs/methodology.md):
--   1. First product view per user
--   2. First cart strictly after that view
--   3. First purchase strictly after that cart
-- Counts unique users at each step, then conversion rates and drop-off volumes.
-- =============================================================================

WITH first_view AS (
  -- Step 1: earliest view per user
  SELECT
    user_id,
    MIN(event_time) AS first_view_time
  FROM clean_funnel_events
  WHERE event_type = 'view'
  GROUP BY user_id
),

first_cart AS (
  -- Step 2: earliest cart after first view
  SELECT
    c.user_id,
    MIN(c.event_time) AS first_cart_time
  FROM clean_funnel_events c
  INNER JOIN first_view v
    ON c.user_id = v.user_id
  WHERE c.event_type = 'cart'
    AND c.event_time > v.first_view_time
  GROUP BY c.user_id
),

first_purchase AS (
  -- Step 3: earliest purchase after first qualifying cart
  SELECT
    p.user_id,
    MIN(p.event_time) AS first_purchase_time
  FROM clean_funnel_events p
  INNER JOIN first_cart c
    ON p.user_id = c.user_id
  WHERE p.event_type = 'purchase'
    AND p.event_time > c.first_cart_time
  GROUP BY p.user_id
),

funnel_counts AS (
  SELECT
    (SELECT COUNT(*) FROM first_view)     AS view_users,
    (SELECT COUNT(*) FROM first_cart)     AS cart_users,
    (SELECT COUNT(*) FROM first_purchase) AS purchase_users
)

SELECT
  view_users,
  cart_users,
  purchase_users,

  -- Conversion rates (%)
  ROUND(cart_users * 100.0 / NULLIF(view_users, 0), 2)     AS view_to_cart_rate,
  ROUND(purchase_users * 100.0 / NULLIF(cart_users, 0), 2) AS cart_to_purchase_rate,
  ROUND(purchase_users * 100.0 / NULLIF(view_users, 0), 2) AS total_conversion_rate,

  -- Drop-off: users who did not reach the next step
  view_users - cart_users     AS view_to_cart_dropoff_users,
  cart_users - purchase_users AS cart_to_purchase_dropoff_users

FROM funnel_counts;

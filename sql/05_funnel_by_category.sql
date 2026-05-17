-- =============================================================================
-- 05_funnel_by_category.sql — Strict funnel by category
-- =============================================================================
-- Same sequential logic as 04_funnel_overall.sql, applied within each
-- (category_id, category_code) using only events tagged to that category.
-- Excludes low-volume segments: HAVING view_users >= 500
-- =============================================================================

WITH first_view AS (
  SELECT
    category_id,
    category_code,
    user_id,
    MIN(event_time) AS first_view_time
  FROM clean_funnel_events
  WHERE event_type = 'view'
    AND category_id IS NOT NULL
  GROUP BY category_id, category_code, user_id
),

first_cart AS (
  SELECT
    v.category_id,
    v.category_code,
    c.user_id,
    MIN(c.event_time) AS first_cart_time
  FROM clean_funnel_events c
  INNER JOIN first_view v
    ON c.user_id = v.user_id
   AND c.category_id = v.category_id
   AND c.category_code IS NOT DISTINCT FROM v.category_code
  WHERE c.event_type = 'cart'
    AND c.event_time > v.first_view_time
  GROUP BY v.category_id, v.category_code, c.user_id
),

first_purchase AS (
  SELECT
    c.category_id,
    c.category_code,
    p.user_id,
    MIN(p.event_time) AS first_purchase_time
  FROM clean_funnel_events p
  INNER JOIN first_cart c
    ON p.user_id = c.user_id
   AND p.category_id = c.category_id
   AND p.category_code IS NOT DISTINCT FROM c.category_code
  WHERE p.event_type = 'purchase'
    AND p.event_time > c.first_cart_time
  GROUP BY c.category_id, c.category_code, p.user_id
),

funnel_by_category AS (
  SELECT
    v.category_id,
    v.category_code,
    COUNT(DISTINCT v.user_id) AS view_users,
    COUNT(DISTINCT c.user_id) AS cart_users,
    COUNT(DISTINCT p.user_id) AS purchase_users
  FROM first_view v
  LEFT JOIN first_cart c
    ON v.category_id = c.category_id
   AND v.category_code IS NOT DISTINCT FROM c.category_code
   AND v.user_id = c.user_id
  LEFT JOIN first_purchase p
    ON v.category_id = p.category_id
   AND v.category_code IS NOT DISTINCT FROM p.category_code
   AND v.user_id = p.user_id
  GROUP BY v.category_id, v.category_code
  HAVING COUNT(DISTINCT v.user_id) >= 500
)

SELECT
  category_id,
  category_code,
  view_users,
  cart_users,
  purchase_users,

  ROUND(cart_users * 100.0 / NULLIF(view_users, 0), 2)     AS view_to_cart_rate,
  ROUND(purchase_users * 100.0 / NULLIF(cart_users, 0), 2) AS cart_to_purchase_rate,
  ROUND(purchase_users * 100.0 / NULLIF(view_users, 0), 2) AS total_conversion_rate,

  view_users - cart_users     AS view_to_cart_dropoff_users,
  cart_users - purchase_users AS cart_to_purchase_dropoff_users

FROM funnel_by_category
ORDER BY view_users DESC;

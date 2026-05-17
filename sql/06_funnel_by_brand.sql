-- =============================================================================
-- 06_funnel_by_brand.sql — Strict funnel by brand
-- =============================================================================
-- Same sequential logic as 04_funnel_overall.sql, applied within each brand
-- using only events tagged to that brand.
-- Excludes null brands and low-volume segments: HAVING view_users >= 500
-- =============================================================================

WITH first_view AS (
  SELECT
    brand,
    user_id,
    MIN(event_time) AS first_view_time
  FROM clean_funnel_events
  WHERE event_type = 'view'
    AND brand IS NOT NULL
    AND TRIM(brand) <> ''
  GROUP BY brand, user_id
),

first_cart AS (
  SELECT
    v.brand,
    c.user_id,
    MIN(c.event_time) AS first_cart_time
  FROM clean_funnel_events c
  INNER JOIN first_view v
    ON c.user_id = v.user_id
   AND c.brand = v.brand
  WHERE c.event_type = 'cart'
    AND c.event_time > v.first_view_time
  GROUP BY v.brand, c.user_id
),

first_purchase AS (
  SELECT
    c.brand,
    p.user_id,
    MIN(p.event_time) AS first_purchase_time
  FROM clean_funnel_events p
  INNER JOIN first_cart c
    ON p.user_id = c.user_id
   AND p.brand = c.brand
  WHERE p.event_type = 'purchase'
    AND p.event_time > c.first_cart_time
  GROUP BY c.brand, p.user_id
),

funnel_by_brand AS (
  SELECT
    v.brand,
    COUNT(DISTINCT v.user_id) AS view_users,
    COUNT(DISTINCT c.user_id) AS cart_users,
    COUNT(DISTINCT p.user_id) AS purchase_users
  FROM first_view v
  LEFT JOIN first_cart c
    ON v.brand = c.brand
   AND v.user_id = c.user_id
  LEFT JOIN first_purchase p
    ON v.brand = p.brand
   AND v.user_id = p.user_id
  GROUP BY v.brand
  HAVING COUNT(DISTINCT v.user_id) >= 500
)

SELECT
  brand,
  view_users,
  cart_users,
  purchase_users,

  ROUND(cart_users * 100.0 / NULLIF(view_users, 0), 2)     AS view_to_cart_rate,
  ROUND(purchase_users * 100.0 / NULLIF(cart_users, 0), 2) AS cart_to_purchase_rate,
  ROUND(purchase_users * 100.0 / NULLIF(view_users, 0), 2) AS total_conversion_rate,

  view_users - cart_users     AS view_to_cart_dropoff_users,
  cart_users - purchase_users AS cart_to_purchase_dropoff_users

FROM funnel_by_brand
ORDER BY view_users DESC;

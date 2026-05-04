-- E-commerce funnel analysis
-- Strict user-level funnel:
-- first product view -> first cart after view -> first purchase after cart

WITH first_view AS (
    SELECT
        user_id,
        MIN(event_time) AS first_view_time
    FROM ecommerce_events
    WHERE LOWER(event_type) = 'view'
    GROUP BY user_id
),

first_cart AS (
    SELECT
        c.user_id,
        MIN(c.event_time) AS first_cart_time
    FROM ecommerce_events c
    INNER JOIN first_view v
        ON c.user_id = v.user_id
    WHERE LOWER(c.event_type) = 'cart'
      AND c.event_time > v.first_view_time
    GROUP BY c.user_id
),

first_purchase AS (
    SELECT
        p.user_id,
        MIN(p.event_time) AS first_purchase_time
    FROM ecommerce_events p
    INNER JOIN first_cart c
        ON p.user_id = c.user_id
    WHERE LOWER(p.event_type) = 'purchase'
      AND p.event_time > c.first_cart_time
    GROUP BY p.user_id
),

funnel_counts AS (
    SELECT
        (SELECT COUNT(*) FROM first_view) AS view_users,
        (SELECT COUNT(*) FROM first_cart) AS cart_users,
        (SELECT COUNT(*) FROM first_purchase) AS purchase_users
)

SELECT
    view_users,
    cart_users,
    purchase_users,
    ROUND(cart_users * 100.0 / NULLIF(view_users, 0), 2) AS view_to_cart_rate,
    ROUND(purchase_users * 100.0 / NULLIF(cart_users, 0), 2) AS cart_to_purchase_rate,
    ROUND(purchase_users * 100.0 / NULLIF(view_users, 0), 2) AS total_conversion_rate
FROM funnel_counts;
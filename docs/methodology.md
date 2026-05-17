# Funnel methodology

This project uses a **strict, time-ordered, user-level funnel** to measure e-commerce conversion from product discovery to purchase. The goal is to answer where users drop before buying, without inflating conversion with loosely ordered events.

## Funnel steps

Each user can contribute at most one path through three steps:

```text
first product view → first cart after view → first purchase after cart
```

### Step 1 — First product view

For each `user_id`, identify the **earliest** `event_time` where `event_type = 'view'`.

This timestamp is the user's entry into the funnel. Users with no view event are excluded from the funnel.

### Step 2 — First cart after first view

For each user who viewed, find the **earliest** cart event where:

- `event_type = 'cart'`, and  
- `event_time` is **strictly after** the user's first view time.

Carts that occur before the first view, or without any prior view, do not count toward the funnel.

### Step 3 — First purchase after first cart

For each user who reached cart, find the **earliest** purchase event where:

- `event_type = 'purchase'`, and  
- `event_time` is **strictly after** the user's first qualifying cart time.

Purchases without a prior qualifying cart do not count toward the funnel.

## How users are counted

At each step we count **unique users** (`user_id`), not raw event volume.

| Step | Metric |
|------|--------|
| Views | Users with at least one product view |
| Carts | Users with at least one cart **after** their first view |
| Purchases | Users with at least one purchase **after** their first qualifying cart |

This ensures conversion rates reflect **people**, not duplicate events.

## Conversion rates

All rates are expressed as percentages of users at the previous step (or at the funnel entry for total conversion).

| Metric | Formula | Business meaning |
|--------|---------|------------------|
| **View → cart** | cart users ÷ view users × 100 | Share of viewers who signal purchase intent |
| **Cart → purchase** | purchase users ÷ cart users × 100 | Share of cart users who complete a purchase |
| **Total conversion (view → purchase)** | purchase users ÷ view users × 100 | End-to-end funnel completion |

Division by zero is handled by returning 0% when the denominator is zero.

## Why strict sequencing matters

A loose funnel (e.g. counting any cart or purchase regardless of order) can overstate conversion by linking unrelated actions. Strict sequencing aligns the analysis with a realistic customer journey and supports clearer product and marketing recommendations.

## Segment analysis

The same logic is applied **within segments** (e.g. `category_id`, `brand`): for each segment value, compute first view, first cart after view, and first purchase after cart using only events attributed to that segment, then count unique users and conversion rates.

Segment rankings (e.g. lowest total conversion among high-traffic categories) use additional volume filters so small samples are not over-interpreted.

## Implementation references

- SQL: `sql/funnel_queries.sql` (overall funnel)
- Python: `python/analysis.py` (overall and segment funnels)

Future phases will align SQL marts and Tableau data sources with this definition.

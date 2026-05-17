# Data dictionary

## Raw event dataset

The full analysis uses **event-level** e-commerce data: one row per user action. The expected columns in the production CSV are listed below.

| Column | Type (logical) | Description |
|--------|----------------|-------------|
| `event_time` | Timestamp | When the event occurred (e.g. `2019-10-01 00:00:00 UTC`) |
| `event_type` | String | Event name; funnel analysis uses `view`, `cart`, and `purchase` (case-normalized in code) |
| `product_id` | Identifier | Product associated with the event |
| `category_id` | Identifier | Numeric or opaque category key for the product |
| `category_code` | String | Human-readable category path (e.g. `appliances.kitchen.kettle`); may be empty |
| `brand` | String | Brand name; may be empty |
| `price` | Numeric | Product price at time of event |
| `user_id` | Identifier | Unique user; grain for funnel counting |
| `user_session` | Identifier | Session id for the visit; useful for session-level analysis (not required for core user funnel) |

### Grain

- **One row** = one event (view, cart, purchase, or other types present in the source file).
- Funnel metrics aggregate to **one row per user** at each step using the strict rules in `docs/methodology.md`.

### Funnel events

Only these `event_type` values are used in the core funnel:

| Value | Role |
|-------|------|
| `view` | User viewed a product |
| `cart` | User added to cart |
| `purchase` | User completed a purchase |

Other event types in the source file, if any, are excluded from the strict funnel.

## Sample dataset (`data/ecommerce_events_sample.csv`)

The repository includes a **small demo file** so the Python pipeline can run without the full CSV. It may use **simplified or extra columns** for readability, for example:

- Readable `category_id` labels (e.g. `Electronics`) instead of long numeric ids  
- `device` (e.g. `mobile`, `desktop`) — present in the sample but **not** in the full production header  

When documenting or building Tableau models, treat the sample as a **structure demo** and the column list above as the **canonical full-dataset schema**.

## Local full dataset (not in Git)

The full file is typically named:

```text
data/ecommerce_events.csv
```

It is listed in `.gitignore` because of file size. Place it locally to run analysis on the complete event history. See `data/README.md` for usage notes.

## Planned output tables (`outputs/`)

Aggregated files (generated later from SQL or Python) will document their own columns in `outputs/README.md` once created. Expected themes:

- User counts per funnel step  
- Conversion rates (view → cart, cart → purchase, view → purchase)  
- Optional segment keys (`category_id`, `brand`)

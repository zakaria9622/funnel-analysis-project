# Outputs

This folder holds **small aggregated CSV files** used as data sources for Tableau dashboards and for sharing reproducible KPIs on GitHub.

## Why outputs exist

The raw full event-level dataset (`ecommerce_events.csv`) is **not committed** to the repository because it is too large for Git hosting. Instead, we commit **summary tables** that contain funnel metrics at a safe file size.

## Planned files

The following files will be added as the SQL and export pipeline is built:

| File | Description |
|------|-------------|
| `funnel_overall.csv` | Overall funnel user counts and conversion rates |
| `funnel_by_category.csv` | Strict funnel metrics broken down by `category_id` |
| `funnel_by_brand.csv` | Strict funnel metrics broken down by `brand` |

## How outputs are generated

These files will be produced from **SQL queries** (primary) or **Python** (validation / optional export), using the same strict sequential funnel logic documented in `docs/methodology.md`.

## Tableau usage

Connect Tableau to the CSV files in this folder rather than to the full raw events file. This keeps dashboards fast and the repository portable.

## Git notes

- Aggregated `.csv` files in this folder are intended to be **committed** once generated.
- Tableau `.hyper` extracts are ignored via `.gitignore` (see `outputs/*.hyper`).

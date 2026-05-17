"""
Export Tableau-ready funnel CSVs using DuckDB.

Run from the repository root:
    python scripts/export_tableau_outputs.py

Requires: data/ecommerce_events.csv (local full dataset, not in Git).
"""

from __future__ import annotations

import sys
from pathlib import Path

import duckdb

# Repository root (parent of scripts/)
ROOT = Path(__file__).resolve().parent.parent
RAW_CSV = ROOT / "data" / "ecommerce_events.csv"
OUTPUT_DIR = ROOT / "outputs"
DB_PATH = ROOT / "funnel_analysis.duckdb"
SQL_DIR = ROOT / "sql"


def log(message: str) -> None:
    print(message, flush=True)


def read_sql(filename: str) -> str:
    path = SQL_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"SQL file not found: {path}")
    return path.read_text(encoding="utf-8")


def clean_sql_query(query: str) -> str:
    cleaned_query = query.strip()
    while cleaned_query.endswith(";"):
        cleaned_query = cleaned_query[:-1].strip()
    return cleaned_query


def export_query_to_csv(conn: duckdb.DuckDBPyConnection, query: str, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    cleaned_query = clean_sql_query(query)
    # Forward slashes work on Windows in DuckDB
    dest = output_path.as_posix()
    conn.execute(f"COPY ({cleaned_query}) TO '{dest}' (HEADER, DELIMITER ';')")


def main() -> None:
    log("Starting export...")

    if not RAW_CSV.is_file():
        log("")
        log("ERROR: Raw CSV not found.")
        log(f"  Expected path: {RAW_CSV}")
        log("")
        log("Place the full dataset locally at data/ecommerce_events.csv")
        log("(The file is ignored by Git because of its size.)")
        sys.exit(1)

    log(f"Raw CSV found: {RAW_CSV}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    if DB_PATH.exists():
        DB_PATH.unlink()

    conn = duckdb.connect(str(DB_PATH))
    log(f"DuckDB database created: {DB_PATH}")

    try:
        # Schema from sql/01_schema.sql
        conn.execute("DROP TABLE IF EXISTS ecommerce_events")
        conn.execute(read_sql("01_schema.sql"))
        log("Raw table ecommerce_events created (schema from sql/01_schema.sql)")

        # Load CSV (Windows-friendly path for DuckDB)
        csv_path = RAW_CSV.as_posix()
        conn.execute(
            f"""
            INSERT INTO ecommerce_events
            SELECT *
            FROM read_csv_auto('{csv_path}', header = true)
            """
        )
        row_count = conn.execute("SELECT COUNT(*) FROM ecommerce_events").fetchone()[0]
        log(f"Raw data loaded: {row_count:,} rows into ecommerce_events")

        # Clean view from sql/03_clean_events.sql
        conn.execute(read_sql("03_clean_events.sql"))
        log("Clean view created: clean_funnel_events")

        overall_query = clean_sql_query(read_sql("04_funnel_overall.sql"))
        category_query = clean_sql_query(read_sql("05_funnel_by_category.sql"))
        brand_query = clean_sql_query(read_sql("06_funnel_by_brand.sql"))

        # Overall metrics once — reused for overall, steps, and drop-offs exports
        conn.execute(
            f"""
            CREATE OR REPLACE TEMP TABLE overall_funnel_metrics AS
            {overall_query}
            """
        )
        log("Temporary table created: overall_funnel_metrics")

        # A) funnel_overall.csv
        overall_path = OUTPUT_DIR / "funnel_overall.csv"
        export_query_to_csv(conn, "SELECT * FROM overall_funnel_metrics", overall_path)
        log(f"Exported: {overall_path}")

        # B) funnel_steps.csv (long format for Tableau funnel chart)
        steps_query = """
        SELECT 1 AS step_order, 'Product views' AS step_name, view_users AS users
        FROM overall_funnel_metrics
        UNION ALL
        SELECT 2 AS step_order, 'Add to cart' AS step_name, cart_users AS users
        FROM overall_funnel_metrics
        UNION ALL
        SELECT 3 AS step_order, 'Purchases' AS step_name, purchase_users AS users
        FROM overall_funnel_metrics
        """
        steps_path = OUTPUT_DIR / "funnel_steps.csv"
        export_query_to_csv(conn, steps_query, steps_path)
        log(f"Exported: {steps_path}")

        # C) funnel_dropoffs.csv (long format for Tableau drop-off chart)
        dropoffs_query = """
        SELECT 'View to cart' AS dropoff_step, view_to_cart_dropoff_users AS lost_users
        FROM overall_funnel_metrics
        UNION ALL
        SELECT 'Cart to purchase' AS dropoff_step, cart_to_purchase_dropoff_users AS lost_users
        FROM overall_funnel_metrics
        """
        dropoffs_path = OUTPUT_DIR / "funnel_dropoffs.csv"
        export_query_to_csv(conn, dropoffs_query, dropoffs_path)
        log(f"Exported: {dropoffs_path}")

        # D) funnel_by_category.csv
        category_path = OUTPUT_DIR / "funnel_by_category.csv"
        export_query_to_csv(conn, category_query, category_path)
        category_rows = conn.execute(f"SELECT COUNT(*) FROM ({category_query}) t").fetchone()[0]
        log(f"Exported: {category_path} ({category_rows:,} rows)")

        # E) funnel_by_brand.csv
        brand_path = OUTPUT_DIR / "funnel_by_brand.csv"
        export_query_to_csv(conn, brand_query, brand_path)
        brand_rows = conn.execute(f"SELECT COUNT(*) FROM ({brand_query}) t").fetchone()[0]
        log(f"Exported: {brand_path} ({brand_rows:,} rows)")

        log("")
        log("Export completed successfully.")
        log(f"Tableau-ready files are in: {OUTPUT_DIR}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()

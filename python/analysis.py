from pathlib import Path

import pandas as pd


def safe_rate(numerator: int, denominator: int) -> float:
    if denominator == 0:
        return 0.0
    return (numerator / denominator) * 100


def load_data(file_path: str) -> pd.DataFrame:
    header = pd.read_csv(file_path, nrows=0)
    available_columns = set(header.columns)

    base_columns = ["user_id", "event_type", "event_time", "category_id"]
    optional_columns = ["brand", "device"]
    selected_columns = [col for col in base_columns if col in available_columns]
    selected_columns.extend([col for col in optional_columns if col in available_columns])

    df = pd.read_csv(file_path, usecols=selected_columns)

    # Basic cleaning
    df = df.dropna(subset=["user_id", "event_type", "event_time"]).copy()
    df["event_type"] = df["event_type"].astype(str).str.strip().str.lower()
    df["event_time"] = pd.to_datetime(df["event_time"], errors="coerce")
    df = df.dropna(subset=["event_time"])

    funnel_steps = ["view", "cart", "purchase"]
    df = df[df["event_type"].isin(funnel_steps)]

    return df


def strict_funnel_counts(df: pd.DataFrame) -> tuple[int, int, int]:
    views = df[df["event_type"] == "view"]
    carts = df[df["event_type"] == "cart"]
    purchases = df[df["event_type"] == "purchase"]

    # Step 1: first view per user
    first_view = views.groupby("user_id", as_index=False)["event_time"].min()
    first_view = first_view.rename(columns={"event_time": "first_view_time"})

    # Step 2: first cart after first view
    carts_after_view = carts.merge(first_view, on="user_id", how="inner")
    carts_after_view = carts_after_view[
        carts_after_view["event_time"] > carts_after_view["first_view_time"]
    ]
    first_cart = carts_after_view.groupby("user_id", as_index=False)["event_time"].min()
    first_cart = first_cart.rename(columns={"event_time": "first_cart_time"})

    # Step 3: first purchase after first cart
    purchases_after_cart = purchases.merge(first_cart, on="user_id", how="inner")
    purchases_after_cart = purchases_after_cart[
        purchases_after_cart["event_time"] > purchases_after_cart["first_cart_time"]
    ]
    first_purchase = purchases_after_cart.groupby("user_id", as_index=False)["event_time"].min()

    view_users = first_view["user_id"].nunique()
    cart_users = first_cart["user_id"].nunique()
    purchase_users = first_purchase["user_id"].nunique()

    return view_users, cart_users, purchase_users


def calculate_funnel(df: pd.DataFrame) -> dict:
    view_users, cart_users, purchase_users = strict_funnel_counts(df)

    return {
        "view_users": view_users,
        "cart_users": cart_users,
        "purchase_users": purchase_users,
        "view_to_cart_rate": safe_rate(cart_users, view_users),
        "cart_to_purchase_rate": safe_rate(purchase_users, cart_users),
        "total_conversion_rate": safe_rate(purchase_users, view_users),  # view -> purchase
    }


def calculate_segment_funnel(df: pd.DataFrame, segment_col: str) -> pd.DataFrame:
    segment_rows = []
    segment_df = df.dropna(subset=[segment_col])

    for segment_value, part in segment_df.groupby(segment_col):
        view_users, cart_users, purchase_users = strict_funnel_counts(part)
        segment_rows.append(
            {
                "segment_type": segment_col,
                "segment_value": segment_value,
                "view_users": view_users,
                "cart_users": cart_users,
                "purchase_users": purchase_users,
                "view_to_cart_rate": safe_rate(cart_users, view_users),
                "cart_to_purchase_rate": safe_rate(purchase_users, cart_users),
                "total_conversion_rate": safe_rate(purchase_users, view_users),
            }
        )

    if not segment_rows:
        return pd.DataFrame()

    result = pd.DataFrame(segment_rows)
    result = result.sort_values("total_conversion_rate")
    return result


def qualifying_bottom_segments(segment_results: pd.DataFrame) -> pd.DataFrame:
    """Segments with enough views plus strict-funnel cart and purchase users."""
    return segment_results[
        (segment_results["view_users"] >= 500)
        & (segment_results["cart_users"] > 0)
        & (segment_results["purchase_users"] > 0)
    ].sort_values("total_conversion_rate", ascending=True)


def bottom_segments_for_print(segment_results: pd.DataFrame, n: int = 5) -> pd.DataFrame:
    return qualifying_bottom_segments(segment_results).head(n)


def print_results(results: dict) -> None:
    print("=== Ecommerce Funnel Analysis ===")
    print(f"View users:     {results['view_users']}")
    print(f"Cart users:     {results['cart_users']}")
    print(f"Purchase users: {results['purchase_users']}")
    print()
    print(f"View -> Cart conversion:     {results['view_to_cart_rate']:.2f}%")
    print(f"Cart -> Purchase conversion: {results['cart_to_purchase_rate']:.2f}%")
    print(f"Total conversion:            {results['total_conversion_rate']:.2f}%")


def print_table(segment_results: pd.DataFrame, title: str) -> None:
    print()
    print(f"=== {title} ===")
    if segment_results.empty:
        print("No data available for this segment.")
        return

    table = segment_results[
        ["segment_value", "view_users", "cart_users", "purchase_users", "total_conversion_rate"]
    ].copy()
    table = table.rename(
        columns={
            "segment_value": "segment",
            "view_users": "views",
            "cart_users": "carts",
            "purchase_users": "purchases",
            "total_conversion_rate": "total_conv_%",
        }
    )
    table["total_conv_%"] = table["total_conv_%"].map(lambda x: f"{x:.2f}")
    print(table.to_string(index=False))


def print_insights(overall: dict, worst_segment: dict | None) -> None:
    print()
    print("=== Insights (short) ===")
    print(
        f"End-to-end conversion is {overall['total_conversion_rate']:.2f}%; "
        f"biggest leakage is early (view to cart at {overall['view_to_cart_rate']:.2f}%)."
    )
    if worst_segment is None:
        print(
            "No category or brand had enough views plus cart and purchase activity "
            "to rank a weakest segment."
        )
    else:
        print(
            f"Lowest-performing segment among those with traction: "
            f"{worst_segment['segment_type']}={worst_segment['segment_value']} "
            f"({worst_segment['total_conversion_rate']:.2f}% view-to-purchase)."
        )


def main() -> None:
    primary = Path("data/ecommerce_events.csv")
    data_path = primary if primary.exists() else Path("data/ecommerce_events_sample.csv")
    df = load_data(str(data_path))
    overall_results = calculate_funnel(df)
    print_results(overall_results)

    all_segment_results = []
    if "category_id" in df.columns:
        category_results = calculate_segment_funnel(df, "category_id")
        category_top_views = category_results.sort_values("view_users", ascending=False).head(10)
        category_bottom_conversion = bottom_segments_for_print(category_results, n=5)
        category_qualifying = qualifying_bottom_segments(category_results)
        print_table(category_top_views, "Top 10 Categories by Views")
        print_table(
            category_bottom_conversion,
            "Lowest Conversion - Categories "
            "(views >= 500, at least one cart user and one purchase)",
        )
        if not category_qualifying.empty:
            all_segment_results.append(category_qualifying)

    if "brand" in df.columns:
        brand_results = calculate_segment_funnel(df, "brand")
        brand_top_views = brand_results.sort_values("view_users", ascending=False).head(10)
        brand_bottom_conversion = bottom_segments_for_print(brand_results, n=5)
        brand_qualifying = qualifying_bottom_segments(brand_results)
        print_table(brand_top_views, "Top 10 Brands by Views")
        print_table(
            brand_bottom_conversion,
            "Lowest Conversion - Brands "
            "(views >= 500, at least one cart user and one purchase)",
        )
        if not brand_qualifying.empty:
            all_segment_results.append(brand_qualifying)

    worst_segment = None
    if all_segment_results:
        combined = pd.concat(all_segment_results, ignore_index=True)
        worst_segment = combined.sort_values("total_conversion_rate").iloc[0].to_dict()

    print_insights(overall_results, worst_segment)


if __name__ == "__main__":
    main()

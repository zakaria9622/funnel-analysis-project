# E-commerce Funnel Analysis

## Project Overview

This project analyzes an e-commerce conversion funnel using event-level user data.

The goal is to understand how users move through the funnel:

1. Product view
2. Add to cart
3. Purchase

The analysis identifies the main conversion drop-off and provides business recommendations to improve revenue performance.

---

## Dataset

The dataset contains e-commerce user events with fields such as:

- user_id
- event_type
- event_time
- product_id
- category_id
- brand
- price

The analysis focuses on the key funnel events:

- view
- cart
- purchase

---

## Methodology

The analysis was performed using Python and pandas.

Main steps:

1. Load the event dataset
2. Keep relevant columns for funnel analysis
3. Clean missing or invalid values
4. Build a strict sequential funnel
5. Count unique users at each funnel step
6. Calculate conversion rates between each step
7. Identify the main conversion leak

---

## Key Results

| Funnel Step | Users |
|---|---:|
| Product Views | 3,022,130 |
| Add to Cart | 336,718 |
| Purchases | 196,474 |

| Conversion Metric | Rate |
|---|---:|
| View to Cart | 11.14% |
| Cart to Purchase | 58.35% |
| Total View to Purchase | 6.50% |

---

## Business Insights

The biggest drop-off happens between product view and add-to-cart.

Only 11.14% of users who viewed a product added it to cart. However, once users reached the cart stage, 58.35% completed a purchase.

This suggests that the main business opportunity is not the checkout step, but the product discovery and product page experience.

---

## Recommendations

To improve funnel performance, the company should focus on:

- Improving product page quality and clarity
- Making prices, shipping costs, and promotions more visible
- Strengthening call-to-action buttons
- Improving product recommendations
- Testing product page layouts through A/B testing
- Identifying categories or brands with weak add-to-cart rates

---

## Tools Used

- Python
- Pandas
- CSV data analysis
- Funnel analysis
- Customer behavior analysis

---

## How to Run the Project

Install dependencies:

```bash
pip install -r requirements.txt
```
Run the analysis:
```bash
python python/analysis.py
```

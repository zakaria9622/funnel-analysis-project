# E-commerce Funnel Analysis — View-to-Cart Bottleneck Diagnosis

![Funnel analysis dashboard](dashboard/funnel_analysis_dashboard.png)

Portfolio project for **junior Data Analyst**, **Product Analyst** and **Marketing Analyst** roles.

This project uses event-level e-commerce data to build a strict user funnel from product view to cart to purchase. The goal is to identify where users drop before buying and translate the result into product and business recommendations.

---

## Executive summary

The funnel shows that the main conversion problem happens before users add products to cart.

Key results from the full run:

- **3,022,130** users viewed products
- **336,718** users added to cart
- **196,474** users purchased
- **View → cart conversion rate:** **11.14%**
- **Cart → purchase conversion rate:** **58.35%**
- **Total view → purchase conversion rate:** **6.50%**

Main business conclusion:

The priority is not checkout first. The biggest opportunity is improving product discovery and product page experience before add-to-cart.

---

## What this project is

This project turns raw event-level data into a clear business funnel.

Instead of saying only:

> Conversion is low.

The analysis answers:

> Where exactly do users drop before purchase?

The funnel is strict and time-ordered:

```text
first product view → first cart after view → first purchase after cart
```

This avoids counting unrelated user actions as real funnel progress.

---

## The business problem

Growth and acquisition can look healthy while revenue does not keep pace.

A common tension:

- Marketing says: “We are driving views and engagement.”
- Leadership says: “Purchases are not scaling with traffic.”
- Product says: “We need to know where the experience breaks.”

Without a funnel, teams argue from averages.

With a time-ordered user-level funnel, the business can see whether the next priority should be:

- more traffic
- better product pages
- stronger add-to-cart motivation
- checkout improvements
- category or brand-specific optimization

---

## What I built

Using Python and pandas, the project:

1. Loads and cleans event-level e-commerce data.
2. Keeps the fields needed for funnel analysis.
3. Filters the relevant funnel events: `view`, `cart`, `purchase`.
4. Applies a strict sequential funnel per user.
5. Calculates unique users at each step.
6. Calculates conversion rates.
7. Produces business recommendations based on the bottleneck.

The same logic is also represented in SQL to show how the funnel can be translated into a database environment.

---

## Dataset at a glance

Typical fields in the CSV include:

```text
user_id
event_type
event_time
product_id
price
category_id
brand
```

Funnel events used:

```text
view
cart
purchase
```

The repository includes a small sample dataset so the Python pipeline can be executed and reviewed publicly.

The final KPI figures shown in this README come from the full event-level dataset used during the analysis.

---

## Dataset transparency

The full event-level dataset used for the final KPI figures is not included because of file size limitations.

This means:

- the sample dataset proves that the Python pipeline works
- the full KPI figures document the final analysis results
- the methodology remains visible in `python/analysis.py`
- the SQL logic remains visible in `sql/funnel_queries.sql`

If the full dataset is available, place it here:

```text
data/ecommerce_events.csv
```

If the full dataset is not available, the script runs on the included sample file:

```text
data/ecommerce_events_sample.csv
```

---

## Methodology

| Choice | Why it matters |
|---|---|
| Strict sequence | Cart only counts after the user’s first view. Purchase only counts after that cart. |
| Unique users per step | Rates reflect people, not raw event volume. |
| Time ordering | Avoids stitching unrelated actions into one artificial funnel. |
| Segment logic | Category and brand cuts can be analyzed with the same strict logic. |

---

## Funnel results

| Funnel step | Unique users |
|---|---:|
| Product views | 3,022,130 |
| Add to cart | 336,718 |
| Purchases | 196,474 |

| Conversion metric | Rate |
|---|---:|
| View → cart | 11.14% |
| Cart → purchase | 58.35% |
| Total view → purchase | 6.50% |

---

## Key finding

The bottleneck is early.

Only **11.14%** of users who view a product add it to cart.

Once users add to cart, conversion is comparatively strong: **58.35%** of cart users purchase.

This means the aggregate issue is not mainly checkout. The main leak happens before add-to-cart.

---

## Business diagnosis

### 1. The dominant leak is View → Cart

Most users never signal purchase intent.

This points to potential issues in:

- product discovery
- product page content
- price clarity
- offer clarity
- delivery information
- trust signals
- product relevance
- add-to-cart motivation

### 2. Cart → Purchase is stronger

A **58.35%** cart-to-purchase rate suggests that users who reach cart are relatively qualified.

Checkout may still be monitored, but it is not the first aggregate bottleneck.

### 3. Product and marketing teams should focus upstream

The first roadmap priority should be improving the experience before cart:

- listing pages
- product detail pages
- product recommendations
- product information
- pricing and promotion clarity
- reassurance elements
- CTA visibility

---

## Actionable recommendations

| Priority | Action | How to measure it |
|---|---|---|
| 1 | Treat **view → cart** as a primary KPI | Track strict view-to-cart weekly |
| 2 | Improve product pages and listing experience | Measure uplift in view-to-cart |
| 3 | Analyze high-traffic categories or brands first | Prioritize segments with volume and weak funnel |
| 4 | Keep cart → purchase as a guardrail | Make sure add-to-cart improvements do not reduce purchase quality |
| 5 | Run structured experiments | A/B test PDP, CTA, delivery info, pricing clarity |

---

## Expected KPI impact

This project does not claim results from tests that were not run.

The expected impact is directional:

- improving view-to-cart should increase cart volume
- purchases should grow if cart-to-purchase remains stable
- total conversion should improve if the upstream bottleneck is reduced
- acquisition efficiency should improve because more existing traffic turns into purchase intent

Primary KPI:

```text
View → cart rate: 11.14%
```

Guardrail KPI:

```text
Cart → purchase rate: 58.35%
```

North-star KPI:

```text
Total view → purchase rate: 6.50%
```

---

## What I would present to a business team

Problem:

The company loses most potential buyers between product view and add-to-cart.

Finding:

Only **11.14%** of users who view a product add it to cart, while **58.35%** of cart users complete a purchase.

Decision:

Prioritize product page and discovery optimization before checkout optimization.

Expected impact:

Increase add-to-cart rate, improve total conversion, and generate more purchases without increasing acquisition spend.

---

## How I would explain this in an interview

I modeled a strict sequential funnel on e-commerce events.

A cart only counts if it happens after the user’s first product view. A purchase only counts if it happens after that cart. This avoids inflating conversion with loose definitions.

On this run, about **3 million** users viewed products, **11.14%** added to cart, and **58.35%** of cart users purchased.

So the diagnosis is upstream: the business should improve product discovery and product pages before focusing mainly on checkout. I would align experiments to view-to-cart first and keep cart-to-purchase as a guardrail.

---

## What I would do next

If this were a real business case, the next steps would be:

1. Identify categories with high traffic and low view-to-cart rate.
2. Identify brands with strong views but weak cart behavior.
3. Split performance by device.
4. Compare new vs returning users.
5. Analyze price bands.
6. Test product page changes.
7. Monitor cart-to-purchase as a guardrail.

---

## Project structure

```text
funnel-analysis-project/
├── data/
│   ├── ecommerce_events_sample.csv
│   └── README.md
├── dashboard/
│   └── funnel_analysis_dashboard.png
├── python/
│   └── analysis.py
├── sql/
│   └── funnel_queries.sql
├── requirements.txt
└── README.md
```

---

## Tools used

- Python
- pandas
- SQL
- CSV analysis
- funnel analysis
- event-level data analysis
- business analytics
- product analytics
- data storytelling

---

## How to reproduce

Run the project from the repository root.

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Run the analysis

```bash
python python/analysis.py
```

### 3. Dataset path

If the full dataset is available, place it here:

```text
data/ecommerce_events.csv
```

If the full dataset is not available, the script runs on the included sample file:

```text
data/ecommerce_events_sample.csv
```

---

## SQL logic

The SQL file reproduces the strict funnel logic using common table expressions.

Main steps:

1. Find each user’s first product view.
2. Find each user’s first cart event after that view.
3. Find each user’s first purchase event after that cart.
4. Count users at each step.
5. Calculate funnel conversion rates.

This shows that the analysis can be implemented both in Python and in SQL.

---

## Skills demonstrated

- Event-level data cleaning
- Funnel analysis
- Strict sequential logic
- User-level conversion calculation
- SQL CTE logic
- Python analysis with pandas
- KPI interpretation
- Product analytics
- Business recommendations
- Analytical storytelling

---

## One-line interview pitch

I built a strict user-level funnel from product view to cart to purchase and found that the main bottleneck is before add-to-cart: only **11.14%** of viewers add to cart, while **58.35%** of cart users purchase. The business priority is therefore to improve product discovery and product pages before over-investing in checkout optimization.

---

## Conclusion

This project shows how a Data Analyst can transform raw event logs into a clear business decision.

The main lesson is simple:

The business does not mainly need more traffic or immediate checkout fixes. It first needs to improve the step where most users drop: product view to add-to-cart.
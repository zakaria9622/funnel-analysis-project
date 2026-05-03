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

This suggests that the main business opportunity is not the checkout step, but the product discovery and product page exp## Business Diagnosis

The funnel analysis shows that the main revenue leak is not located at the checkout stage, but much earlier in the customer journey.

Only 11.14% of users who view a product add it to cart, while 58.35% of users who reach the cart complete the purchase.

This means the company already has a relatively strong checkout process, but loses most potential customers before they express buying intent.

The priority should therefore be to improve product page persuasion, offer clarity, and add-to-cart motivation rather than focusing first on checkout optimization.erience.

---

## Business Diagnosis

The funnel analysis shows that the main revenue leak is not located at the checkout stage, but much earlier in the customer journey.

Only 11.14% of users who view a product add it to cart, while 58.35% of users who reach the cart complete the purchase.

This means the company already has a relatively strong checkout process, but loses most potential customers before they express buying intent.

The priority should therefore be to improve product page persuasion, offer clarity, and add-to-cart motivation rather than focusing first on checkout optimization.

---

## What I Would Present to a Business Team

Problem:
The company loses most potential buyers between product view and add-to-cart.

Finding:
Only 11.14% of users who view a product add it to cart, while 58.35% of cart users complete a purchase.

Decision:
Prioritize product page optimization before checkout optimization.

Expected Impact:
Increase add-to-cart rate, improve global conversion, and generate more purchases without increasing traffic acquisition costs.

---

## Actionable Recommendations

### 1. Improve product page conversion

Since the weakest step is product view → add to cart, the company should improve product pages before investing heavily in checkout optimization.

Recommended actions:
- make product benefits clearer above the fold
- improve product images and descriptions
- highlight delivery conditions earlier
- display return policy and trust elements more visibly
- strengthen the add-to-cart call-to-action

Expected business impact:
- higher add-to-cart rate
- more qualified users entering the checkout flow
- higher total purchases without increasing acquisition spend

### 2. Run A/B tests on product pages

The company should test different product page versions to identify what increases add-to-cart behavior.

Suggested tests:
- CTA wording and placement
- product image layout
- price and promotion visibility
- delivery cost visibility
- social proof and customer reviews

Success metric:
- improvement in view-to-cart conversion rate

### 3. Segment funnel performance by category and brand

The global funnel rate gives a high-level diagnosis, but the next step is to identify which product categories or brands are responsible for the largest drop-offs.

Recommended analysis:
- view-to-cart rate by category
- cart-to-purchase rate by category
- average price by category
- conversion rate by brand
- revenue opportunity by weak-performing category

Business value:
- prioritize fixes on categories with high traffic but low add-to-cart rate
- avoid wasting effort on low-volume segments

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

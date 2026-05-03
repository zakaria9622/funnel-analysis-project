# E-commerce Funnel Analysis

**What this is:** Event-level data, cleaned and modeled into a **strict user funnel**, so stakeholders see **where demand dies before it ever becomes a cart**—not just “conversion is low.”

Built for clarity in a portfolio or interview: business question first, methodology second, numbers third, decisions last.

---

## The business problem

Growth and acquisition can look healthy while **revenue does not keep pace**. A common tension:

- Marketing: *“We are driving views and engagement.”*  
- Finance / leadership: *“Purchases are not scaling with that activity.”*

Without a funnel, teams argue from averages. With a **time-ordered, user-level funnel**, you can show **which step loses the most qualified opportunity** and whether the next dollar should go to **traffic, product experience, or checkout**.

This project uses a **strict** definition of “in funnel” so casual browsing is not mistaken for progress toward purchase.

---

## What I built (project overview)

Using **Python** and **pandas** on e-commerce **view / cart / purchase** events:

1. Load and clean event-level data.  
2. Keep fields needed for funnel and segmentation (`user_id`, `event_type`, `event_time`, plus `category_id` and `brand` when present).  
3. Apply a **strict sequential funnel** per user: first **view** → first **cart after** that view → first **purchase after** that cart.  
4. Report overall conversion and **category / brand** views, with rules on segment tables so sparse or empty funnels do not drown out the main story (see `python/analysis.py` output).

**Run from the project root:**

```bash
pip install -r requirements.txt
python python/analysis.py
```

---

## Dataset (at a glance)

Typical fields in the CSV include:

- `user_id`, `event_type`, `event_time`  
- `product_id`, `price`, `category_id`, `brand` (where available)

Funnel events used: **view**, **cart**, **purchase**.

---

## Methodology (plain English)

| Choice | Why it matters |
|--------|----------------|
| **Strict sequence** | Cart only counts **after** the user’s first view; purchase only **after** that cart. Same user, same journey—no stitching unrelated sessions into one funnel. |
| **Unique users per step** | Rates reflect **people**, not raw event volume, so one power browser does not inflate “progress.” |
| **Segments** | Category and brand use the **same** strict logic on events in that segment; bottom lists use volume and activity filters so recommendations stay grounded. |

---

## Key results (from this run)

| Funnel step | Unique users |
|-------------|-------------:|
| Product views | 3,022,130 |
| Add to cart | 336,718 |
| Purchases | 196,474 |

| Conversion metric | Rate |
|--------------------|-----:|
| View → cart | 11.14% |
| Cart → purchase | 58.35% |
| Total view → purchase | 6.50% |

*Figures match the script output; rounding is unchanged.*

---

## Key finding

**The bottleneck is early:** only **11.14%** of users who record a product view go on to add to cart under this strict definition.

**Once intent shows up, conversion is comparatively strong:** **58.35%** of users who reach cart go on to purchase.

So the headline is not “checkout is broken at scale”—it is **“we lose most of the addressable funnel before add-to-cart.”** End-to-end view → purchase at **6.50%** is consistent with that shape.

---

## Business diagnosis

1. **Dominant leak:** View → cart. Most users never signal purchase intent in a way the funnel can count.  
2. **Relative strength:** Cart → purchase (**58.35%**) is far higher than view → cart (**11.14%**) as a share of users at each step, so **late-stage** friction is **not** the first place to over-invest at the **aggregate** level.  
3. **Implication for roadmap:** Prioritize **discovery, listings, PDP content, price and promo clarity, trust, and add-to-cart motivation** before treating checkout as the main lever—while still monitoring cart → purchase so fixes upstream do not hide stock, pricing, or trust issues downstream.

---

## Actionable recommendations

| Priority | Action | How you’d measure it |
|----------|--------|----------------------|
| 1 | Own **view → cart** as a **primary KPI** for product and lifecycle experiments (PDP, listing layout, delivery/returns messaging, CTA). | Same strict funnel definition as in code; week-over-week or experiment cells. |
| 2 | **Sequence work by segment** using the script’s category/brand tables: high traffic + weak funnel first. | Compare strict funnel rates before/after changes; no need to optimize long-tail segments first. |
| 3 | Run **structured tests** (A/B or quasi-experiments); hold **cart → purchase** as a **guardrail** so you do not trade bad add-to-carts for abandoned carts. | Lift on view → cart; alert if cart → purchase drifts far from the **58.35%** baseline without a known cause. |
| 4 | **Deeper cuts** (same data, next iteration): time, price band, new vs returning—only after the aggregate story is accepted. | Exploratory slices; still no change to the core strict definition unless the business redefines “conversion.” |

---

## Expected KPI impact (honest framing—no fabricated lift)

This project does **not** claim results from tests that were not run. What you *can* say in an application or stakeholder meeting:

- **Primary KPI:** strict **view → cart** (baseline **11.14%**). Small **absolute** improvements at **~3M** viewing users move **large** numbers of people into cart **if** the change is real and sustained.  
- **Flow-through:** Purchases scale with **cart volume** as long as **cart → purchase** stays in the ballpark of **58.35%**; that is why upstream KPI is the first focus.  
- **North-star for “success”:** agree a **target band** for view → cart and for **total view → purchase** (baseline **6.50%**) **after** experiments, measured the same way as this baseline.

That is how you discuss impact **without inventing percentage lifts.**

---

## How I’d explain this in an interview

**~45 seconds:**

> “I modeled a strict sequential funnel on e-commerce events: cart has to come after the user’s first view, and purchase after that cart, so we are not flattering ourselves with loose definitions. On this run, about **three million** users hit a view, **about eleven percent** add to cart, and **about fifty-eight percent** of those who cart purchase. So the diagnosis is upstream—grow and improve add-to-cart and PDP quality—while watching cart-to-purchase so we do not break trust or checkout. I’d align experiments to view-to-cart first and use segment outputs to decide where to start.”

**If they ask “so what would you do Monday?”**

> “Pick the highest-traffic categories or brands where the strict funnel is weakest, propose two PDP or listing variants, and measure view-to-cart with cart-to-purchase as a guardrail—using the same definitions as this baseline.”

---

## What this demonstrates (junior DA / marketing analytics)

- Translating **event logs** into **stakeholder language** and a **clear priority**.  
- Choosing **definitions** (strict funnel) that match the **business question** and avoid misleading rates.  
- Connecting metrics to **experiment design** and **KPI hierarchy** without overstating certainty.

---

## Tools & layout

**Tools:** Python, pandas; CSV analysis; funnel and segment summaries.

**Layout:**

- `data/` — e.g. `ecommerce_events.csv`  
- `python/analysis.py` — pipeline and printed results  
- `requirements.txt` — dependencies  

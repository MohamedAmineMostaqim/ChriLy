# Feature Engineering Documentation

## Overview

Feature engineering enriches the cleaned ChriLy datasets with business-oriented attributes that improve analytical capabilities without altering the normalized database structure.

Unlike many analytics projects, business KPIs are intentionally **not** precomputed in Python. KPI calculations, joins, aggregations, and business analysis are performed later in SQL to demonstrate relational database querying skills.

---

# Objectives

The feature engineering process aims to:

- Improve analytical capabilities.
- Create reusable business attributes.
- Simplify SQL analysis.
- Preserve normalized relational tables.
- Avoid redundant KPI calculations.

---

# Engineered Features

## Orders

### Temporal Features

| Feature | Description |
|----------|-------------|
| purchase_year | Purchase year |
| purchase_month | Purchase month number |
| purchase_month_name | Purchase month name |
| purchase_quarter | Calendar quarter |
| purchase_weekday | Day of week |
| purchase_hour | Purchase hour |
| is_weekend | Weekend purchase indicator |

---

### Delivery Features

| Feature | Description |
|----------|-------------|
| shipping_time_days | Days between approval and carrier pickup |
| delivery_time_days | Days between purchase and customer delivery |
| delivery_delay_days | Difference between actual and estimated delivery |
| delivery_status | Early, On Time, or Late delivery |

---

## Order Payments

### Payment Features

| Feature | Description |
|----------|-------------|
| cod_flag | Cash on Delivery indicator |
| payment_value_category | Low, Medium, High, Premium |
| payment_installments_bucket | 1, 2–3, 4–6, 7+ installments |

---

## Products

### Logistics Feature

| Feature | Description |
|----------|-------------|
| product_volume_cm3 | Product volume computed from dimensions |

---

## Reviews

### Customer Satisfaction Features

| Feature | Description |
|----------|-------------|
| review_sentiment | Negative, Neutral, Positive |
| would_recommend | True if review score ≥ 4 |

---

# Design Principles

Feature engineering followed several principles.

## Business Relevance

Every engineered feature supports a real business question or dashboard analysis.

## No KPI Precomputation

Metrics such as revenue, average order value, customer lifetime value, repeat purchase rate, and regional sales are intentionally excluded.

These metrics are calculated later using SQL.

## Preserve Normalization

Each feature remains within its original table.

No analytical dataset or denormalized master table is created during this stage.

## Reproducibility

Every engineered feature is deterministic and can be reproduced directly from the cleaned datasets.

---

# Result

The resulting datasets contain enriched business attributes while maintaining the normalized relational structure required for SQL analytics.
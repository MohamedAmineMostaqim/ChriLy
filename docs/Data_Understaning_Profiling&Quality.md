# Data Quality Audit

## Overview

This notebook evaluates the quality of the raw Olist e-commerce datasets before any transformation is applied. The audit focuses on structural integrity, completeness, validity, and business consistency to ensure the dataset is suitable for Moroccanization, data cleaning, feature engineering, SQL analysis, and dashboard development.

---

# 1. Footprint & Schema Checks

## Dataset Structure

The audit covered the nine relational datasets that compose the Olist database:

* Customers
* Geolocation
* Orders
* Order Items
* Order Payments
* Order Reviews
* Products
* Sellers
* Product Category Translation

All datasets were successfully loaded and inspected. Column data types were verified before any transformations.

## Primary Key Validation

Primary key uniqueness was tested for every table with an expected primary key.

| Table                | Primary Key                   | Result                               |
| -------------------- | ----------------------------- | ------------------------------------ |
| Customers            | customer_id                   | ✅ Pass                               |
| Orders               | order_id                      | ✅ Pass                               |
| Order Items          | order_id + order_item_id      | ✅ Pass                               |
| Order Payments       | order_id + payment_sequential | ✅ Pass                               |
| Order Reviews        | review_id                     | ⚠️ Failed (814 duplicate review IDs) |
| Products             | product_id                    | ✅ Pass                               |
| Sellers              | seller_id                     | ✅ Pass                               |
| Category Translation | product_category_name         | ✅ Pass                               |

The Geolocation dataset does not contain a natural primary key because multiple geographic coordinates may exist for the same ZIP code prefix.

## Foreign Key Validation

The following relationships were validated:

* Orders → Customers
* Order Items → Orders
* Order Items → Products
* Order Items → Sellers
* Order Payments → Orders
* Order Reviews → Orders

All foreign key relationships passed the integrity checks.

**Result**

* Orphan records detected: **0**
* Referential integrity: **Passed**

---

# 2. Missing Values

Missing values were analyzed at both the dataset and column levels.

## Dataset-Level Completeness

| Dataset            | Missing (%) |
| ------------------ | ----------: |
| Order Reviews      |      21.01% |
| Products           |       0.83% |
| Orders             |       0.62% |
| Remaining datasets |       0.00% |

The majority of missing values are concentrated within the Order Reviews dataset.

## Column-Level Completeness

The largest missing fields are:

| Column                        | Missing (%) |
| ----------------------------- | ----------: |
| review_comment_title          |      88.34% |
| review_comment_message        |      58.70% |
| order_delivered_customer_date |       2.98% |
| product_category_name         |       1.85% |
| product_name_lenght           |       1.85% |
| product_description_lenght    |       1.85% |
| product_photos_qty            |       1.85% |
| order_delivered_carrier_date  |       1.79% |
| order_approved_at             |       0.16% |

## Business Context Validation

Missing delivery timestamps were compared against the order lifecycle.

The audit showed:

* 99.04% of cancelled orders have no customer delivery timestamp.
* 100% of unavailable, processing, shipped, invoiced, created, and approved orders have no delivery timestamp.
* Only **8 delivered orders** are missing a delivery timestamp.

These results indicate that missing delivery dates are primarily explained by the business process rather than random data quality issues.

---

# 3. Numeric & Boundary Audits

Business rules were applied to identify impossible or invalid numerical values.

| Validation Rule              | Result               |
| ---------------------------- | -------------------- |
| Price > 0                    | ✅ Pass               |
| Freight Value ≥ 0            | ✅ Pass               |
| Payment Value > 0            | ⚠️ 9 invalid records |
| Payment Installments ≥ 1     | ⚠️ 2 invalid records |
| Review Score between 1 and 5 | ✅ Pass               |
| Product Weight > 0           | ⚠️ 4 invalid records |
| Customer ZIP Code Format     | ✅ Pass               |
| Seller ZIP Code Format       | ✅ Pass               |

Overall, the dataset contains only a small number of invalid numerical records, suggesting generally high data quality.

---

# 4. Business Logic Reconciliation

## Timestamp Sequence Validation

The chronological order of business events was validated using the expected workflow:

Purchase → Approval → Carrier Dispatch → Customer Delivery

### Results

| Validation          | Violations |
| ------------------- | ---------: |
| Purchase → Approval |          0 |
| Approval → Carrier  |      1,359 |
| Carrier → Customer  |         23 |

Most orders follow the expected business process. However, 1,359 records indicate carrier timestamps occurring before approval timestamps, while 23 records show delivery timestamps preceding carrier dispatch. These records will be reviewed during the cleaning phase.

## Payment Reconciliation

The total order value was calculated as:

**Price + Freight Value**

This amount was compared against the total payment value recorded in the Order Payments table.

### Results

| Metric             |  Value |
| ------------------ | -----: |
| Orders Checked     | 99,441 |
| Orders Matched     | 99,138 |
| Payment Mismatches |    303 |
| Match Rate         | 99.70% |

The reconciliation achieved a very high match rate. The remaining mismatches may result from vouchers, payment adjustments, multiple payment methods, rounding differences, or marketplace-specific business rules. These records will be investigated further during the analytical phase rather than treated as immediate data errors.

---

# 5. Exploratory Visualizations

Three visual inspections were performed as part of the audit.

## Delivery Duration Distribution

A boxplot of delivery durations was generated to identify unusually short or long delivery times and detect potential outliers.

## Payment Method Distribution

The payment distribution shows a strong preference for credit card transactions.

| Payment Type | Transactions |
| ------------ | -----------: |
| Credit Card  |       76,795 |
| Boleto       |       19,784 |
| Voucher      |        5,775 |
| Debit Card   |        1,529 |
| Not Defined  |            3 |

## Monthly Order Trend

Monthly purchase volumes were visualized across the complete observation period.

The timeline shows:

* Very few transactions during the initial months of data collection in 2016.
* Rapid growth throughout 2017.
* Stable transaction volumes during 2018 until the dataset ends.

---

# Overall Assessment

The audit indicates that the raw dataset is suitable for downstream processing.

Key observations include:

* All foreign key relationships are valid.
* All expected primary keys are unique except for duplicate review IDs.
* Missing delivery timestamps are largely explained by order status.
* Numerical integrity is generally high with only a few isolated anomalies.
* Payment reconciliation achieved a 99.70% match rate.
* Most business events follow the expected chronological sequence, although a small number of timestamp inconsistencies require further investigation.

Overall, the dataset demonstrates good structural quality and provides a solid foundation for the next stages of the project.

---

# Next Phase

The next notebook focuses on Moroccanization.

The objective is to adapt the Brazilian dataset to a Moroccan business context by localizing geographic information, customer and seller locations, product categories, and supporting business attributes while preserving the original relational structure.

The localized dataset will then be used for data cleaning, feature engineering, SQL analytics, machine learning, and Power BI dashboard development.
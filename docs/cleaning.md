# Data Cleaning Documentation

## Overview

This stage prepares the localized ChriLy datasets for downstream SQL analytics and Power BI visualization.

The cleaning process focuses exclusively on issues identified during the Data Quality Audit while preserving valid business information. No unnecessary transformations or aggressive data removal were performed.

---

# Cleaning Objectives

The cleaning process aimed to:

- Convert columns to appropriate data types.
- Correct invalid records identified during the audit.
- Handle missing values according to business context.
- Preserve the integrity of the normalized relational database.
- Produce clean datasets for SQL analysis.

---

# Cleaning Operations

## 1. Data Type Conversion

Datetime columns were converted to the appropriate datetime format.

### Orders

- order_purchase_timestamp
- order_approved_at
- order_delivered_carrier_date
- order_delivered_customer_date
- order_estimated_delivery_date

### Order Items

- shipping_limit_date

### Reviews

- review_creation_date
- review_answer_timestamp

---

## 2. Duplicate Audit

A duplicate audit was performed across every dataset.

No problematic duplicate records requiring removal were identified.

Although the geolocation dataset contains many repeated records, these correspond to legitimate coordinate observations associated with the same postal code and were intentionally preserved.

---

## 3. Missing Values

Missing values were evaluated according to their business meaning rather than removed indiscriminately.

### Orders

Missing delivery timestamps associated with canceled, unavailable, processing, shipped, created, or approved orders were preserved because they represent valid business states.

Only eight delivered orders were found with missing delivery timestamps. These records were retained because they represent less than 0.01% of the dataset.

### Reviews

Missing review titles and review messages were preserved since customer comments are optional.

### Products

Missing physical dimensions were replaced using the median value of each respective column.

Missing product categories were replaced with:

Unknown

to preserve all products.

---

## 4. Invalid Values

The following invalid values identified during the quality audit were corrected.

### Order Payments

Removed records where:

- payment_value <= 0
- payment_installments < 1

### Products

Invalid product weights (<= 0) were replaced using the median valid weight.

---

## 5. Text Standardization

No additional text normalization was required.

Customer cities, seller cities, payment methods, regions, product categories, and carrier names were generated through the Moroccanization pipeline and were already standardized.

---

# Cleaning Summary

| Cleaning Step | Action |
|---------------|--------|
| Datatype Conversion | Completed |
| Duplicate Audit | Completed (No Removal) |
| Missing Product Dimensions | Filled with Median |
| Missing Product Categories | Filled with "Unknown" |
| Logical Missing Values | Preserved |
| Invalid Payment Values | Removed |
| Invalid Installments | Removed |
| Invalid Product Weights | Replaced with Median |
| Text Standardization | Already Standardized |

---

# Output

The cleaning stage exports normalized datasets to:

```

data/clean/

```

including:

- chrily_customers.csv
- chrily_orders.csv
- chrily_order_items.csv
- chrily_order_payments.csv
- chrily_order_reviews.csv
- chrily_products.csv
- chrily_sellers.csv
- chrily_geolocation.csv
- chrily_category_translation.csv

These datasets preserve the relational schema and are used directly within PostgreSQL for SQL-based analytics.
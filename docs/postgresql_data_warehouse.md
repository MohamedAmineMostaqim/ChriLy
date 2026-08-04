# PostgreSQL Data Warehouse Documentation

# ChriLy Data Warehouse

## Overview

The PostgreSQL Data Warehouse is the analytical layer of the ChriLy project. After completing data cleaning, feature engineering, and Moroccanization, the processed datasets were loaded into PostgreSQL and transformed into a dimensional star schema optimized for business intelligence and reporting.

The warehouse separates transactional data from analytical data, enabling fast aggregations, simplified SQL queries, and efficient Power BI dashboards.

---

# Objectives

The warehouse was designed to:

* Store cleaned and engineered data in a structured analytical model.
* Support business reporting and KPI generation.
* Improve query performance through dimensional modeling.
* Serve as the primary data source for Power BI dashboards.
* Provide a scalable foundation for future analytics and machine learning.

---

# Technology Stack

* PostgreSQL
* SQL
* Python
* SQLAlchemy
* Pandas
* Jupyter Notebook

---

# Warehouse Architecture

The warehouse follows a Star Schema architecture.

```
                   Dim Customer
                        |
                        |
Dim Product ---- Fact Orders ---- Dim Seller
                        |
                        |
                    Dim Date
```

The central fact table stores measurable business events, while surrounding dimension tables contain descriptive attributes used for filtering, grouping, and reporting.

---

# Project Workflow

The PostgreSQL phase followed these steps:

1. Configure PostgreSQL connection from Python.
2. Create the analytical schema.
3. Create dimension tables.
4. Create the fact table.
5. Load staging data.
6. Build the dimensions.
7. Generate the Date Dimension.
8. Build the Fact Table.
9. Create indexes.
10. Execute business analysis queries.
11. Create analytical SQL views.

---

# Database Schemas

The project uses two schemas.

## staging

Stores cleaned datasets exactly as produced by the data engineering pipeline.

Tables:

* stg_orders
* stg_order_items
* stg_order_payments
* stg_order_reviews
* stg_customers
* stg_products
* stg_sellers

The staging layer acts as the landing zone before data is transformed into the warehouse.

---

## chrily

Contains the analytical warehouse.

Tables:

* dim_customer
* dim_product
* dim_seller
* dim_date
* fact_orders

Views:

- vw_sales (Master Reporting View)


---

# Dimension Tables

## Customer Dimension

Contains customer descriptive information.

Examples:

* Customer ID
* Customer Unique ID
* City
* State
* ZIP Code

Primary Key

* customer_key

---

## Product Dimension

Contains product descriptive attributes.

Examples:

* Product Category
* Weight
* Volume
* Dimensions

Primary Key

* product_key

---

## Seller Dimension

Contains seller information.

Examples:

* Seller City
* Seller State

Primary Key

* seller_key

---

## Date Dimension

Generated from purchase dates.

Contains:

* Date
* Year
* Quarter
* Month
* Month Name
* Week
* Day
* Weekday
* Weekend Flag

Primary Key

* date_key

---

# Fact Table

The fact table stores transactional business events at the order-item level.

Measures include:

* Product Price
* Freight Value
* Allocated Payment Value
* Shipping Time
* Delivery Time
* Delivery Delay
* Review Score

Business attributes include:

* Delivery Status
* Payment Type
* Installments
* COD Flag
* Ramadan Flag
* Holiday Flag
* Weekend Flag

Foreign Keys:

* customer_key
* product_key
* seller_key
* date_key

---

# ETL Process

The ETL process transforms staging data into the analytical warehouse.

Major steps include:

* Loading cleaned datasets into staging tables.
* Populating dimension tables with unique records.
* Building the Date Dimension from purchase dates.
* Aggregating payment information by order.
* Aggregating review information by order.
* Calculating total order value.
* Allocating payments proportionally across order items.
* Loading the Fact Table.
* Validating row counts after loading.

---

# Payment Allocation Logic

Some orders contain multiple products but only one payment record.

To preserve financial accuracy, payments are allocated proportionally to each order item using:

Allocated Payment = Total Payment × ((Item Price + Freight) ÷ Total Order Value)

This ensures every order item receives its proportional share of the total payment while maintaining consistency with the original transaction.

---

# Indexing Strategy

Indexes were created to improve analytical query performance.

Fact Table:

* customer_key
* seller_key
* product_key
* date_key
* order_id
* payment_type
* delivery_status

Dimension Tables:

* customer_id
* product_id
* seller_id
* full_date

---

# Business Analysis

The warehouse supports multiple analytical queries, including:

* Monthly Revenue Trend
* Revenue by Product Category
* Top Products
* Top Sellers
* Top Customers
* Customer Revenue Ranking
* Delivery Performance
* Payment Analysis
* Customer Satisfaction Analysis
* Ramadan Sales Analysis
* Running Revenue
* Month-over-Month Revenue Growth

These queries validate the warehouse and provide reusable business insights for dashboards and reporting.

---

# Analytical Views

To simplify reporting, several SQL views were created.

Views:

- vw_sales (Master Reporting View)

The Power BI dashboard connects primarily to the master reporting view (`vw_sales`), which joins the fact table with all dimension tables into a single business-friendly dataset.
---

# Data Quality

Several validation steps were performed throughout the warehouse build:

* Primary key uniqueness
* Foreign key integrity
* Duplicate prevention
* Date conversion validation
* Payment aggregation validation
* Review aggregation validation
* Warehouse row count verification

---

# Integration with Power BI

The PostgreSQL warehouse serves as the primary data source for Power BI.

Instead of connecting directly to raw CSV files, Power BI connects to the analytical warehouse and SQL views, ensuring:

* Faster dashboards
* Simpler data model
* Centralized business logic
* Consistent KPIs
* Improved scalability

---

# Benefits of the Warehouse

* Optimized for analytical workloads.
* Simplified reporting through star schema design.
* Reduced query complexity.
* Improved dashboard performance.
* Reusable business logic.
* Scalable architecture for future enhancements.
* Seamless integration with Power BI and machine learning workflows.

---
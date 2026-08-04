-- ==========================================================
-- MASTER REPORTING VIEW
-- ==========================================================

DROP VIEW IF EXISTS chrily.vw_sales;

CREATE VIEW chrily.vw_sales AS

SELECT

    -- ======================================================
    -- FACT IDENTIFIERS
    -- ======================================================

    f.fact_order_key,
    f.order_id,
    f.order_item_id,

    -- ======================================================
    -- DATE
    -- ======================================================

    d.full_date,
    d.year,
    d.quarter,
    d.month,
    d.month_name,
    d.day,
    d.weekday,
    d.week,

    -- ======================================================
    -- CUSTOMER
    -- ======================================================

    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- ======================================================
    -- SELLER
    -- ======================================================

    s.seller_id,
    s.seller_city,
    s.seller_state,

    -- ======================================================
    -- PRODUCT
    -- ======================================================

    p.product_id,
    p.product_category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    p.product_volume_cm3,

    -- ======================================================
    -- SALES
    -- ======================================================

    f.price,
    f.freight_value,
    f.payment_value_allocated,

    -- ======================================================
    -- PAYMENT
    -- ======================================================

    f.payment_type,
    f.payment_installments,
    f.payment_installments_bucket,
    f.cod_flag,

    -- ======================================================
    -- DELIVERY
    -- ======================================================

    f.shipping_time_days,
    f.delivery_time_days,
    f.delivery_delay_days,
    f.delivery_status,

    -- ======================================================
    -- CUSTOMER EXPERIENCE
    -- ======================================================

    f.review_score,
    f.review_sentiment,
    f.would_recommend,

    -- ======================================================
    -- MOROCCAN FEATURES
    -- ======================================================

    f.holiday,
    f.is_holiday,
    f.is_ramadan,
    f.is_weekend

FROM chrily.fact_orders f

INNER JOIN chrily.dim_customer c
ON f.customer_key = c.customer_key

INNER JOIN chrily.dim_product p
ON f.product_key = p.product_key

INNER JOIN chrily.dim_seller s
ON f.seller_key = s.seller_key

INNER JOIN chrily.dim_date d
ON f.date_key = d.date_key;
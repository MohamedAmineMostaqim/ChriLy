-- ==========================================================
-- ChriLy Data Warehouse
-- Build Warehouse
-- ==========================================================

BEGIN;

-- ==========================================================
-- Clean Dimensions (Allows Safe Rebuild)
-- ==========================================================

TRUNCATE TABLE chrily.fact_orders RESTART IDENTITY;

TRUNCATE TABLE chrily.dim_date RESTART IDENTITY CASCADE;

TRUNCATE TABLE chrily.dim_product RESTART IDENTITY CASCADE;

TRUNCATE TABLE chrily.dim_seller RESTART IDENTITY CASCADE;

TRUNCATE TABLE chrily.dim_customer RESTART IDENTITY CASCADE;

-- ==========================================================
-- CUSTOMER DIMENSION
-- ==========================================================

INSERT INTO chrily.dim_customer (

    customer_id,
    customer_unique_id,
    customer_city,
    customer_state

)

SELECT DISTINCT

    customer_id,
    customer_unique_id,
    customer_city,
    customer_state

FROM staging.stg_customers;

-- ==========================================================
-- SELLER DIMENSION
-- ==========================================================

INSERT INTO chrily.dim_seller (

    seller_id,
    seller_city,
    seller_state

)

SELECT DISTINCT

    seller_id,
    seller_city,
    seller_state

FROM staging.stg_sellers;

-- ==========================================================
-- PRODUCT DIMENSION
-- ==========================================================

INSERT INTO chrily.dim_product (

    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_volume_cm3

)

SELECT DISTINCT

    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_volume_cm3

FROM staging.stg_products;

-- ==========================================================
-- DATE DIMENSION
-- ==========================================================

INSERT INTO chrily.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    weekday,
    week,
    is_weekend
)
SELECT DISTINCT
    TO_CHAR(purchase_date, 'YYYYMMDD')::INTEGER,
    purchase_date,
    purchase_year,
    purchase_quarter,
    purchase_month,
    purchase_month_name,
    EXTRACT(DAY FROM purchase_date)::INTEGER,
    purchase_weekday,
    EXTRACT(WEEK FROM purchase_date)::INTEGER,
    is_weekend
FROM staging.stg_orders
ORDER BY purchase_date;

-- ==========================================================
-- FACT TABLE
-- ==========================================================

WITH payments AS (

    SELECT

        order_id,

        SUM(payment_value) AS payment_value,

        MAX(payment_installments) AS payment_installments,

        MAX(payment_installments_bucket) AS payment_installments_bucket,

        BOOL_OR(cod_flag) AS cod_flag,

        STRING_AGG(
            DISTINCT payment_type,
            ', '
            ORDER BY payment_type
        ) AS payment_type

    FROM staging.stg_order_payments

    GROUP BY order_id

),

reviews AS (

    SELECT

        order_id,

        ROUND(AVG(review_score),0)::INTEGER AS review_score,

        CASE

            WHEN AVG(review_score) >= 4 THEN 'Positive'

            WHEN AVG(review_score) >= 3 THEN 'Neutral'

            ELSE 'Negative'

        END AS review_sentiment,

        BOOL_OR(would_recommend) AS would_recommend

    FROM staging.stg_order_reviews

    GROUP BY order_id

),

order_totals AS (

    SELECT

        order_id,

        SUM(price + freight_value) AS total_order_value,

        COUNT(*) AS items_per_order

    FROM staging.stg_order_items

    GROUP BY order_id

)

INSERT INTO chrily.fact_orders (

    order_id,

    order_item_id,

    customer_key,

    seller_key,

    product_key,

    date_key,

    price,

    freight_value,

    payment_value_allocated,

    shipping_time_days,

    delivery_time_days,

    delivery_delay_days,

    payment_type,

    payment_installments,

    payment_installments_bucket,

    cod_flag,

    review_score,

    review_sentiment,

    would_recommend,

    delivery_status,

    holiday,

    is_holiday,

    is_ramadan,

    is_weekend

)
SELECT

    oi.order_id,

    oi.order_item_id,

    dc.customer_key,

    ds.seller_key,

    dp.product_key,

    dd.date_key,

    oi.price,

    oi.freight_value,

    ROUND(
    CAST(
        p.payment_value *
        (
            (oi.price + oi.freight_value)
            /
            ot.total_order_value
        )
    AS NUMERIC),
    2
    ) AS payment_value_allocated,

    o.shipping_time_days,

    o.delivery_time_days,

    o.delivery_delay_days,

    p.payment_type,

    p.payment_installments,

    p.payment_installments_bucket,

    p.cod_flag,

    r.review_score,

    r.review_sentiment,

    r.would_recommend,

    o.delivery_status,

    o.holiday,

    o.is_holiday,

    o.is_ramadan,

    o.is_weekend

FROM staging.stg_order_items oi

INNER JOIN staging.stg_orders o
    ON oi.order_id = o.order_id

INNER JOIN order_totals ot
    ON oi.order_id = ot.order_id

INNER JOIN payments p
    ON oi.order_id = p.order_id

LEFT JOIN reviews r
    ON oi.order_id = r.order_id

INNER JOIN chrily.dim_customer dc
    ON o.customer_id = dc.customer_id

INNER JOIN chrily.dim_product dp
    ON oi.product_id = dp.product_id

INNER JOIN chrily.dim_seller ds
    ON oi.seller_id = ds.seller_id

INNER JOIN chrily.dim_date dd
    ON dd.full_date = o.purchase_date::date;

-- ==========================================================
-- Validation
-- ==========================================================

SELECT
    COUNT(*) AS customers
FROM chrily.dim_customer;

SELECT
    COUNT(*) AS sellers
FROM chrily.dim_seller;

SELECT
    COUNT(*) AS products
FROM chrily.dim_product;

SELECT
    COUNT(*) AS dates
FROM chrily.dim_date;

SELECT
    COUNT(*) AS fact_rows
FROM chrily.fact_orders;

COMMIT;
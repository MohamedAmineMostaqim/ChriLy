-- ==========================================================
-- SALES VIEW
-- ==========================================================

CREATE OR REPLACE VIEW chrily.vw_sales AS

SELECT

    f.order_id,

    f.order_item_id,

    d.full_date,

    d.year,

    d.quarter,

    d.month,

    d.month_name,

    c.customer_city,

    c.customer_state,

    s.seller_city,

    s.seller_state,

    p.product_category_name,

    f.price,

    f.freight_value,

    f.payment_value_allocated,

    f.review_score,

    f.review_sentiment,

    f.delivery_status,

    f.is_ramadan,

    f.is_holiday,

    f.is_weekend

FROM chrily.fact_orders f

JOIN chrily.dim_customer c

ON f.customer_key = c.customer_key

JOIN chrily.dim_product p

ON f.product_key = p.product_key

JOIN chrily.dim_seller s

ON f.seller_key = s.seller_key

JOIN chrily.dim_date d

ON f.date_key = d.date_key;



CREATE OR REPLACE VIEW chrily.vw_products AS

SELECT

    p.product_category_name,

    p.product_weight_g,

    p.product_volume_cm3,

    f.payment_value_allocated,

    f.review_score,

    d.year,

    d.month

FROM chrily.fact_orders f

JOIN chrily.dim_product p

ON f.product_key = p.product_key

JOIN chrily.dim_date d

ON f.date_key = d.date_key;


CREATE OR REPLACE VIEW chrily.vw_customers AS

SELECT

    c.customer_unique_id,

    c.customer_city,

    c.customer_state,

    f.order_id,

    f.payment_value_allocated,

    f.review_score,

    d.year,

    d.month

FROM chrily.fact_orders f

JOIN chrily.dim_customer c

ON f.customer_key = c.customer_key

JOIN chrily.dim_date d

ON f.date_key = d.date_key;


CREATE OR REPLACE VIEW chrily.vw_delivery AS

SELECT

    d.full_date,

    s.seller_city,

    s.seller_state,

    f.delivery_status,

    f.shipping_time_days,

    f.delivery_time_days,

    f.delivery_delay_days

FROM chrily.fact_orders f

JOIN chrily.dim_date d

ON f.date_key = d.date_key

JOIN chrily.dim_seller s

ON f.seller_key = s.seller_key;

CREATE OR REPLACE VIEW chrily.vw_payments AS

SELECT

    d.year,

    d.month,

    f.payment_type,

    f.payment_installments,

    f.payment_installments_bucket,

    f.cod_flag,

    f.payment_value_allocated

FROM chrily.fact_orders f

JOIN chrily.dim_date d

ON f.date_key = d.date_key;


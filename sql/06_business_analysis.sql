-- ==========================================================
-- ChriLy Data Warehouse
-- Business Analysis
-- ==========================================================

-- ==========================================================
-- 1. Monthly Revenue Trend
-- Business Question:
-- How has revenue evolved over time?
-- ==========================================================

SELECT

    d.year,
    d.month,
    d.month_name,

    COUNT(DISTINCT f.order_id) AS total_orders,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS total_revenue,

    ROUND(AVG(f.payment_value_allocated)::NUMERIC,2) AS average_sale

FROM chrily.fact_orders f

JOIN chrily.dim_date d
ON f.date_key = d.date_key

GROUP BY

    d.year,
    d.month,
    d.month_name

ORDER BY

    d.year,
    d.month;

-- ==========================================================
-- 2. Revenue by Product Category
-- Business Question:
-- Which product categories generate the most revenue?
-- ==========================================================

SELECT

    p.product_category_name,

    COUNT(*) AS items_sold,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS revenue,

    ROUND(AVG(f.payment_value_allocated)::NUMERIC,2) AS average_sale

FROM chrily.fact_orders f

JOIN chrily.dim_product p
ON f.product_key = p.product_key

GROUP BY

    p.product_category_name

ORDER BY revenue DESC;

-- ==========================================================
-- 3. Top Products
-- Business Question:
-- Which individual products generate the highest revenue?
-- ==========================================================

SELECT

    p.product_id,

    p.product_category_name,

    COUNT(*) AS quantity_sold,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS revenue

FROM chrily.fact_orders f

JOIN chrily.dim_product p
ON f.product_key = p.product_key

GROUP BY

    p.product_id,
    p.product_category_name

ORDER BY revenue DESC

LIMIT 10;

-- ==========================================================
-- 4. Top Sellers
-- Business Question:
-- Which sellers generate the highest revenue?
-- ==========================================================

SELECT

    s.seller_city,

    s.seller_state,

    COUNT(DISTINCT f.order_id) AS total_orders,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS revenue,

    ROUND(AVG(f.review_score)::NUMERIC,2) AS average_review

FROM chrily.fact_orders f

JOIN chrily.dim_seller s
ON f.seller_key = s.seller_key

GROUP BY

    s.seller_city,
    s.seller_state

ORDER BY revenue DESC

LIMIT 10;

-- ==========================================================
-- 5. Top Customers
-- Business Question:
-- Which customers generate the highest revenue?
-- ==========================================================

SELECT

    c.customer_unique_id,

    c.customer_city,

    c.customer_state,

    COUNT(DISTINCT f.order_id) AS total_orders,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS total_spent,

    ROUND(AVG(f.payment_value_allocated)::NUMERIC,2) AS average_order_value

FROM chrily.fact_orders f

JOIN chrily.dim_customer c
ON f.customer_key = c.customer_key

GROUP BY

    c.customer_unique_id,
    c.customer_city,
    c.customer_state

ORDER BY total_spent DESC

LIMIT 10;

-- ==========================================================
-- 6. Customer Revenue Ranking
-- Business Question:
-- Rank customers based on total revenue generated.
-- ==========================================================

SELECT

    c.customer_unique_id,

    c.customer_city,

    c.customer_state,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS total_revenue,

    RANK() OVER (

        ORDER BY SUM(f.payment_value_allocated) DESC

    ) AS customer_rank

FROM chrily.fact_orders f

JOIN chrily.dim_customer c
ON f.customer_key = c.customer_key

GROUP BY

    c.customer_unique_id,
    c.customer_city,
    c.customer_state

ORDER BY customer_rank;

-- ==========================================================
-- 7. Delivery Performance
-- Business Question:
-- How does delivery performance vary by delivery status?
-- ==========================================================

SELECT

    delivery_status,

    COUNT(*) AS total_items,

    ROUND(AVG(delivery_time_days)::NUMERIC,2) AS average_delivery_days,

    ROUND(AVG(delivery_delay_days)::NUMERIC,2) AS average_delay_days

FROM chrily.fact_orders

GROUP BY

    delivery_status

ORDER BY

    total_items DESC;

-- ==========================================================
-- 8. Payment Analysis
-- Business Question:
-- Which payment methods generate the most revenue?
-- ==========================================================

SELECT

    payment_type,

    COUNT(*) AS transactions,

    ROUND(SUM(payment_value_allocated)::NUMERIC,2) AS revenue,

    ROUND(AVG(payment_value_allocated)::NUMERIC,2) AS average_payment

FROM chrily.fact_orders

GROUP BY

    payment_type

ORDER BY revenue DESC;

-- ==========================================================
-- 9. Customer Satisfaction Analysis
-- Business Question:
-- How does customer sentiment relate to revenue?
-- ==========================================================

SELECT

    review_sentiment,

    COUNT(*) AS total_reviews,

    ROUND(AVG(review_score)::NUMERIC,2) AS average_review_score,

    ROUND(SUM(payment_value_allocated)::NUMERIC,2) AS total_revenue

FROM chrily.fact_orders

GROUP BY

    review_sentiment

ORDER BY

    average_review_score DESC;

-- ==========================================================
-- 10. Ramadan Sales Analysis
-- Business Question:
-- Does Ramadan influence sales performance?
-- ==========================================================

SELECT

    is_ramadan,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(SUM(payment_value_allocated)::NUMERIC,2) AS total_revenue,

    ROUND(AVG(payment_value_allocated)::NUMERIC,2) AS average_sale

FROM chrily.fact_orders

GROUP BY

    is_ramadan;

-- ==========================================================
-- 11. Running Revenue
-- Business Question:
-- How does cumulative revenue grow over time?
-- ==========================================================

SELECT

    d.year,

    d.month,

    d.month_name,

    ROUND(SUM(f.payment_value_allocated)::NUMERIC,2) AS monthly_revenue,

    ROUND(

        SUM(
            SUM(f.payment_value_allocated)
        ) OVER (

            ORDER BY
                d.year,
                d.month

        )::NUMERIC,

        2

    ) AS cumulative_revenue

FROM chrily.fact_orders f

JOIN chrily.dim_date d

ON f.date_key = d.date_key

GROUP BY

    d.year,
    d.month,
    d.month_name

ORDER BY

    d.year,
    d.month;

-- ==========================================================
-- 12. Month-over-Month Revenue Growth
-- Business Question:
-- How has revenue changed compared to the previous month?
-- ==========================================================

WITH monthly_sales AS (

    SELECT

        d.year,

        d.month,

        d.month_name,

        SUM(f.payment_value_allocated) AS revenue

    FROM chrily.fact_orders f

    JOIN chrily.dim_date d

    ON f.date_key = d.date_key

    GROUP BY

        d.year,
        d.month,
        d.month_name

)

SELECT

    year,

    month,

    month_name,

    ROUND(revenue::NUMERIC,2) AS revenue,

    ROUND(

        LAG(revenue) OVER (

            ORDER BY
                year,
                month

        )::NUMERIC,

        2

    ) AS previous_month_revenue,

    ROUND(

        (
            revenue
            -
            LAG(revenue) OVER (

                ORDER BY
                    year,
                    month

            )
        )::NUMERIC,

        2

    ) AS revenue_difference

FROM monthly_sales

ORDER BY

    year,
    month;
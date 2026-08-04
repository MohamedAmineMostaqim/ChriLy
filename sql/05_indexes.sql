-- ==========================================================
-- ChriLy Data Warehouse
-- Indexes
-- ==========================================================

-- ===========================
-- Fact Table Indexes
-- ===========================

CREATE INDEX IF NOT EXISTS idx_fact_customer
ON chrily.fact_orders(customer_key);

CREATE INDEX IF NOT EXISTS idx_fact_seller
ON chrily.fact_orders(seller_key);

CREATE INDEX IF NOT EXISTS idx_fact_product
ON chrily.fact_orders(product_key);

CREATE INDEX IF NOT EXISTS idx_fact_date
ON chrily.fact_orders(date_key);

CREATE INDEX IF NOT EXISTS idx_fact_order
ON chrily.fact_orders(order_id);

CREATE INDEX IF NOT EXISTS idx_fact_payment_type
ON chrily.fact_orders(payment_type);

CREATE INDEX IF NOT EXISTS idx_fact_delivery_status
ON chrily.fact_orders(delivery_status);

-- ===========================
-- Dimension Indexes
-- ===========================

CREATE INDEX IF NOT EXISTS idx_customer_id
ON chrily.dim_customer(customer_id);

CREATE INDEX IF NOT EXISTS idx_product_id
ON chrily.dim_product(product_id);

CREATE INDEX IF NOT EXISTS idx_seller_id
ON chrily.dim_seller(seller_id);

CREATE INDEX IF NOT EXISTS idx_date_full
ON chrily.dim_date(full_date);
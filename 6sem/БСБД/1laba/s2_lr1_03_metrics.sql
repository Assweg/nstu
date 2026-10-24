-- Задание 2. Расчет метрик маркетинговой аналитики

SET search_path TO app, ref, audit, stg, public;
SET ROLE app_owner;

-- Блок А. Метрики за всё время (сканирование всех секций)
-- 1. LTV (Lifetime Value) - общая выручка от каждого клиента за весь период

WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.full_name,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date,
        SUM(o.total_amount) AS total_revenue
    FROM app.customers c
    JOIN app.orders_partitioned o
      ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.full_name
),
customer_ltv AS (
    SELECT
        customer_id,
        full_name,
        total_revenue AS ltv,
        first_order_date,
        last_order_date
    FROM customer_orders
)
SELECT
    customer_id      AS client_id,
    full_name        AS client_name,
    ltv,
    first_order_date,
    last_order_date
FROM customer_ltv
ORDER BY ltv DESC;

-- 2. AOV (Average Order Value) - средний чек клиента

WITH customer_stats AS (
    SELECT
        c.customer_id,
        c.full_name,
        COUNT(o.order_id)  AS orders_count,
        SUM(o.total_amount) AS total_revenue
    FROM app.customers c
    JOIN app.orders_partitioned o
      ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.full_name
),
customer_aov AS (
    SELECT
        customer_id,
        full_name,
        total_revenue,
        orders_count,
        (total_revenue / NULLIF(orders_count, 0))::NUMERIC(12,2) AS aov
    FROM customer_stats
)
SELECT
    customer_id      AS client_id,
    full_name        AS client_name,
    orders_count,
    total_revenue,
    aov
FROM customer_aov
ORDER BY aov DESC
LIMIT 5;

-- Блок Б. Метрики за отчетный период (только секция текущего месяца)

WITH params AS (SELECT DATE '2026-02-01' AS period_start,
                       DATE '2026-03-01' AS period_end),

orders_month AS (
    SELECT o.*
    FROM app.orders_partitioned o
    CROSS JOIN params p
    WHERE o.order_date >= p.period_start
        AND o.order_date <  p.period_end),

active_customers AS (
    -- Активные клиенты: хотя бы один заказ за все время
    SELECT DISTINCT o.customer_id
    FROM app.orders_partitioned o),

paying_customers_month AS (
    -- Платящие клиенты за отчетный месяц
    SELECT DISTINCT om.customer_id
    FROM orders_month om),

revenue_month AS (
    SELECT SUM(om.total_amount) AS revenue
    FROM orders_month om)

SELECT
    'ARPU и ARPPU' AS metric_description,
    (SELECT revenue FROM revenue_month) /
        NULLIF((SELECT COUNT(*) FROM active_customers), 0)::NUMERIC(12,2) AS arpu,
    (SELECT revenue FROM revenue_month) /
        NULLIF((SELECT COUNT(*) FROM paying_customers_month), 0)::NUMERIC(12,2) AS arppu,
    (SELECT COUNT(*) FROM active_customers)           AS active_customers_total,
    (SELECT COUNT(*) FROM paying_customers_month)     AS paying_customers_month,
    (SELECT revenue FROM revenue_month)               AS revenue_month_total;


-- EXPLAIN ANALYZE
-- WITH params AS (
--     SELECT DATE '2026-02-01' AS period_start,
--            DATE '2026-03-01' AS period_end
-- ),
-- orders_month AS (
--     SELECT o.*
--     FROM app.orders_partitioned o
--     CROSS JOIN params p
--     WHERE o.order_date >= p.period_start
--       AND o.order_date <  p.period_end
-- )
-- SELECT
--     SUM(om.total_amount) /
--         NULLIF(COUNT(DISTINCT om.customer_id), 0)::NUMERIC(12,2) AS arppu
-- FROM orders_month om;
--
-- В результате плана выполнения должен быть виден Partition Pruning
-- (сканируется только партиция app.orders_p_current).

-- 5. Топ-3 популярных товаров/услуг за последний месяц

WITH params AS (
    SELECT
        DATE '2026-02-01' AS period_start,
        DATE '2026-03-01' AS period_end
),
orders_month AS (
    SELECT
        o.order_id
    FROM app.orders_partitioned o
    CROSS JOIN params p
    WHERE o.order_date >= p.period_start
      AND o.order_date <  p.period_end
),
items_month AS (
    SELECT
        oi.product_id,
        oi.quantity
    FROM app.order_items oi
    JOIN orders_month om
      ON oi.order_id = om.order_id
),
product_stats AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(im.quantity) AS total_quantity
    FROM app.products p
    JOIN items_month im
      ON im.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    total_quantity
FROM product_stats
ORDER BY total_quantity DESC
LIMIT 3;

-- 6. Топ-3 непопулярных товаров/услуг за последний месяц (среди тех, что покупались)

WITH params AS (
    SELECT
        DATE '2026-02-01' AS period_start,
        DATE '2026-03-01' AS period_end
),
orders_month AS (
    SELECT
        o.order_id
    FROM app.orders_partitioned o
    CROSS JOIN params p
    WHERE o.order_date >= p.period_start
      AND o.order_date <  p.period_end
),
items_month AS (
    SELECT
        oi.product_id,
        oi.quantity
    FROM app.order_items oi
    JOIN orders_month om
      ON oi.order_id = om.order_id
),
product_stats AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(im.quantity) AS total_quantity
    FROM app.products p
    JOIN items_month im
      ON im.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    total_quantity
FROM product_stats
ORDER BY total_quantity ASC
LIMIT 3;

RESET ROLE;
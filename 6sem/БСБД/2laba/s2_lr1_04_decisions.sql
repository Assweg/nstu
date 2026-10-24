-- Задание 3. Принятие решений и обновление данных на основе метрик

SET search_path TO app, ref, audit, stg, public;
SET ROLE app_owner;

DO $$
BEGIN
    RAISE NOTICE 'S2 LR1: старт задания 3 (изменение структуры и данных на основе аналитики)';
END;
$$;

-- 1. Уровни лояльности и VIP-статус на основе LTV

ALTER TABLE IF EXISTS app.customers
    ADD COLUMN IF NOT EXISTS is_vip BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS loyalty_level TEXT,
    ADD COLUMN IF NOT EXISTS loyalty_discount_percent NUMERIC(5,2) DEFAULT 0;

COMMENT ON COLUMN app.customers.is_vip IS
    'Признак VIP-клиента, рассчитанный по метрике LTV';

COMMENT ON COLUMN app.customers.loyalty_level IS
    'Уровень карты лояльности клиента (BRONZE / SILVER / GOLD) на основе LTV';

COMMENT ON COLUMN app.customers.loyalty_discount_percent IS
    'Скидка по карте лояльности в процентах (5 / 10 / 15) в зависимости от уровня';

WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.full_name,
        SUM(o.total_amount) AS total_revenue
    FROM app.customers c
    JOIN app.orders_partitioned o
      ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.full_name
)


UPDATE app.customers c
SET loyalty_level = CASE
        WHEN co.total_revenue >= 800000 THEN 'GOLD'
        WHEN co.total_revenue >= 400000 THEN 'SILVER'
        WHEN co.total_revenue >= 250000 THEN 'BRONZE'
        ELSE NULL
    END,
    loyalty_discount_percent = CASE
        WHEN co.total_revenue >= 800000 THEN 15.00
        WHEN co.total_revenue >= 400000 THEN 10.00
        WHEN co.total_revenue >= 250000 THEN 5.00
        ELSE 0.00
    END,
    is_vip = (co.total_revenue >= 250000)
FROM customer_orders co
WHERE c.customer_id = co.customer_id;

-- 2. Назначение скидки к товарам на основе их непопулярности за отчётный период

ALTER TABLE IF EXISTS app.products
    ADD COLUMN IF NOT EXISTS discount_percent NUMERIC(5,2) DEFAULT 0;

COMMENT ON COLUMN app.products.discount_percent IS
    'Размер скидки на товар/услугу в процентах, установленный по результатам аналитики';

ALTER TABLE IF EXISTS app.products
    ADD COLUMN IF NOT EXISTS final_price NUMERIC(12,2);

COMMENT ON COLUMN app.products.final_price IS
    'Цена товара после скидки на товар (без учёта VIP): base_price с учётом discount_percent';

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
        SUM(im.quantity) AS total_quantity
    FROM app.products p
    JOIN items_month im
      ON im.product_id = p.product_id
    GROUP BY p.product_id
),
least_popular AS (
    -- Топ-3 наименее популярных товаров среди тех, что покупались за отчётный месяц
    SELECT
        ps.product_id
    FROM product_stats ps
    ORDER BY ps.total_quantity ASC
    LIMIT 3
)
UPDATE app.products p
SET discount_percent = 20.00
FROM least_popular lp
WHERE p.product_id = lp.product_id;

-- Конечная цена товара после скидки на товар (решение 2, физическое поле)
UPDATE app.products
SET final_price = ROUND((base_price * (100 - COALESCE(discount_percent, 0)) / 100)::NUMERIC, 2);

DO $$
DECLARE
    disc_cnt INTEGER;
BEGIN
    SELECT COUNT(*) INTO disc_cnt FROM app.products WHERE discount_percent >= 20.00;
    RAISE NOTICE 'S2 LR1: скидка 20%% назначена на непопулярные товары (кол-во: %)', disc_cnt;
END;
$$;

-- 3. Корректировка скидок по карте лояльности по ARPPU за отчётный месяц

ALTER TABLE IF EXISTS app.customers
    ADD COLUMN IF NOT EXISTS arppu_bonus_percent NUMERIC(5,2) DEFAULT 0;

COMMENT ON COLUMN app.customers.arppu_bonus_percent IS
    'Бонус к скидке по карте лояльности из решения 3 (по условию ARPPU)';

DO $$
DECLARE
    v_arppu NUMERIC(18,2);
    v_bonus INTEGER;
BEGIN
    WITH params AS (
        SELECT DATE '2026-02-01' AS d1, DATE '2026-03-01' AS d2
    ),
    om AS (
        SELECT o.total_amount, o.customer_id
        FROM app.orders_partitioned o
        CROSS JOIN params p
        WHERE o.order_date >= p.d1 AND o.order_date < p.d2
    )
    SELECT
        ROUND((COALESCE(SUM(om.total_amount), 0) / NULLIF(COUNT(DISTINCT om.customer_id), 0))::NUMERIC, 2)
    INTO v_arppu
    FROM om;

    IF v_arppu IS NULL OR v_arppu >= 280000 THEN
        UPDATE app.customers
        SET arppu_bonus_percent = 0
        WHERE loyalty_level IS NOT NULL;

        RAISE NOTICE 'S2 LR1: ARPPU = %, бонус по карте не начисляется (порог 280000)', v_arppu;
    ELSE
        UPDATE app.customers
        SET loyalty_discount_percent = loyalty_discount_percent + 5.00,
            arppu_bonus_percent = 5.00
        WHERE loyalty_level IS NOT NULL;

        GET DIAGNOSTICS v_bonus = ROW_COUNT;
        RAISE NOTICE 'S2 LR1: ARPPU = % < 280000, начислен +5%% к скидке по карте (% клиентов)', v_arppu, v_bonus;
    END IF;
END;
$$;

-- Пример «покупки» для VIP: расчёт строки заказа (каталожная цена после скидки на товар + скидка VIP по лояльности)
CREATE OR REPLACE FUNCTION app.quote_vip_purchase_line(
    p_customer_id INTEGER,
    p_product_id  INTEGER,
    p_quantity    INTEGER DEFAULT 1
)
RETURNS TABLE (
    customer_name           TEXT,
    is_vip                  BOOLEAN,
    product_name            TEXT,
    quantity                INTEGER,
    base_price              NUMERIC(12,2),
    product_discount_pct    NUMERIC(5,2),
    price_after_product_disc NUMERIC(12,2),
    vip_loyalty_pct         NUMERIC(5,2),
    unit_price_after_vip    NUMERIC(12,2),
    line_total_after_vip    NUMERIC(12,2)
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        c.full_name,
        c.is_vip,
        pr.product_name,
        p_quantity,
        pr.base_price,
        COALESCE(pr.discount_percent, 0),
        COALESCE(pr.final_price, ROUND((pr.base_price * (100 - COALESCE(pr.discount_percent, 0)) / 100)::NUMERIC, 2)),
        COALESCE(c.loyalty_discount_percent, 0),
        ROUND(
            (COALESCE(pr.final_price, ROUND((pr.base_price * (100 - COALESCE(pr.discount_percent, 0)) / 100)::NUMERIC, 2))
             * (100 - COALESCE(c.loyalty_discount_percent, 0)) / 100)::NUMERIC,
            2
        ),
        ROUND(
            (COALESCE(pr.final_price, ROUND((pr.base_price * (100 - COALESCE(pr.discount_percent, 0)) / 100)::NUMERIC, 2))
             * (100 - COALESCE(c.loyalty_discount_percent, 0)) / 100 * p_quantity)::NUMERIC,
            2
        )
    FROM app.customers c
    CROSS JOIN app.products pr
    WHERE c.customer_id = p_customer_id
      AND pr.product_id = p_product_id
      AND c.is_vip = TRUE;
$$;

COMMENT ON FUNCTION app.quote_vip_purchase_line IS
    'Пример расчёта строки покупки для VIP: цена после скидки на товар и после скидки по карте лояльности';

-- Демонстрация для отчёта: покупка VIP (скидка по карте применяется к final_price товара)
SELECT * FROM app.quote_vip_purchase_line(
    (SELECT customer_id FROM app.customers WHERE is_vip ORDER BY customer_id LIMIT 1),
    (SELECT product_id FROM app.products ORDER BY product_id LIMIT 1),
    2
);

-- То же количество товара без скидки VIP (для сравнения в отчёте: экономия = без_VIP − line_total_after_vip)
WITH one_cust AS (
    SELECT customer_id FROM app.customers WHERE is_vip ORDER BY customer_id LIMIT 1
),
one_prod AS (
    SELECT product_id, final_price FROM app.products ORDER BY product_id LIMIT 1
)
SELECT
    'Без скидки VIP (только цена товара с учётом скидки на товар)' AS режим,
    op.product_id,
    ROUND((op.final_price * 2)::NUMERIC, 2) AS line_total_no_vip
FROM one_prod op;

RESET ROLE;
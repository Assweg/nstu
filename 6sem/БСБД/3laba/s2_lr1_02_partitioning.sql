-- Задание 1. Реализация секционирования (партицирования)

SET search_path TO app, ref, audit, stg, public;
SET ROLE app_owner;

-- 1. Создание новой секционированной таблицы, полностью повторяющей структуру app.orders

DROP TABLE IF EXISTS app.orders_partitioned CASCADE;

CREATE TABLE app.orders_partitioned (
    order_id        INTEGER       NOT NULL,
    customer_id     INTEGER       NOT NULL,
    order_date      DATE          NOT NULL,
    status          VARCHAR(30),
    total_amount    NUMERIC(12,2) NOT NULL,
    created_at      TIMESTAMPTZ   DEFAULT NOW(),
    CONSTRAINT orders_partitioned_pk PRIMARY KEY (order_date, order_id)
)
PARTITION BY RANGE (order_date);

COMMENT ON TABLE app.orders_partitioned IS
    'Секционированная таблица заказов по диапазону дат (архив + текущий месяц)';

-- 2. Создание партиций (секций)

DROP TABLE IF EXISTS app.orders_p_archive;
DROP TABLE IF EXISTS app.orders_p_current;

CREATE TABLE app.orders_p_archive
    PARTITION OF app.orders_partitioned
    FOR VALUES FROM (MINVALUE) TO ('2026-02-01');

COMMENT ON TABLE app.orders_p_archive IS
    'Архивная партиция заказов (до 01.02.2026 включительно)';

CREATE TABLE app.orders_p_current
    PARTITION OF app.orders_partitioned
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

COMMENT ON TABLE app.orders_p_current IS
    'Текущая партиция заказов (февраль 2026 - отчетный период)';

-- 3. Перенос данных из оригинальной таблицы app.orders в секционированную

INSERT INTO app.orders_partitioned (order_id, customer_id, order_date, status, total_amount, created_at)
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.total_amount,
    o.created_at
FROM app.orders o;

DO $$
DECLARE
    total_count   BIGINT;
    archive_count BIGINT;
    current_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_count FROM app.orders_partitioned;
    SELECT COUNT(*) INTO archive_count FROM app.orders_p_archive;
    SELECT COUNT(*) INTO current_count FROM app.orders_p_current;

    RAISE NOTICE 'S2 LR1: всего заказов скопировано: %', total_count;
    RAISE NOTICE 'S2 LR1: в архивной партиции: %', archive_count;
    RAISE NOTICE 'S2 LR1: в текущей партиции (февраль 2026): %', current_count;
END;
$$;

RESET ROLE;
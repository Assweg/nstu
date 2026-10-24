-- Часть 1. Расширение модели данными о клиентах, товарах и заказах

SET search_path TO app, ref, audit, stg, public;
SET ROLE app_owner;

-- 1. Таблица клиентов (покупателей услуг студии дубляжа)

CREATE TABLE IF NOT EXISTS app.customers (
    customer_id      SERIAL PRIMARY KEY,
    full_name       VARCHAR(200) NOT NULL,
    email           VARCHAR(150),
    phone           VARCHAR(30),
    registered_at   TIMESTAMPTZ DEFAULT NOW(),
    is_active       BOOLEAN      DEFAULT TRUE
);

COMMENT ON TABLE app.customers IS
    'Клиенты (покупатели услуг студии дубляжа) для аналитики маркетинговых метрик';

-- 2. Таблица товаров/услуг

CREATE TABLE IF NOT EXISTS app.products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(200) NOT NULL,
    category        VARCHAR(100),
    base_price      NUMERIC(12,2) NOT NULL,
    is_active       BOOLEAN      DEFAULT TRUE,
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

COMMENT ON TABLE app.products IS
    'Товары/услуги (пакеты дубляжа), которые приобретают клиенты';

-- 3. Таблица заказов (базовая, не секционированная)

CREATE TABLE IF NOT EXISTS app.orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INTEGER      NOT NULL REFERENCES app.customers(customer_id),
    order_date      DATE         NOT NULL,
    status          VARCHAR(30)  DEFAULT 'new',
    total_amount    NUMERIC(12,2) NOT NULL,
    created_at      TIMESTAMPTZ  DEFAULT NOW()
);

COMMENT ON TABLE app.orders IS
    'История заказов клиентов (операции покупки услуг дубляжа)';

CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON app.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON app.orders(order_date);

-- 4. Таблица позиций заказа (строки заказа)

CREATE TABLE IF NOT EXISTS app.order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INTEGER      NOT NULL REFERENCES app.orders(order_id) ON DELETE CASCADE,
    product_id      INTEGER      NOT NULL REFERENCES app.products(product_id),
    quantity        INTEGER      NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    line_total      NUMERIC(12,2) NOT NULL CHECK (line_total >= 0)
);

COMMENT ON TABLE app.order_items IS
    'Позиции заказов клиентов (какой товар/услуга, в каком количестве и по какой цене)';

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON app.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON app.order_items(product_id);

-- 5. Триггер для автоматического пересчёта line_total = quantity * unit_price

CREATE OR REPLACE FUNCTION app.order_items_set_line_total()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.line_total := NEW.quantity * NEW.unit_price;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_order_items_set_line_total ON app.order_items;

CREATE TRIGGER trg_order_items_set_line_total
BEFORE INSERT OR UPDATE OF quantity, unit_price
ON app.order_items
FOR EACH ROW
EXECUTE FUNCTION app.order_items_set_line_total();

-- 6. Триггер для автоматического пересчёта суммы заказа total_amount по строкам заказа

CREATE OR REPLACE FUNCTION app.orders_recalculate_total()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE app.orders o
       SET total_amount = COALESCE((
           SELECT SUM(oi.line_total)
           FROM app.order_items oi
           WHERE oi.order_id = o.order_id
       ), 0)
     WHERE o.order_id = COALESCE(NEW.order_id, OLD.order_id);

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_order_items_after_change ON app.order_items;

CREATE TRIGGER trg_order_items_after_change
AFTER INSERT OR UPDATE OR DELETE
ON app.order_items
FOR EACH ROW
EXECUTE FUNCTION app.orders_recalculate_total();

-- 7. Наполнение тестовыми данными для демонстрации метрик

INSERT INTO app.customers (full_name, email, phone, registered_at) VALUES
    ('ООО «КиноПрокат Плюс»', 'kinoprokat@example.com', '+7-900-111-2233', '2025-01-15'),
    ('Стриминговый сервис «StreamFun»', 'streamfun@example.com', '+7-900-222-3344', '2025-06-10'),
    ('Кинотеатр «Премьер»', 'premiere@example.com', '+7-900-333-4455', '2025-09-05'),
    ('Кинокомпания «АртФильм»', 'artfilm@example.com', '+7-900-444-5566', '2024-11-20'),
    ('Онлайн-кинотеатр «MovieNow»', 'movienow@example.com', '+7-900-555-6677', '2025-12-01'),
    ('Продюсерский центр «RetroVision»', 'retrovision@example.com', '+7-900-666-7788', '2024-07-10')
ON CONFLICT DO NOTHING;

INSERT INTO app.products (product_name, category, base_price) VALUES
    ('Полный дубляж полнометражного фильма', 'Фильм', 300000.00),
    ('Дубляж серии сериала (45 минут)', 'Сериал', 80000.00),
    ('Локализация документального фильма', 'Документальный', 150000.00),
    ('Рекламный ролик до 60 секунд', 'Реклама', 50000.00),
    ('Озвучивание обучающего курса', 'Обучающий', 120000.00),
    ('Адаптация трейлера', 'Трейлер', 40000.00)
ON CONFLICT DO NOTHING;

-- Немного заказов за разные месяцы, чтобы были и "архив", и "текущий период" (февраль 2026)

-- Январь 2026 (архив)
INSERT INTO app.orders (customer_id, order_date, status, total_amount)
VALUES
    (1, '2026-01-10', 'completed', 0),
    (2, '2026-01-18', 'completed', 0),
    (3, '2026-01-25', 'completed', 0);

INSERT INTO app.order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
    (currval('app.orders_order_id_seq') - 2, 1, 1, 300000.00, 300000.00), -- заказ 1
    (currval('app.orders_order_id_seq') - 1, 2, 3, 80000.00, 240000.00),  -- заказ 2
    (currval('app.orders_order_id_seq'),     4, 2, 50000.00, 100000.00);  -- заказ 3

-- Февраль 2026 (отчетный месяц / partition_current)
INSERT INTO app.orders (customer_id, order_date, status, total_amount)
VALUES
    (1, '2026-02-03', 'completed', 0),
    (2, '2026-02-05', 'completed', 0),
    (2, '2026-02-15', 'completed', 0),
    (3, '2026-02-20', 'completed', 0),
    (4, '2026-02-22', 'completed', 0),
    (5, '2026-02-25', 'completed', 0);

INSERT INTO app.order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
    -- заказ клиента 1
    (currval('app.orders_order_id_seq') - 5, 1, 1, 320000.00, 320000.00),
    -- два заказа клиента 2
    (currval('app.orders_order_id_seq') - 4, 2, 4, 85000.00, 340000.00),
    (currval('app.orders_order_id_seq') - 3, 5, 2, 125000.00, 250000.00),
    -- заказы клиентов 3, 4, 5
    (currval('app.orders_order_id_seq') - 2, 3, 1, 155000.00, 155000.00),
    (currval('app.orders_order_id_seq') - 1, 4, 5, 52000.00, 260000.00),
    (currval('app.orders_order_id_seq'),     6, 3, 42000.00, 126000.00);

-- Дополнительный заказ в другом месяце для демонстрации "старых" клиентов
INSERT INTO app.orders (customer_id, order_date, status, total_amount)
VALUES
    (5, '2025-12-15', 'completed', 0);

INSERT INTO app.order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
    (currval('app.orders_order_id_seq'), 1, 1, 290000.00, 290000.00);

-- Клиент, активный за всю историю, но не платящий в феврале 2026.
-- Это гарантирует отличие ARPU и ARPPU (active_customers > paying_customers_month).
INSERT INTO app.orders (customer_id, order_date, status, total_amount)
VALUES
    (
        (SELECT customer_id
         FROM app.customers
         WHERE full_name = 'Продюсерский центр «RetroVision»'
         ORDER BY customer_id DESC
         LIMIT 1),
        '2025-11-20',
        'completed',
        0
    );

INSERT INTO app.order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
    (currval('app.orders_order_id_seq'), 5, 1, 118000.00, 118000.00);

RESET ROLE;
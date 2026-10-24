-- =============================================================================
-- ЛР4 (семестр 2), ЗАДАНИЕ 2 — ЧАСТЬ B: «имитация аварии»
-- =============================================================================
-- КОГДА ЗАПУСКАТЬ: только после s2_lr4_02_before_disaster.sql
--               и паузы 1–2 минуты (требование ТЗ).
--               Команда: ./scripts/s2_lr4_task2.sh disaster
--
-- ЧТО ДЕЛАЕТ (по ТЗ):
--   1) DROP TABLE — разрушительное действие (логический сбой / атака)
--   2) Создаёт таблицу заново и вставляет «Данные после аварии»
--   3) pg_switch_wal() — новый сегмент WAL после инцидента
--
-- СКРИНШОТ ДЛЯ ОТЧЁТА: SELECT в конце — должна быть только строка «после аварии».
-- После этого переходите к заданию 3: ./scripts/s2_lr4_task3.sh
-- =============================================================================

\set ON_ERROR_STOP on
SET client_min_messages TO NOTICE;

\echo '=== Задание 2, часть B: имитация инцидента ==='

DROP TABLE pitr_lab.important_data;

CREATE TABLE pitr_lab.important_data (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO pitr_lab.important_data (message)
VALUES ('Данные после аварии');

SELECT pg_switch_wal() AS switched_wal_after_disaster;

-- >>> СКРИНШОТ ДЛЯ ОТЧЁТА: «плохое» состояние БД перед PITR <<<
SELECT id, message, created_at
FROM pitr_lab.important_data
ORDER BY id;

\echo 'Часть B завершена. Данные «до аварии» в текущей БД отсутствуют — это ожидаемо.'

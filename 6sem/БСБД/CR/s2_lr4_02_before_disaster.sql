-- =============================================================================
-- ЛР4 (семестр 2), ЗАДАНИЕ 2 — ЧАСТЬ A: «до аварии»
-- =============================================================================
-- КОГДА ЗАПУСКАТЬ: после ./run_docker.sh start и проверки задания 1.
--               Сначала выполните shell-скрипт задания 2 (pg_basebackup):
--                 ./scripts/s2_lr4_task2.sh backup
--               затем этот файл:
--                 ./scripts/s2_lr4_task2.sh before
--               ИЛИ вручную (см. комментарии в scripts/s2_lr4_task2.sh).
--
-- ЧТО ДЕЛАЕТ (по ТЗ, пункт «работа с данными»):
--   1) Создаёт контрольную таблицу pitr_lab.important_data
--   2) Вставляет строку «Данные до аварии»
--   3) CHECKPOINT + pg_switch_wal() — сбрасывает данные в WAL для PITR
--   4) SELECT now() — покажите это время в отчёте (целевая точка восстановления)
--
-- ВАЖНО: блок «имитация аварии» — в файле s2_lr4_02_disaster.sql
--        Запускайте его только через 1–2 минуты после этого скрипта!
-- =============================================================================

\set ON_ERROR_STOP on
SET client_min_messages TO NOTICE;

\echo '=== Задание 2, часть A: контрольные данные ДО аварии ==='

CREATE SCHEMA IF NOT EXISTS pitr_lab;
COMMENT ON SCHEMA pitr_lab IS 'Схема для демонстрации PITR (ЛР4)';

DROP TABLE IF EXISTS pitr_lab.important_data CASCADE;

CREATE TABLE pitr_lab.important_data (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO pitr_lab.important_data (message)
VALUES ('Данные до аварии');

-- Сброс буферов на диск и ротация WAL — зафиксировать состояние в журнале
CHECKPOINT;
SELECT pg_switch_wal() AS wal_switched_before_target;

SELECT now() AS recovery_target_time;

SELECT id, message, created_at
FROM pitr_lab.important_data
ORDER BY id;

\echo 'Часть A завершена. Подождите 1–2 мин, затем: ./scripts/s2_lr4_task2.sh disaster'

-- =============================================================================
-- ЛР4 (семестр 2), ЗАДАНИЕ 1 — проверка инфраструктуры WAL
-- =============================================================================
-- КОГДА: после ./run_docker.sh start (настройки уже в docker-compose.yml).
--        Задания 2 и 3 при start НЕ выполняются — только этот файл вручную.
--
-- ЗАПУСК:
--   ./run_docker.sh s2-lr4-check-1
--   или:
--   docker cp s2_lr4_01_infrastructure.sql dubbing_studio_postgres:/tmp/
--   docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr4_01_infrastructure.sql
--
-- ЧТО ПРОВЕРЯЕТ (по ТЗ задания 1):
--   data_checksums = on
--   wal_level = replica
--   archive_mode = on
--   archive_command вызывает s2_lr4_archive_wal.sh (gzip + openssl AES-256-CBC)
--
-- СКРИНШОТ ДЛЯ ОТЧЁТА: таблица pg_settings в конце + число *.gz.enc в archive:
--   docker exec dubbing_studio_postgres ls /var/lib/postgresql/archive | head
-- =============================================================================

\set ON_ERROR_STOP on
SET client_min_messages TO NOTICE;

\echo '=== Задание 1: инфраструктура WAL и шифрование архивов ==='

DO $$
DECLARE
    v_checksums TEXT;
    v_wal_level TEXT;
    v_archive_mode TEXT;
    v_archive_cmd TEXT;
BEGIN
    SELECT setting INTO v_checksums FROM pg_settings WHERE name = 'data_checksums';
    SELECT setting INTO v_wal_level FROM pg_settings WHERE name = 'wal_level';
    SELECT setting INTO v_archive_mode FROM pg_settings WHERE name = 'archive_mode';
    SELECT setting INTO v_archive_cmd FROM pg_settings WHERE name = 'archive_command';

    RAISE NOTICE 'data_checksums = %', v_checksums;
    RAISE NOTICE 'wal_level = %', v_wal_level;
    RAISE NOTICE 'archive_mode = %', v_archive_mode;
    RAISE NOTICE 'archive_command = %', v_archive_cmd;

    IF v_checksums IS DISTINCT FROM 'on' THEN
        RAISE EXCEPTION 'data_checksums должны быть on (initdb --data-checksums). Пересоздайте том: ./run_docker.sh cleanup && ./run_docker.sh start';
    END IF;

    IF v_wal_level IS DISTINCT FROM 'replica' AND v_wal_level IS DISTINCT FROM 'logical' THEN
        RAISE EXCEPTION 'wal_level должен быть replica (сейчас: %)', v_wal_level;
    END IF;

    IF v_archive_mode IS DISTINCT FROM 'on' THEN
        RAISE EXCEPTION 'archive_mode должен быть on (сейчас: %)', v_archive_mode;
    END IF;

    IF v_archive_cmd IS NULL OR v_archive_cmd = '' OR position('s2_lr4_archive_wal' IN v_archive_cmd) = 0 THEN
        RAISE EXCEPTION 'archive_command должен вызывать s2_lr4_archive_wal.sh';
    END IF;
END $$;

SELECT
    name AS parameter,
    setting AS value,
    CASE name
        WHEN 'data_checksums' THEN 'контроль целостности страниц (initdb -k)'
        WHEN 'wal_level' THEN 'достаточно WAL для репликации/PITR'
        WHEN 'archive_mode' THEN 'непрерывное архивирование'
        WHEN 'archive_command' THEN 'шифрование: gzip | openssl enc AES-256-CBC'
        ELSE ''
    END AS description
FROM pg_settings
WHERE name IN ('data_checksums', 'wal_level', 'archive_mode', 'archive_command')
ORDER BY name;

-- Принудительная ротация WAL — в каталоге archive появятся файлы *.gz.enc
SELECT pg_switch_wal() AS switched_wal;

\echo 'Задание 1 проверено. Далее вручную: ./scripts/s2_lr4_task2.sh backup'

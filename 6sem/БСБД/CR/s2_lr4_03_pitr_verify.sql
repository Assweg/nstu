-- =============================================================================
-- ЛР4 (семестр 2), ЗАДАНИЕ 3 — проверка успешного PITR
-- =============================================================================
-- КОГДА: после ./scripts/s2_lr4_task3.sh start (сервер уже promote).
--
-- ЗАПУСК:
--   ./scripts/s2_lr4_task3.sh verify
--   или вручную скопировать файл в контейнер и выполнить через psql -f
--
-- КРИТЕРИИ УСПЕХА (по ТЗ):
--   • pg_is_in_recovery() = false (сервер принимает записи)
--   • таблица pitr_lab.important_data существует
--   • есть строка «Данные до аварии»
--   • НЕТ строки «Данные после аварии»
--
-- СКРИНШОТ ДЛЯ ОТЧЁТА: результат SELECT в конце + NOTICE об успехе
-- =============================================================================

\set ON_ERROR_STOP on
SET client_min_messages TO NOTICE;

\echo '=== Задание 3: проверка результата PITR ==='

DO $$
DECLARE
    v_in_recovery BOOLEAN;
    v_before_cnt INT;
    v_after_cnt INT;
BEGIN
    SELECT pg_is_in_recovery() INTO v_in_recovery;
    IF v_in_recovery THEN
        RAISE EXCEPTION 'Сервер всё ещё в режиме recovery (pg_is_in_recovery = true)';
    END IF;

    IF to_regclass('pitr_lab.important_data') IS NULL THEN
        RAISE EXCEPTION 'Таблица pitr_lab.important_data отсутствует — PITR не восстановил данные до аварии';
    END IF;

    SELECT COUNT(*) INTO v_before_cnt
    FROM pitr_lab.important_data
    WHERE message = 'Данные до аварии';

    SELECT COUNT(*) INTO v_after_cnt
    FROM pitr_lab.important_data
    WHERE message = 'Данные после аварии';

    RAISE NOTICE 'Строк «Данные до аварии»: %', v_before_cnt;
    RAISE NOTICE 'Строк «Данные после аварии»: %', v_after_cnt;

    IF v_before_cnt < 1 THEN
        RAISE EXCEPTION 'PITR неуспешен: нет контрольной записи «Данные до аварии»';
    END IF;

    IF v_after_cnt > 0 THEN
        RAISE EXCEPTION 'PITR неуспешен: присутствуют данные «после аварии» (неверный recovery_target_time?)';
    END IF;

    RAISE NOTICE 'PITR выполнен успешно: восстановлено состояние до инцидента';
END $$;

-- >>> Главный скриншот для отчёта по заданию 3 <<<
SELECT
    id,
    message,
    created_at
FROM pitr_lab.important_data
ORDER BY id;

\echo 'Задание 3: проверка PITR пройдена'

-- Лабораторная работа 3 (семестр 2)
-- Работа с шифрованием данных

SET client_min_messages TO NOTICE;

\i s2_lr3_01_password_encryption.sql
\i s2_lr3_03_key_management.sql
\i s2_lr3_02_column_encryption.sql
\i s2_lr3_04_performance.sql
\i s2_lr3_05_conclusions.sql

DO $$
BEGIN
    RAISE NOTICE 'S2 LR3: все задания (кроме SSL) выполнены';
END;
$$;


-- DO $$
-- BEGIN
--     -- Перезаписываем пароли теми же значениями, чтобы хэш стал SCRAM-SHA-256.
--     EXECUTE 'ALTER ROLE studio_manager WITH PASSWORD ''manager_pass123''';
--     EXECUTE 'ALTER ROLE voice_actor WITH PASSWORD ''actor_pass123''';
--     EXECUTE 'ALTER ROLE security_auditor WITH PASSWORD ''auditor_pass123''';
--     EXECUTE 'ALTER ROLE app_owner_user WITH PASSWORD ''owner_pass123''';
-- END;
-- $$;
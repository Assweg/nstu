SET search_path TO public;

SELECT rolname, rolpassword
FROM pg_authid
WHERE rolname IN ('studio_manager', 'voice_actor', 'security_auditor', 'app_owner_user')
ORDER BY rolname;

-- Изменяем метод хеширования 
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
SELECT pg_reload_conf();

-- Изменяем пароли на новый метод
-- ALTER ROLE studio_manager WITH PASSWORD 'manager_pass123';
-- ALTER ROLE voice_actor WITH PASSWORD 'actor_pass123';
-- ALTER ROLE security_auditor WITH PASSWORD 'auditor_pass123';
-- ALTER ROLE app_owner_user WITH PASSWORD 'owner_pass123';

DO $$
BEGIN
    -- Перезаписываем пароли теми же значениями, чтобы хэш стал SCRAM-SHA-256.
    EXECUTE 'ALTER ROLE studio_manager WITH PASSWORD ''manager_pass123''';
    EXECUTE 'ALTER ROLE voice_actor WITH PASSWORD ''actor_pass123''';
    EXECUTE 'ALTER ROLE security_auditor WITH PASSWORD ''auditor_pass123''';
    EXECUTE 'ALTER ROLE app_owner_user WITH PASSWORD ''owner_pass123''';
END;
$$;



-- Проверка после изменения
SELECT rolname, rolpassword
FROM pg_authid
WHERE rolname IN ('studio_manager', 'voice_actor', 'security_auditor', 'app_owner_user')
ORDER BY rolname;
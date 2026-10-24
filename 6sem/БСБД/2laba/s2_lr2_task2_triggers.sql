SET search_path TO app, audit, public;

ALTER TABLE app.projects
    ADD COLUMN IF NOT EXISTS project_code VARCHAR(50);

ALTER TABLE app.recording_sessions
    ADD COLUMN IF NOT EXISTS contract_salary_snapshot NUMERIC(10,2);

ALTER TABLE app.actors
    ADD COLUMN IF NOT EXISTS login_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS password_hash TEXT;

CREATE TABLE IF NOT EXISTS app.password_change_acl (
    db_login VARCHAR(100) PRIMARY KEY,
    can_change_password BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS audit.delete_watch_log (
    event_id BIGSERIAL PRIMARY KEY,
    db_user VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    deleted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Триггер проверки уникальности значения перед вставкой
CREATE OR REPLACE FUNCTION app.tg_projects_check_unique_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.project_code IS NOT NULL AND EXISTS (
        SELECT 1
        FROM app.projects p
        WHERE p.project_code = NEW.project_code
    ) THEN
        RAISE EXCEPTION 'Проект с кодом "%" уже существует', NEW.project_code;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_projects_check_unique_code ON app.projects;
CREATE TRIGGER trg_projects_check_unique_code
BEFORE INSERT ON app.projects
FOR EACH ROW
EXECUTE FUNCTION app.tg_projects_check_unique_code();

-- Триггер автозаполнения даты при вставке
CREATE OR REPLACE FUNCTION app.tg_projects_fill_created_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at := NOW();
    END IF;

    RETURN NEW;
END;
$$;


DROP TRIGGER IF EXISTS trg_projects_fill_created_at ON app.projects;
CREATE TRIGGER trg_projects_fill_created_at
BEFORE INSERT ON app.projects
FOR EACH ROW
EXECUTE FUNCTION app.tg_projects_fill_created_at();

-- Триггер обновления поля в связанной таблице при изменении ключевой записи
CREATE OR REPLACE FUNCTION app.tg_contracts_sync_salary_to_sessions()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE app.recording_sessions rs
       SET contract_salary_snapshot = NEW.salary_amount
     WHERE rs.contract_id = NEW.contract_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_contracts_sync_salary_to_sessions ON app.contracts;
CREATE TRIGGER trg_contracts_sync_salary_to_sessions
AFTER UPDATE OF salary_amount ON app.contracts
FOR EACH ROW
WHEN (OLD.salary_amount IS DISTINCT FROM NEW.salary_amount)
EXECUTE FUNCTION app.tg_contracts_sync_salary_to_sessions();

-- Триггер обнаружения подозрительных DELETE и блокировки действий
CREATE OR REPLACE FUNCTION app.tg_audio_archives_detect_mass_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    recent_count INTEGER;
BEGIN
    SELECT COUNT(*)
      INTO recent_count
      FROM audit.delete_watch_log l
     WHERE l.db_user = CURRENT_USER
       AND l.table_name = 'app.audio_archives'
       AND l.deleted_at > NOW() - INTERVAL '1 minute';

    IF recent_count >= 5 THEN
        RAISE EXCEPTION 'Подозрительная активность: слишком много удалений из app.audio_archives за короткий период (пользователь: %)', CURRENT_USER;
    END IF;

    INSERT INTO audit.delete_watch_log(db_user, table_name)
    VALUES (CURRENT_USER, 'app.audio_archives');

    RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_audio_archives_detect_mass_delete ON app.audio_archives;
CREATE TRIGGER trg_audio_archives_detect_mass_delete
BEFORE DELETE ON app.audio_archives
FOR EACH ROW
EXECUTE FUNCTION app.tg_audio_archives_detect_mass_delete();

-- Триггер блокировки смены пароля без разрешения
CREATE OR REPLACE FUNCTION app.tg_actors_block_password_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    is_allowed BOOLEAN;
BEGIN
    IF NEW.password_hash IS DISTINCT FROM OLD.password_hash THEN
        SELECT a.can_change_password
          INTO is_allowed
          FROM app.password_change_acl a
         WHERE a.db_login = CURRENT_USER;

        IF COALESCE(is_allowed, FALSE) = FALSE THEN
            RAISE EXCEPTION 'Смена пароля запрещена для пользователя "%": нет специального разрешения', CURRENT_USER;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_actors_block_password_change ON app.actors;
CREATE TRIGGER trg_actors_block_password_change
BEFORE UPDATE OF password_hash ON app.actors
FOR EACH ROW
EXECUTE FUNCTION app.tg_actors_block_password_change();


-- Демонстрация работы триггеров
-- уникальность
INSERT INTO app.projects (
    studio_id, title, original_language, description, project_code, created_at
)
VALUES (
    1, 'DEMO Trigger Project', 'ru', 'demo row', 'PRJ-DEMO-001', NULL
);

SELECT project_id, project_code, created_at
FROM app.projects
WHERE project_code = 'PRJ-DEMO-001';

DO $$
BEGIN
    INSERT INTO app.projects (
        studio_id, title, original_language, description, project_code
    )
    VALUES (
        1, 'DEMO Trigger Project Duplicate', 'ru', 'duplicate code', 'PRJ-DEMO-001'
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ожидаемая ошибка уникальности: %', SQLERRM;
END;
$$;

-- Обновление связанных данных
UPDATE app.contracts
   SET salary_amount = salary_amount + 100
 WHERE contract_id = 1;

SELECT session_id, contract_id, contract_salary_snapshot
FROM app.recording_sessions
WHERE contract_id = 1
ORDER BY session_id
LIMIT 5;

-- Блокировка массовых удалений
DO $$
BEGIN
    FOR i IN 1..6 LOOP
        DELETE FROM app.audio_archives
         WHERE archive_id = (SELECT MIN(archive_id) FROM app.audio_archives);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ожидаемая блокировка удаления: %', SQLERRM;
END;
$$;

-- Блокировка смены пароля
UPDATE app.actors
   SET login_name = 'demo_actor',
       password_hash = COALESCE(password_hash, md5('pass1'))
 WHERE actor_id = 1;

INSERT INTO app.password_change_acl(db_login, can_change_password)
VALUES ('postgres', FALSE)
ON CONFLICT (db_login) DO UPDATE
SET can_change_password = EXCLUDED.can_change_password;

DO $$
BEGIN
    UPDATE app.actors
       SET password_hash = md5('pass2')
     WHERE actor_id = 1;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ожидаемая блокировка смены пароля: %', SQLERRM;
END;
$$;

UPDATE app.password_change_acl
SET can_change_password = TRUE
WHERE db_login = 'postgres';

UPDATE app.actors
SET password_hash = md5('pass3')
WHERE actor_id = 1;

SELECT actor_id, login_name, password_hash
FROM app.actors
WHERE actor_id = 1;
-- Задание 4. Безопасное хранение ключей шифрования
-- Ключи лежат ВНЕ БД: read-only том Docker ./secrets -> /var/lib/postgresql/secrets
-- В БД хранится только метадата и зашифрованный закрытый PGP-ключ (KEK тоже только в secrets).

CREATE SCHEMA IF NOT EXISTS key_store AUTHORIZATION app_owner;

SET search_path TO key_store, app, ref, public;

-- Пересоздаём реестр при миграции со старой схемы (ключи в plaintext внутри БД).
DROP TABLE IF EXISTS key_store.crypto_materials CASCADE;

CREATE TABLE key_store.crypto_materials (
    key_id BIGSERIAL PRIMARY KEY,
    key_name TEXT NOT NULL UNIQUE,
    key_type TEXT NOT NULL CHECK (key_type IN ('pgp_private_encrypted', 'metadata')),
    key_value BYTEA,
    storage_location TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by TEXT NOT NULL DEFAULT CURRENT_USER
);

ALTER TABLE key_store.crypto_materials OWNER TO app_owner;

REVOKE ALL ON SCHEMA key_store FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA key_store FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA key_store FROM PUBLIC;
GRANT USAGE ON SCHEMA key_store TO security_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON key_store.crypto_materials TO security_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA key_store TO security_admin;

CREATE OR REPLACE FUNCTION key_store.read_secret(p_filename TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = key_store, public
AS $$
DECLARE
    v_path TEXT;
    v_content TEXT;
BEGIN
    IF p_filename !~ '^[a-z0-9_.-]+$' THEN
        RAISE EXCEPTION 'Недопустимое имя файла секрета: %', p_filename;
    END IF;

    v_path := '/var/lib/postgresql/secrets/' || p_filename;

    BEGIN
        v_content := pg_read_file(v_path);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Секрет не найден: % (проверьте том ./secrets -> /var/lib/postgresql/secrets). %',
                v_path, SQLERRM;
    END;

    IF length(trim(both E'\n\r' from v_content)) = 0 THEN
        RAISE EXCEPTION 'Секрет пуст: %', v_path;
    END IF;

    RETURN trim(both E'\n\r' from v_content);
END;
$$;

CREATE OR REPLACE FUNCTION key_store.get_sym_key()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = key_store, public
AS $$
BEGIN
    IF SESSION_USER <> 'postgres'
       AND NOT pg_has_role(SESSION_USER, 'security_admin', 'member') THEN
        RAISE EXCEPTION 'Недостаточно прав: требуется postgres или security_admin';
    END IF;

    RETURN key_store.read_secret('lr3_sym_key.txt');
END;
$$;

CREATE OR REPLACE FUNCTION key_store.get_pgp_public_key()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = key_store, public
AS $$
BEGIN
    RETURN key_store.read_secret('lr3_pgp_public.asc');
END;
$$;

-- Чтение файлов вне PGDATA доступно только суперпользователю / pg_read_server_files.
ALTER FUNCTION key_store.read_secret(TEXT) OWNER TO postgres;
ALTER FUNCTION key_store.get_sym_key() OWNER TO postgres;
ALTER FUNCTION key_store.get_pgp_public_key() OWNER TO postgres;

REVOKE ALL ON FUNCTION key_store.read_secret(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION key_store.get_sym_key() FROM PUBLIC;
REVOKE ALL ON FUNCTION key_store.get_pgp_public_key() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION key_store.read_secret(TEXT) TO security_admin;
GRANT EXECUTE ON FUNCTION key_store.get_sym_key() TO security_admin;
GRANT EXECUTE ON FUNCTION key_store.get_pgp_public_key() TO security_admin, app_owner;

INSERT INTO key_store.crypto_materials (key_name, key_type, key_value, storage_location)
VALUES
    ('lr3_sym_key', 'metadata', NULL, 'docker-secrets:/var/lib/postgresql/secrets/lr3_sym_key.txt'),
    ('lr3_pgp_public_key', 'metadata', NULL, 'docker-secrets:/var/lib/postgresql/secrets/lr3_pgp_public.asc'),
    ('lr3_master_kek', 'metadata', NULL, 'docker-secrets:/var/lib/postgresql/secrets/lr3_master_kek.txt'),
    ('lr3_pgp_private_key', 'metadata', NULL, 'docker-secrets:/var/lib/postgresql/secrets/lr3_pgp_private.asc')
ON CONFLICT (key_name) DO UPDATE
SET key_type = EXCLUDED.key_type,
    storage_location = EXCLUDED.storage_location,
    key_value = EXCLUDED.key_value;

INSERT INTO key_store.crypto_materials (key_name, key_type, key_value, storage_location)
VALUES (
    'lr3_pgp_private_key_encrypted',
    'pgp_private_encrypted',
    pgp_sym_encrypt(
        key_store.read_secret('lr3_pgp_private.asc'),
        key_store.read_secret('lr3_master_kek.txt')
    ),
    'db:encrypted_blob; kek:docker-secrets/lr3_master_kek.txt'
)
ON CONFLICT (key_name) DO UPDATE
SET key_type = EXCLUDED.key_type,
    key_value = EXCLUDED.key_value,
    storage_location = EXCLUDED.storage_location;

CREATE OR REPLACE FUNCTION key_store.decrypt_studio_bank_details(p_studio_id INTEGER)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = key_store, ref, public
AS $$
DECLARE
    v_private_key TEXT;
    v_private_key_encrypted BYTEA;
    v_bank_details_enc BYTEA;
    v_kek TEXT;
BEGIN
    IF SESSION_USER <> 'postgres'
       AND NOT pg_has_role(SESSION_USER, 'security_admin', 'member') THEN
        RAISE EXCEPTION 'Недостаточно прав для расшифровки: требуется security_admin';
    END IF;

    SELECT key_value
      INTO v_private_key_encrypted
      FROM key_store.crypto_materials
     WHERE key_name = 'lr3_pgp_private_key_encrypted';

    IF v_private_key_encrypted IS NULL THEN
        RAISE EXCEPTION 'Зашифрованный закрытый ключ не найден в key_store.crypto_materials';
    END IF;

    v_kek := key_store.read_secret('lr3_master_kek.txt');
    v_private_key := pgp_sym_decrypt(v_private_key_encrypted, v_kek);

    SELECT s.bank_details_enc
      INTO v_bank_details_enc
      FROM ref.studios s
     WHERE s.studio_id = p_studio_id;

    IF v_bank_details_enc IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN pgp_pub_decrypt(v_bank_details_enc, dearmor(v_private_key));
END;
$$;

CREATE OR REPLACE FUNCTION key_store.decrypt_pgp_ciphertext(p_ciphertext BYTEA)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = key_store, public
AS $$
DECLARE
    v_private_key TEXT;
    v_private_key_encrypted BYTEA;
    v_kek TEXT;
BEGIN
    IF p_ciphertext IS NULL THEN
        RETURN NULL;
    END IF;

    IF SESSION_USER <> 'postgres'
       AND NOT pg_has_role(SESSION_USER, 'security_admin', 'member') THEN
        RAISE EXCEPTION 'Недостаточно прав для расшифровки: требуется security_admin';
    END IF;

    SELECT key_value
      INTO v_private_key_encrypted
      FROM key_store.crypto_materials
     WHERE key_name = 'lr3_pgp_private_key_encrypted';

    v_kek := key_store.read_secret('lr3_master_kek.txt');
    v_private_key := pgp_sym_decrypt(v_private_key_encrypted, v_kek);

    RETURN pgp_pub_decrypt(p_ciphertext, dearmor(v_private_key));
END;
$$;

ALTER FUNCTION key_store.decrypt_studio_bank_details(INTEGER) OWNER TO postgres;
ALTER FUNCTION key_store.decrypt_pgp_ciphertext(BYTEA) OWNER TO postgres;
REVOKE ALL ON FUNCTION key_store.decrypt_studio_bank_details(INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION key_store.decrypt_pgp_ciphertext(BYTEA) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION key_store.decrypt_studio_bank_details(INTEGER) TO security_admin;
GRANT EXECUTE ON FUNCTION key_store.decrypt_pgp_ciphertext(BYTEA) TO security_admin;

\echo '=== Реестр ключей (содержимое секретов не выводится) ==='
SELECT key_name, key_type, storage_location,
       CASE WHEN key_value IS NULL THEN NULL ELSE octet_length(key_value) END AS stored_bytes
FROM key_store.crypto_materials
ORDER BY key_id;

\echo '=== Проверка доступа к Docker secrets (только длины) ==='
SELECT
    octet_length(convert_to(key_store.read_secret('lr3_sym_key.txt'), 'utf8')) AS sym_key_bytes,
    octet_length(convert_to(key_store.read_secret('lr3_pgp_public.asc'), 'utf8')) AS public_key_bytes,
    octet_length(convert_to(key_store.read_secret('lr3_master_kek.txt'), 'utf8')) AS kek_bytes;

\echo '=== Расшифровка ref.studios через защищённую функцию (ключи из secrets) ==='
SELECT
    s.studio_id,
    key_store.decrypt_studio_bank_details(s.studio_id) AS bank_details_decrypted
FROM ref.studios s
WHERE s.bank_details_enc IS NOT NULL
ORDER BY s.studio_id
LIMIT 3;

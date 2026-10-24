-- Задание 2. Шифрование избранных столбцов
-- Таблица 1: app.actors.passport_data -> симметричное PGP-шифрование
-- Таблица 2: ref.studios.bank_details -> PGP-шифрование открытым ключом
-- Ключи загружаются из Docker secrets (см. s2_lr3_03_key_management.sql).

SET search_path TO app, ref, key_store, public;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE app.actors
    ADD COLUMN IF NOT EXISTS passport_data_enc BYTEA;

ALTER TABLE ref.studios
    ADD COLUMN IF NOT EXISTS bank_details_enc BYTEA;

DO $$
DECLARE
    v_sym_key TEXT;
    v_public_key TEXT;
BEGIN
    v_sym_key := key_store.get_sym_key();
    v_public_key := key_store.get_pgp_public_key();

    PERFORM set_config('app.lr3_sym_key', v_sym_key, false);
    PERFORM set_config('app.lr3_public_key', v_public_key, false);
END;
$$;

UPDATE app.actors
SET passport_data = '12 34 567890'
WHERE actor_id = (SELECT MIN(actor_id) FROM app.actors)
  AND COALESCE(passport_data, '') = '';

UPDATE ref.studios
SET bank_details = '40702810000000000001'
WHERE studio_id = (SELECT MIN(studio_id) FROM ref.studios)
  AND COALESCE(bank_details, '') = '';

UPDATE app.actors
SET passport_data_enc = pgp_sym_encrypt(passport_data, current_setting('app.lr3_sym_key'))
WHERE passport_data IS NOT NULL
  AND (passport_data_enc IS NULL OR passport_data_enc IS DISTINCT FROM pgp_sym_encrypt(passport_data, current_setting('app.lr3_sym_key')));

UPDATE ref.studios
SET bank_details_enc = pgp_pub_encrypt(bank_details, dearmor(current_setting('app.lr3_public_key')))
WHERE bank_details IS NOT NULL
  AND (bank_details_enc IS NULL OR bank_details_enc IS DISTINCT FROM pgp_pub_encrypt(bank_details, dearmor(current_setting('app.lr3_public_key'))));

\echo '=== Без ключа: отображаются зашифрованные значения ==='
SELECT actor_id, encode(passport_data_enc, 'hex') AS passport_data_enc_hex
FROM app.actors
WHERE passport_data_enc IS NOT NULL
ORDER BY actor_id
LIMIT 3;

SELECT studio_id, encode(bank_details_enc, 'hex') AS bank_details_enc_hex
FROM ref.studios
WHERE bank_details_enc IS NOT NULL
ORDER BY studio_id
LIMIT 3;

\echo '=== С ключом: расшифровка симметричного PGP (ключ из Docker secrets) ==='
SELECT
    actor_id,
    pgp_sym_decrypt(passport_data_enc, key_store.get_sym_key()) AS passport_data_decrypted
FROM app.actors
WHERE passport_data_enc IS NOT NULL
ORDER BY actor_id
LIMIT 3;

\echo '=== С ключом: расшифровка PGP через security-функцию (закрытый ключ не в SQL-скрипте) ==='
SELECT
    s.studio_id,
    key_store.decrypt_studio_bank_details(s.studio_id) AS bank_details_decrypted
FROM ref.studios s
WHERE s.bank_details_enc IS NOT NULL
ORDER BY s.studio_id
LIMIT 3;
SET search_path TO app, key_store, public;

DO $$
BEGIN
    PERFORM set_config('app.lr3_sym_key', key_store.get_sym_key(), false);
    PERFORM set_config('app.lr3_public_key', key_store.get_pgp_public_key(), false);
END;
$$;

-- Симметричное шифрование

DROP TABLE IF EXISTS app.lr3_perf_sym_plain;
CREATE TABLE app.lr3_perf_sym_plain (
    id BIGSERIAL PRIMARY KEY,
    passport_data TEXT NOT NULL
);

DROP TABLE IF EXISTS app.lr3_perf_sym_enc;
CREATE TABLE app.lr3_perf_sym_enc (
    id BIGSERIAL PRIMARY KEY,
    passport_data_enc BYTEA NOT NULL
);

INSERT INTO app.lr3_perf_sym_plain(passport_data)
SELECT 'PASSPORT-' || lpad(g::text, 8, '0')
FROM generate_series(1, 20000) AS s(g);

INSERT INTO app.lr3_perf_sym_enc(passport_data_enc)
SELECT pgp_sym_encrypt('PASSPORT-' || lpad(g::text, 8, '0'), current_setting('app.lr3_sym_key'))
FROM generate_series(1, 20000) AS s(g);

ANALYZE app.lr3_perf_sym_plain;
ANALYZE app.lr3_perf_sym_enc;

\echo 'симметричный SELECT до шифрования'
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*)
FROM app.lr3_perf_sym_plain
WHERE passport_data LIKE 'PASSPORT-0001%';

\echo 'симметричный SELECT после шифрования'
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*)
FROM app.lr3_perf_sym_enc
WHERE pgp_sym_decrypt(passport_data_enc, current_setting('app.lr3_sym_key')) LIKE 'PASSPORT-0001%';

-- Асимметричное шифрование

DROP TABLE IF EXISTS app.lr3_perf_asym_plain;
CREATE TABLE app.lr3_perf_asym_plain (
    id BIGSERIAL PRIMARY KEY,
    bank_details TEXT NOT NULL
);

DROP TABLE IF EXISTS app.lr3_perf_asym_enc;
CREATE TABLE app.lr3_perf_asym_enc (
    id BIGSERIAL PRIMARY KEY,
    bank_details_enc BYTEA NOT NULL
);

INSERT INTO app.lr3_perf_asym_plain(bank_details)
SELECT '40702810' || lpad(g::text, 12, '0')
FROM generate_series(1, 5000) AS s(g);

INSERT INTO app.lr3_perf_asym_enc(bank_details_enc)
SELECT pgp_pub_encrypt('40702810' || lpad(g::text, 12, '0'), dearmor(current_setting('app.lr3_public_key')))
FROM generate_series(1, 5000) AS s(g);

ANALYZE app.lr3_perf_asym_plain;
ANALYZE app.lr3_perf_asym_enc;

\echo 'асимметричный SELECT до шифрования'
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*)
FROM app.lr3_perf_asym_plain
WHERE bank_details LIKE '4070281000000001%';

\echo 'асимметричный SELECT после шифрования'
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*)
FROM app.lr3_perf_asym_enc e
WHERE key_store.decrypt_pgp_ciphertext(e.bank_details_enc) LIKE '4070281000000001%';

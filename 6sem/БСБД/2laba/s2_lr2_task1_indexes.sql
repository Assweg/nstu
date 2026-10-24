SET search_path TO app, public;

DROP TABLE IF EXISTS app.index_benchmark CASCADE;
CREATE TABLE app.index_benchmark (
    id BIGSERIAL PRIMARY KEY,
    order_code BIGINT NOT NULL,
    customer_email TEXT NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    geolocation POINT NOT NULL,
    description TEXT NOT NULL,
    tags TEXT[] NOT NULL
);

CREATE OR REPLACE FUNCTION app.fill_index_benchmark(p_rows INTEGER DEFAULT 300000)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO app.index_benchmark (order_code, customer_email, amount, created_at, geolocation, description, tags)
    SELECT
        1000000 + g AS order_code,
        'client_' || (g % 50000) || '@mail.local' AS customer_email,
        ROUND((10 + random() * 10000)::numeric, 2) AS amount,
        NOW() - ((p_rows - g) || ' minutes')::interval AS created_at,
        point(
            (random() * 2000 - 1000)::float8,
            (random() * 2000 - 1000)::float8
        ) AS geolocation,
        'Order #' || g || ' for project ' || (g % 900) || ' with payload ' || encode(digest(g::text, 'md5'), 'hex') AS description,
        ARRAY[
            CASE WHEN g % 2 = 0 THEN 'music' ELSE 'voice' END,
            CASE WHEN g % 3 = 0 THEN 'urgent' ELSE 'normal' END,
            'project_' || (g % 100)::text
        ]::text[] AS tags
    FROM generate_series(1, p_rows) AS s(g);
END;
$$;

-- Заполняем таблицу (важно!)
SELECT app.fill_index_benchmark(300000);




-- До индексов
ANALYZE app.index_benchmark;

\echo ' '
\echo 'До индексов'
\echo ' '

\echo 'B-Tree'
EXPLAIN ANALYZE
SELECT *
FROM app.index_benchmark
WHERE customer_email = 'client_12345@mail.local';

\echo 'Hash'
EXPLAIN ANALYZE
SELECT *
FROM app.index_benchmark
WHERE order_code = 1187654;

\echo 'GiST'
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM app.index_benchmark
WHERE geolocation <@ box(point(-50, -50), point(50, 50));

\echo 'SP-GiST'
EXPLAIN ANALYZE
SELECT id, geolocation
FROM app.index_benchmark
ORDER BY geolocation <-> point(0, 0)
LIMIT 20;

\echo 'BRIN'
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM app.index_benchmark
WHERE created_at >= NOW() - INTERVAL '30 minutes';

\echo 'GIN'
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM app.index_benchmark
WHERE tags @> ARRAY['project_42']::text[];



CREATE INDEX IF NOT EXISTS idx_bench_btree_email ON app.index_benchmark USING btree (customer_email);
CREATE INDEX IF NOT EXISTS idx_bench_hash_order_code ON app.index_benchmark USING hash (order_code);
CREATE INDEX IF NOT EXISTS idx_bench_gist_geo ON app.index_benchmark USING gist (geolocation);
CREATE INDEX IF NOT EXISTS idx_bench_spgist_geo ON app.index_benchmark USING spgist (geolocation);
CREATE INDEX IF NOT EXISTS idx_bench_brin_created_at ON app.index_benchmark USING brin (created_at);
CREATE INDEX IF NOT EXISTS idx_bench_gin_tags ON app.index_benchmark USING gin (tags);

-- После индексов
ANALYZE app.index_benchmark;

\echo ' '
\echo 'После индексов'
\echo ' '

\echo 'B-Tree'
EXPLAIN ANALYZE
SELECT *
FROM app.index_benchmark
WHERE customer_email = 'client_12345@mail.local';

\echo 'Hash'
EXPLAIN ANALYZE
SELECT *
FROM app.index_benchmark
WHERE order_code = 1187654;

\echo 'GiST'
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM app.index_benchmark
WHERE geolocation <@ box(point(-50, -50), point(50, 50));

\echo 'SP-GiST'
EXPLAIN ANALYZE
SELECT id, geolocation
FROM app.index_benchmark
ORDER BY geolocation <-> point(0, 0)
LIMIT 20;

\echo 'BRIN'
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM app.index_benchmark
WHERE created_at >= NOW() - INTERVAL '30 minutes';

\echo 'GIN'
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM app.index_benchmark
WHERE tags @> ARRAY['project_42']::text[];
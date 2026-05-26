EXPLAIN;
SET client_min_messages = warning;

DROP TABLE IF EXISTS match_no_partition CASCADE;
DROP TABLE IF EXISTS match_with_partition CASCADE;

SET client_min_messages = notice;

CREATE TABLE match_no_partition (LIKE Match INCLUDING ALL);

CREATE TABLE match_with_partition
(LIKE Match INCLUDING DEFAULTS INCLUDING CONSTRAINTS)
PARTITION BY RANGE (match_date);

CREATE TABLE match_2024 PARTITION OF match_with_partition
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE match_2025 PARTITION OF match_with_partition
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE match_2026 PARTITION OF match_with_partition
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE match_other PARTITION OF match_with_partition DEFAULT;

INSERT INTO match_no_partition SELECT * FROM Match;
INSERT INTO match_with_partition SELECT * FROM Match;

ANALYZE match_no_partition;
ANALYZE match_with_partition;

SELECT 'rows_by_partition' AS section;

SELECT tableoid::regclass AS partition_name, COUNT(*) AS row_count
FROM match_with_partition
GROUP BY tableoid::regclass
ORDER BY partition_name;

SELECT 'regular_table_filter_by_match_date' AS section;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM match_no_partition
WHERE match_date BETWEEN '2025-01-01' AND '2025-12-31';

SELECT 'partitioned_table_filter_by_match_date' AS section;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM match_with_partition
WHERE match_date BETWEEN '2025-01-01' AND '2025-12-31';

SELECT 'regular_table_filter_by_club' AS section;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM match_no_partition
WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'Spartak' LIMIT 1);

SELECT 'partitioned_table_filter_by_club' AS section;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM match_with_partition
WHERE club1_id = (SELECT club_id FROM Club WHERE name = 'Spartak' LIMIT 1);

SELECT 'partitioned_table_update_partition_key' AS section;

EXPLAIN ANALYZE
UPDATE match_with_partition
SET match_date = match_date + INTERVAL '1 year'
WHERE match_date < '2026-01-01';

SELECT 'regular_table_update_match_date' AS section;

EXPLAIN ANALYZE
UPDATE match_no_partition
SET match_date = match_date + INTERVAL '1 year'
WHERE match_date < '2026-01-01';

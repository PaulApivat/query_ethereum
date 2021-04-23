/* Isolate multiple time units */
/* note: Minutes & Seconds are identical */

/* ethereum."blocks" */
SELECT 
    DATE_TRUNC('hour', time) AS hour,
    DATE_TRUNC('minute', time) AS minute,
    DATE_TRUNC('second', time) AS second,
    DATE_TRUNC('day', time) AS day,
    DATE_TRUNC('month', time) AS month,
    DATE_TRUNC('year', time) AS year
FROM ethereum."blocks"
LIMIT 10

/* ethereum."transactions" */
SELECT 
    DATE_TRUNC('hour', block_time) AS hour,
    DATE_TRUNC('minute', block_time) AS minute,
    DATE_TRUNC('second', block_time) AS second,
    DATE_TRUNC('day', block_time) AS day,
    DATE_TRUNC('month', block_time) AS month,
    DATE_TRUNC('year', block_time) AS year
FROM ethereum."transactions"
LIMIT 10

/* ether-queries hashrate.sql from YazzyYaz */
/* Google BigQuery */
/* source: https://github.com/YazzyYaz/Ether-Queries/blob/master/hashrate.sql */
WITH block_rows AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY timestamp) AS rn
  FROM `bigquery-public-data.crypto_ethereum_classic.blocks`
)
SELECT mp.timestamp AS block_time, 
TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) AS time_elapsed,
((mp.difficulty + mc.difficulty) / 2) AS average_difficulty,
((mp.difficulty + mc.difficulty) / 2) / TIMESTAMP_DIFF(mp.timestamp, mc.timestamp, SECOND) AS hashrate
FROM block_rows mc
JOIN block_rows mp
ON  mc.rn = mp.rn - 1
ORDER BY block_time ASC



/* Ether-queries hashrate.sql  */
WITH block_rows AS (
  SELECT *, ROW_NUMBER() OVER (ORDER BY time) AS rn
  FROM ethereum."blocks"
)
SELECT 
mp.time AS block_time, 
mp.time - mc.time AS time_elapsed,
((mp.difficulty + mc.difficulty) / 2) AS average_difficulty
FROM block_rows mc
JOIN block_rows mp
ON  mc.rn = mp.rn - 1
ORDER BY block_time ASC
LIMIT 10
OFFSET 1

/* better formatting */
WITH block_rows AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY time) AS rn
    FROM ethereum."blocks"
) 
    SELECT mp.time AS block_time, 
    mp.time - mc.time AS time_elapsed,
    ((mp.difficulty + mc.difficulty) / 2) AS average_difficulty
    FROM block_rows mc
    JOIN block_rows mp
    ON  mc.rn = mp.rn - 1
    ORDER BY block_time ASC
    LIMIT 10
    OFFSET 1


/* Successfully calculate Hashrate */
WITH block_rows AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY time) AS rn
    FROM ethereum."blocks"
),
temp_table AS (
    SELECT mp.time AS block_time, 
    mp.time - mc.time AS time_elapsed,
    ((mp.difficulty + mc.difficulty) / 2) AS average_difficulty
    FROM block_rows mc
    JOIN block_rows mp
    ON  mc.rn = mp.rn - 1
    ORDER BY block_time ASC
    LIMIT 10
    OFFSET 1
)
SELECT
    block_time,
    time_elapsed,
    average_difficulty,
    average_difficulty / extract('second' FROM time_elapsed::interval)::numeric(9,2) AS hashrate
FROM temp_table t
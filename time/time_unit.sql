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
/* Blocks, standard data */

/* Timestamp & (Block) Size */

/* Avg Block Size per Day Over Time */
/* note: unsure if block size is in bytes */
SELECT 
DATE_TRUNC('day', time) AS dt,
AVG(size) AS avg_block_size
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1


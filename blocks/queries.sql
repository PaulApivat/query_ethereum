/************************** Blocks, standard data ***************************/

/* Timestamp & (Block) Size */
/* - use DATE_TRUNC('day', time) to make sense of Timestamp */ 
/* - use COUNT(*) for Block Count and Rewards */
/* - need distinguish between Block Size and Size of Data within the Block */
/* - number of transaction included within the block is found in ethereum."transaction" table */

/* Avg Block Size per Day Over Time */
/* note: unsure if block size is in bytes */
SELECT 
DATE_TRUNC('day', time) AS dt,
AVG(size) AS avg_block_size
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Sum Block Size per Day Over Time */ 
/* note: unsure if block size is in bytes */
/* looks more like Ethereum Block Count & Rewards Chart in Etherscan; https://etherscan.io/chart/blocks */
SELECT 
DATE_TRUNC('day', time) AS dt,
SUM(size) AS sum_block_size
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Ethereum Block Count and Rewards Chart */
/* Add https://duneanalytics.com/paulapivat/Ethereum-Blocks */
/* Etherscan comparison:  https://etherscan.io/chart/blocks */
SELECT 
    DATE_TRUNC('day', time) AS dt,
    COUNT(*) AS block_count
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Question: Is 'size' in ethereum."blocks" measured in bytes? */
/* Size visualization does not match etherscan chart */
/* Etherscan Ethereum Avg Block Size Chart: https://etherscan.io/chart/blocksize */

/* Number of transaction included within the block; see ethereum."transactions" */

/* Miner: Address of miner who mined the block */
SELECT miner FROM ethereum."blocks"
LIMIT 10
OFFSET 1

/* Number of Unique Miner per day Over time */
/* not sure if useful */
SELECT 
DATE_TRUNC('day', time) AS dt,
COUNT(DISTINCT(miner)) AS count_unique_miner
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Top 25 Miners by Number of Blocks Mined */
/* MATCHES Etherscan: Top 25 Miners over last 7 days */
/* source: https://etherscan.io/stat/miner?range=7&blocktype=blocks */
/* Missing % of total column */

SELECT 
DISTINCT(miner) AS unique_miner,
COUNT(*) AS num_blocks_mined
FROM ethereum."blocks"
WHERE time > now() - interval '7 days'
GROUP BY unique_miner
ORDER BY num_blocks_mined DESC
LIMIT 25

/* With % of total column */
SELECT 
DISTINCT(miner) AS unique_miner,
COUNT(*) AS num_blocks_mined,
(COUNT(*) / (SUM(COUNT(*)) OVER() )) * 100 AS percent_total
FROM ethereum."blocks"
WHERE time > now() - interval '7 days'
GROUP BY unique_miner
ORDER BY num_blocks_mined DESC
LIMIT 25




/* Number of blocks that Ethermine (mining pool) mined */
/* TOTAL Blocks Mined by Ethermine: 2409771, Date: 21/4/2021 */
SELECT 
COUNT(*) 
FROM ethereum."blocks"
WHERE miner = '\xea674fdde714fd979de3edf0f56aa9716b898ec8'
LIMIT 25

/* Ethereum Network Difficulty Chart */
/* Average Difficulty per day over time */
/* MATCHES Etherscan chart: https://etherscan.io/chart/difficulty */
/* Difficulty is measured in TeraHashes - TH source: https://2miners.com/blog/mining-difficulty-and-network-hashrate-explained/  */
SELECT 
AVG(difficulty) AS average_difficulty,
DATE_TRUNC('day', time) AS dt
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Ethereum Daily Gas Used Chart */
/* Total Gas Used per day Over Time */
/* MATCHES Etherscan chart: https://etherscan.io/chart/gasused */
/* proper metric is gas / tx */
SELECT 
SUM(gas_used) AS total_gas_used,
DATE_TRUNC('day', time) AS dt
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Ethereum Average Gas Limit Chart */
/* Average Daily Gas Limit Over Time */
/* MATCHES Etherscan: https://etherscan.io/chart/gaslimit  */
SELECT 
AVG(gas_limit) AS avg_gas_limit,
DATE_TRUNC('day', time) AS dt
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/************************** Blocks, advanced data ***************************/
/* Hashrate query building off from YazzyYaz */
/* source: https://github.com/YazzyYaz/Ether-Queries/blob/master/hashrate.sql */

/* Hash and Hash Rate are not the same */

/* Hash Rate is Hash Per Second */
/* Count Number of Hash, Group by Time (seconds) */
/* Need to convert to Day */
SELECT 
COUNT(hash) AS count_hash,
DATE_TRUNC('second', time) AS st
FROM ethereum."blocks"
GROUP BY st
LIMIT 10
OFFSET 1

SELECT 
COUNT(hash) AS num_hash,
DATE_TRUNC('day', block_time) AS dt
FROM ethereum."transactions"
GROUP BY dt
LIMIT 5
OFFSET 1

/* Ethereum Network HASHRATE */
/* NOTE: This works for LIMITED queries, but eventually run in to "Error: Division by zero." */
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

/* Ethereum Hashrate by Day */ 
WITH block_rows AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY time) AS rn
    FROM ethereum."blocks"
),
delta_time AS (
    SELECT
        mp.time AS block_time,
        mp.difficulty AS difficulty,
        (mp.time - mc.time) AS delta_block_time
    FROM block_rows mc
    JOIN block_rows mp
    ON mc.rn = mp.rn - 1
),
hashrate_book AS (
    SELECT 
        DATE_TRUNC('day', block_time) AS block_day,
        AVG(delta_block_time) AS daily_avg_block_time,
        AVG(difficulty) AS daily_avg_difficulty
        FROM delta_time
        GROUP BY block_day
)
SELECT 
    block_day,
    (daily_avg_difficulty / extract('second' FROM daily_avg_block_time::interval)::numeric(9,2))/1000000000 AS hashrate
FROM hashrate_book
ORDER BY block_day ASC





/************************** Transaction, standard data ***************************/

/* Number of Daily Transaction over Time */
/* MATCHES Etherscan: Ethereum Daily Transactions Chart; source: https://etherscan.io/chart/tx */ 
SELECT 
DATE_TRUNC('day', block_time) AS dt,
COUNT(*) AS transaction_count
FROM ethereum."transactions"
GROUP BY dt
OFFSET 1
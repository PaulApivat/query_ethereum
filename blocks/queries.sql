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

/* Ethereum Block Count Per Day Over Time */
/* Matches Etherscan */
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
/* Not Match Ether Scan, except for largest Miner at 22.5% */
/* confirm miner address of Spark Pool as largest miner on Etherscan */
/* Spark Pool Address: 0x5A0b54D5dc17e0AadC383d2db43B0a0D3E029c4c */
/* 2nd Largest miner from query is Nanopool Address: 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5 */
/* (but Etherscan has Ethermine as second largest pool) */
/* view % in Chart Options */
SELECT 
DISTINCT(miner) AS unique_miner,
COUNT(*) AS num_blocks_mined
FROM ethereum."blocks"
GROUP BY unique_miner
ORDER BY num_blocks_mined DESC
LIMIT 25
OFFSET 1



/************************** Transaction, standard data ***************************/

/* Number of Daily Transaction over Time */
/* Matches Etherscan: Ethereum Daily Transactions Chart; source: https://etherscan.io/chart/tx */ 
SELECT 
DATE_TRUNC('day', block_time) AS dt,
COUNT(*) AS transaction_count
FROM ethereum."transactions"
GROUP BY dt
OFFSET 1
/************************** Blocks, standard data ***************************/

/* Timestamp & (Block) Size */
/* - use DATE_TRUNC('day', time) to make sense of Timestamp */ 
/* - use COUNT(*) for Block Count and Rewards */
/* - need distinguish between Block Size and Size of Data within the Block */
/* - number of transaction included within the block is found in ethereum."transaction" table */

/* Average Gas Limit (Block Size), Ethereum */
/* Etherscan comparison: https://etherscan.io/chart/gaslimit */
/* Block size 20-30 kb in size */
SELECT 
    DATE_TRUNC('day', time) AS dt,
    AVG(gas_limit) AS avg_block_gas_limit
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Not to be confused with Avg Transaction Gas Limit */
/* source: https://ethgasstation.info/blog/ethereum-block-size/ */
SELECT 
    DATE_TRUNC('day', block_time) AS bt,
    AVG(gas_limit) AS avg_transaction_gas_limit
FROM ethereum."transactions"
GROUP BY bt
OFFSET 1

/* Ethereum Daily Gas Used Chart */
/* Etherscan comparison: https://etherscan.io/chart/gasused */
SELECT 
    DATE_TRUNC('day', time) AS dt,
    AVG(gas_used) AS avg_block_gas_used
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
/* Block size measured in Kilobytes */
/* source: https://ethgasstation.info/blog/ethereum-block-size/ */



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

/*********** What's In a Block ? ************/
/* reference: https://ethereum.org/en/developers/docs/blocks/ */
/* missing: transaction list and state root */
SELECT 
    time,
    number,
    ROW_NUMBER() OVER (ORDER BY time) AS rn,
    difficulty,
    total_difficulty,
    hash,
    parent_hash,
    nonce,
    size,
    gas_limit
FROM ethereum."blocks"
LIMIT 10


/* Block Rewards Daily by Miners */
SELECT 
    miner,
    DATE_TRUNC('day', time) AS dt,
    COUNT(miner) AS total_block_reward
FROM ethereum."blocks"
GROUP BY miner, dt
HAVING COUNT(miner) > 1

/* Blocks Per Second */
WITH temp_table AS (
    SELECT
        COUNT(*) AS num_blocks,
        DATE_TRUNC('day', time) AS dt
    FROM ethereum."blocks" b
    GROUP BY dt
    LIMIT 10
)
SELECT
    num_blocks::numeric(9,2) / 86400 AS blocks_sec,
    dt
FROM temp_table

/******************** Table Join: Blocks & Transactions ************************/
/* Error: Your query took too long to execute */
SELECT 
    b.time,
    t.block_hash
FROM ethereum."blocks" b
JOIN ethereum."transactions" t 
ON b.hash = t.hash
LIMIT 5


SELECT 
    DATE_TRUNC('minute', time) AS dt
FROM ethereum."blocks" b
WHERE time = '2015-08-11 10:03' 
LIMIT 50



/**************************** Foundational Topics on Ethereum Blocks**************************/

/* Linked List */
SELECT 
    time,
    hash,
    parent_hash
FROM ethereum."blocks"
LIMIT 10
OFFSET 1

/* Linked List - updated data from last 7 days */
SELECT 
    time,
    hash,
    parent_hash
FROM ethereum."blocks"
WHERE time > now() - interval '7 days'
LIMIT 10
OFFSET 1


/* Number of Blocks in a Day */
SELECT 
    COUNT(*),
    DATE_TRUNC('day', time) AS dt
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* confirm ethereum."blocks".hash = ethereum."transactions".block_hash */
/* Blocks */
SELECT 
    time,
    hash,
    parent_hash
FROM ethereum."blocks"
WHERE time > '2015-08-07 08:50'
LIMIT 100

/* Transaction */
SELECT
    block_time,
    block_hash,
    hash
FROM ethereum."transactions"
LIMIT 10

/* Block Gas Limit over time */
SELECT 
    DATE_TRUNC('day', time) AS dt,
    AVG(gas_limit) AS avg_gas_limit
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Block Gas Limit vs Block Gas used */
SELECT 
    DATE_TRUNC('day', time) AS dt,
    AVG(gas_limit) AS avg_gas_limit,
    AVG(gas_used) AS avg_gas_used
FROM ethereum."blocks"
GROUP BY dt
OFFSET 1

/* Number of Blocks and corresponding number of transaction over past 7-days */
SELECT
    COUNT(*) AS number_of_transactions,
    COUNT(DISTINCT(block_number)) AS number_of_blocks
FROM ethereum."transactions"
WHERE block_time > now() - interval '7 days'

/* Number of Transactions for a specific block in the past 1 day */
SELECT
    COUNT(*) AS num_transactions
FROM ethereum."transactions"
WHERE block_time > now() - interval '1 day' AND block_hash = '\xb8b1984f2a26da40201bad9eaf1e898eaefb0eec0945b4451e1efacb159e5b76'

/* Query on a specific day in 2018 */
SELECT
    block_time,
    block_hash,
    hash
FROM ethereum."transactions" 
WHERE block_time > '2018-08-07'
LIMIT 100

/* Query a specific block on a specific day in 2018 */
SELECT
    COUNT(*) AS num_transactions
FROM ethereum."transactions" 
WHERE block_hash = '\xd93fdbd1f14f6e6ac48fbe02c829253d584f816dce733e2b0c131b4c7556abb3'AND block_time > '2018-08-07'


/* Locate my txn hash of ENS domain on Etherscan */
SELECT
    block_time,
    hash,
    "from",
    "to"
FROM ethereum."transactions" 
WHERE hash = '\xdb23119668fcc774d24db9ed1a2b1701438ffe94824a9e52506f9f98f5d57b77'
LIMIT 10

/* Dune Analytics */
/* Number of Txn sent from Specific Account */
/* can link to specific block */
SELECT
    block_time,
    block_hash,
    block_number,
    hash,
    "from",
    "to"
FROM ethereum."transactions" 
WHERE "from" = '\xdfdf2d882d9ebce6c7eac3da9ab66cbfda263781'
LIMIT 50

/* Same query - num txn from specific account -  on BigQuery */
SELECT  
    block_timestamp,
    block_hash,
    block_number,
    "hash",
    from_address,
    to_address
FROM `bigquery-public-data.crypto_ethereum.transactions` 
WHERE from_address = "0xdfdf2d882d9ebce6c7eac3da9ab66cbfda263781"
LIMIT 50

/******************** ACCOUNT *************************/
/******* Account State contains: nonce, balance, storage hash, code hash *******/
/******* source: https://ethereum.org/en/developers/docs/accounts/    */
/* block_hash != storage hash */
/* hash != code hash */

SELECT 
    nonce,
    value / 1e18 AS balance,
    "from",
    block_time,
    block_number,
    block_hash,
    hash
FROM ethereum."transactions"
WHERE "from" = '\xdfdf2d882d9ebce6c7eac3da9ab66cbfda263781'
LIMIT 50

/********************* TRANSACTION **********************/
SELECT 
    nonce,
    block_time,
    value / 1e18 AS balance_eth,
    "from",
    "to",
    gas_limit,
    gas_price / 1e9 AS gwei,
    data
FROM ethereum."transactions"
WHERE "from" = '\xdfdf2d882d9ebce6c7eac3da9ab66cbfda263781'
LIMIT 50

/* PRICE of ETH in last 7 days */
SELECT 
    DATE_TRUNC('day', minute) AS dt,
    AVG(price) AS avg_price
FROM prices."layer1_usd"
WHERE symbol = 'ETH' AND minute > now() - interval '7 days'
GROUP BY dt
LIMIT 10

/************************** Transaction, standard data ***************************/

/* Number of Daily Transaction over Time */
/* MATCHES Etherscan: Ethereum Daily Transactions Chart; source: https://etherscan.io/chart/tx */ 
SELECT 
DATE_TRUNC('day', block_time) AS dt,
COUNT(*) AS transaction_count
FROM ethereum."transactions"
GROUP BY dt
OFFSET 1


/* Avg Transaction Gas Limit */
/* NOT to be confused with Block Gas Limit */
/* source: https://ethgasstation.info/blog/ethereum-block-size/ */
SELECT 
    DATE_TRUNC('day', block_time) AS bt,
    AVG(gas_limit) AS avg_transaction_gas_limit
FROM ethereum."transactions"
GROUP BY bt
OFFSET 1
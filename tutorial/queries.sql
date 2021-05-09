/* Ethereum Foundation contract query -- through transactions */
/* Recreating view on Etherscan */
/* latest block: 12396854 */
WITH temp_table AS (
SELECT 
    hash,
    block_number,
    block_time,
    "from",
    "to",
    value / 1e18 AS ether,
    gas_used,
    gas_price / 1e9 AS gas_price_gwei
FROM ethereum."transactions"
WHERE "to" = '\xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe'
ORDER BY block_time DESC
)
SELECT
    hash,
    block_number,
    block_time,
    "from",
    "to",
    ether,
    (gas_used * gas_price_gwei) / 1e9 AS txn_fee
FROM temp_table



/* filter for a specific block */
SELECT * FROM ethereum."blocks"
WHERE "number" = 12396854
LIMIT 10


/* Ethereum Transaction Details */
SELECT 
    "to",
    "from",
    value / 1e18 AS ether,
    data,
    gas_limit,
    gas_price / 1e9 AS gas_price_gwei,
    gas_used,
    ROUND(((gas_used / gas_limit) * 100),2) AS gas_used_pct
FROM ethereum."transactions"
WHERE "to" = '\xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe'   
ORDER BY block_time DESC

/* Query a block for list of all transactions */
SELECT * FROM ethereum."transactions"
WHERE block_number = 12401622
ORDER BY block_time DESC
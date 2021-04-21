# query_ethereum

A project to create a tutorial for querying Ethereum with SQL using [Dune Analytics](https://duneanalytics.com/). In the process, a dashboard for the Dune community will be created.

## Motivation

## Code & Resources Used

- Query Ethereum with SQL by Sascha Gobel from AnyBlock Analytics [blog](https://www.anyblockanalytics.com/blog/query-ethereum-with-sql/)

- Block explorers: Etherscan, Blockscout, Etherchain, Ethplorer, Blockchair

## Documenting Progress

4/12/2021

- Set-up project structure, gather resources.

- Starting Point: [ethereum.org Block-Explorers](https://ethereum.org/en/developers/docs/data-and-analytics/block-explorers/)

- AnyBlock Analytics [post](https://www.anyblockanalytics.com/blog/query-ethereum-with-sql/)
  • Things to note:
  • Data model for Ethereum SQL index
  • SQL tables and data sources
  • [AnyBlock SQL Documentation](https://www.anyblockanalytics.com/docs/sql/schema/)
  • [Google Spreadsheet: Data Model for Ethereum SQL Index](https://docs.google.com/spreadsheets/d/1ehCIQxjSZcVLnddDWHBzhPb8h83mHWZxvyX9eckghbU/edit?usp=sharing)

4/21/2021

- Create queries for ethereum."blocks", covering block size, timestamp, miner addresses, network difficulty, daily gas limit and use.
- Next step: Hash Rate, parent hash and nonce
- Create Queries for Transactions

## Key Metrics from the Block Explorer

- Starting Point: [ethereum.org Block-Explorers](https://ethereum.org/en/developers/docs/data-and-analytics/block-explorers/), things to query within Dune

**note**: Focus on current Ethereum chain, not Eth2 (date: 12/4/2021)

**Blocks, standard data**

- Block height ?
- Timestamp: time at which a miner mined the block.
- Transactions: The number of transactions included within the block. ( COUNT(\*) in ethereum."transactions")
- Miner: Address of the miner who mined the block.
- Reward ?
- Difficulty: The difficulty associated with mining the block.
- Size: The size of the data within the block (measured in bytes). ?? (block size vs size of data within block)
- Gas used: The total units of gas used by the transactions in the block.
- Gas limit: The total gas limits set by the transactions in the block.
- Extra data ?

**Blocks, advanced data**

- Hash: The cryptographic hash that represents the block header (the unique identifier of the block). (Hash and Hash Rate are not the same) ??
- Parent hash: The hash of hte block that came before the current block.
- Sha3Uncles ?
- StateRoot ?
- Nonce: A value used to demonstrate proof-of-work for a block by the miner.

**Uncle blocks ?**
**Gas ?**

**Transactions, standard data**

- Transaction hash: A hash generated when the transaction is submitted.
- Status: An indication of whether the transaction is pending, failed or a success (see: ethereum."transactions" success (bool))
- Block: The block in which the transaction has been included. (ethereum."blocks" number, ethereum."transactions" block_number?)
- Timestamp: The time at which a miner mined the transaction (see: block_time?)
- From: The address of the account that submitted the transaction.
- To: The address of the recipient or smart contract that the transaction interacts with.
- Tokens transferred ?
- Value: The total ETH value being transferred.
- Transaction fee ?

**Transactions, advanced data**

- Gas limit: The maximum numbers of gas units this transaction can consume.
- Gas used: The actual amount of gas units the transaction consumed.
- Gas price: The price set per gas unit.
- Nonce: The transaction number for the `from` address (starts at 0 so a nonce of 100 would actually be the 101st transaction submitted by this account)
- Input data: Any extra information required by the transaction (see: data?)

**Accounts, user ?**

**Accounts, smart contracts**

- Contract creator ?
- Creation transaction ?
- Source code ?
- Contract ABI: The Application Binary Interface of the contract - the calls the contract makes and data received (see: abi?)
- Contract creation code ?
- Contract events ?

**Tokens (see specific Tokens)**

**Network**

- Difficulty: The current mining difficulty (see: ethereum."blocks" difficulty?)
- Hash rate ?
- Total transactions ?
- Transactions per second ?
- ETH price ?
- Total ETH Supply ?
- Market cap ?

- For later:
- Blocks, advanced data

#### Available Ethereum Tables in Dune Analytics

1. **Blocks**: difficulty*, gas_limit*, gas_used*, hash*, miner*, nonce*, number*, parent_hash*, size*, time*, total_difficulty
2. **Contracts**: abi*, address, base, code*, created_at, dynamic, name, namespace, updated_at
3. **Logs**: block_hash, block_number, block_time, contract_address, data, index, topic1, topic2, topic3, topic4, tx_hash, tx_index
4. **Signatures**: abi, id, signature
5. **Traces**: address, block_hash, block_number, block_time, call_type, code, error, from, gas, gas_used, input, output, refund_address, sub_traces, success, to, trace_address, tx_hash, tx_index, tx_success, type, value
6. **Transactions**: block_hash, block_number\*, block_time*, data*, from*, gas_limit*, gas_price*, gas_used*, hash*, index, nonce*, success*, to*, value\*

## Key SQL Queries

## Tutorial

#### Querying Ethereum with SQL on Dune Analytics

-

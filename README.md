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
-

## Key Metrics from the Block Explorer

- Starting Point: [ethereum.org Block-Explorers](https://ethereum.org/en/developers/docs/data-and-analytics/block-explorers/), things to query within Dune

**note**: Focus on current Ethereum chain, not Eth2 (date: 12/4/2021)

**Blocks, standard data**

- Block height?
- Timestamp: time at which a miner mined the block.
- Transactions: The number of transactions included within the block. (ethereum."blocks" number, ethereum."transactions" block_number?)
- Miner: Address of the miner who mined the block.
- Reward ?
- Difficulty: The difficulty associated with mining the block.
- Size: The size of the data within the block (measured in bytes).
- Gas used: The total units of gas used by the transactions in the block.
- Gas limit: The total gas limits set by the transactions in the block.
- Extra data ?

**Blocks, advanced data**

- Hash: The cryptographic hash that represents the block header (the unique identifier of the block).

- Uncle blocks
- Gas
- Transactions, standard data
- Accounts, user
- Accounts, smart contracts
- Tokens
- Network

- For later:
- Blocks, advanced data
- Transactions, advanced data

#### Available Ethereum Tables in Dune Analytics

1. **Blocks**: difficulty*, gas_limit*, gas_used*, hash*, miner*, nonce, number*, parent_hash, size*, time*, total_difficulty
2. **Contracts**: abi, address, base, code, created_at, dynamic, name, namespace, updated_at
3. **Logs**: block_hash, block_number, block_time, contract_address, data, index, topic1, topic2, topic3, topic4, tx_hash, tx_index
4. **Signatures**: abi, id, signature
5. **Traces**: address, block_hash, block_number, block_time, call_type, code, error, from, gas, gas_used, input, output, refund_address, sub_traces, success, to, trace_address, tx_hash, tx_index, tx_success, type, value
6. **Transactions**: block_hash, block_number\*, block_time, data, from, gas_limit, gas_price, gas_used, hash, index, nonce, success, to, value

## Key SQL Queries

## Tutorial

#### Querying Ethereum with SQL on Dune Analytics

-

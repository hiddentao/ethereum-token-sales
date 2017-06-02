This repository is a collection of various possible Solidity token sale
contracts, following on from [community](https://www.reddit.com/r/ethereum/comments/6emfdu/erc_fairer_token_crowdsale_with_proportional/) [discussions](https://www.reddit.com/r/ethereum/comments/6eqkip/since_everyone_is_sharing_token_sale_ideas_heres/).

## Available models:

* [ProportionalAllocationToken.sol](contracts/ProportionalAllocationToken.sol)
  * Fixed duration sale with specific start and end blocks.
  * Fixed amount of ETH that *must* be raised in order sale to be successful.
  * Tokens allocated proportionately to each sender according to amount of
ETH contributed as a fraction of the total amount of ETH contributed by all senders.
  * Only the target level of ETH is retained, thus a sender's unretained ETH is
returned to them.
  * Senders must make two transactions - one to contribute ETH, and one to claim
tokens and/or refund once the sale is complete.
  * _Good_:
    * No network congestion because no rush to invest.
    * All senders get a chance to invest.
    * Fixed/predictable tokens-per-ETH price.
  * _Bad_:
    * Whales can still virtually "squash" out smaller investors by massively outspending them ([read discussion](https://www.reddit.com/r/ethereum/comments/6emfdu/erc_fairer_token_crowdsale_with_proportional/dibjwhf/)).

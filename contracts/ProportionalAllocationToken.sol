pragma solidity ^0.4.10;

import "./StandardToken.sol";
import "./SafeMath.sol";


contract SaleToken is StandardToken, SafeMath {

    // metadata
    string public name = 'SaleToken';
    string public symbol = 'SALETOKEN';
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // important addresses
    address public depositAddress;      // deposit address for ETH for ICO owner

    // crowdsale params
    bool public isFinalized;            // true when ICO finalized and successful
    uint256 public targetEth;           // target ETH to raise
    uint256 public fundingStartBlock;   // when to start allowing funding
    uint256 public fundingEndBlock;     // when to stop allowing funding

    // events
    event CreateFairToken(string _name);
    event Contribute(address _sender, uint256 _value);
    event FinalizeSale(address _sender);
    event RefundContribution(address _sender, uint256 _value);
    event ClaimTokens(address _sender, uint256 _value);

    // calculated values
    mapping (address => uint256) contributions;    // ETH contributed per address
    uint256 contributed;      // total ETH contributed

    // constructor
    function FairToken(
        uint256 _totalSupply,
        uint256 _minEth,
        address _depositAddress,
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock)
    {
        isFinalized = false;
        totalSupply = _totalSupply * 10**decimals;
        targetEth = _minEth;
        depositAddress = _depositAddress;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        // log
        CreateFairToken(name);
    }

    /// Accepts ETH from a contributor
    function contribute() payable external {
        if (block.number < fundingStartBlock) throw;    // not yet begun?
        if (block.number > fundingEndBlock) throw;      // already ended?
        if (msg.value == 0) throw;                  // no ETH sent in?

        // Add to contributions
        contributions[msg.sender] += msg.value;
        contributed += msg.value;

        // log
        Contribute(msg.sender, msg.value);  // logs contribution
    }

    /// Finalizes the funding and sends the ETH to deposit address
    function finalizeFunding() external {
        if (isFinalized) throw;                       // already succeeded?
        if (msg.sender != depositAddress) throw;      // wrong sender?
        if (block.number <= fundingEndBlock) throw;   // not yet finished?
        if (contributed < targetEth) throw;             // not enough raised?

        isFinalized = true;

        // send to deposit address
        if (!depositAddress.send(targetEth)) throw;

        // log
        FinalizeSale(msg.sender);
    }

    /// Allows contributors to claim their tokens and/or a refund. If funding failed then they get back all their Ether, otherwise they get back any excess Ether
    function claimTokensAndRefund() external {
        if (0 == contributions[msg.sender]) throw;    // must have previously contributed
        if (block.number < fundingEndBlock) throw;    // not yet done?

        // if not enough funding
        if (contributed < targetEth) {
            // refund my full contribution
            if (!msg.sender.send(contributions[msg.sender])) throw;
            RefundContribution(msg.sender, contributions[msg.sender]);
        } else {
            // calculate how many tokens I get
            balances[msg.sender] = safeMult(totalSupply, contributions[msg.sender]) / contributed;
            // refund excess ETH
            if (!msg.sender.send(contributions[msg.sender] - (safeMult(targetEth, contributions[msg.sender]) / contributed))) throw;
            ClaimTokens(msg.sender, balances[msg.sender]);
      }

      contributions[msg.sender] = 0;
    }
}

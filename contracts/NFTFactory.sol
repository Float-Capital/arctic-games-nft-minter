// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.3;

import "./NFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract NFTFactory is Ownable {
    address[] public nfts;
    event NFTDeployed(address indexed nft, uint256 nftCount);

    constructor() Ownable() {}

    function deployNFT(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address admin,
        address saleFeeRecipient,
        uint256 maxTokenAmount,
        uint256 salesFeeBPS
    ) public onlyOwner returns (address nft) {
        nft = address(
            new NFT(
                name,
                symbol,
                baseURI,
                admin,
                saleFeeRecipient,
                maxTokenAmount,
                salesFeeBPS
            )
        );
        nfts.push(nft);
        emit NFTDeployed(nft, nfts.length);
    }
}

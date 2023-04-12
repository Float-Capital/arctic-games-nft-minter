// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./abstract/HasSecondarySaleFees.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";

contract NFT is Ownable, HasSecondarySaleFees, ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public baseURI;

    address public saleFeesRecipient;

    uint256 public defaultSecondarySalePercentage;

    uint256 public constant basisPointsDenominator = 10000;

    uint256 maxTokenAmount;

    event UpdateSaleFeesRecipient(address saleFeesRecipient);

    constructor(
        string memory name,
        string memory symbol,
        string memory _baseUri,
        address _admin,
        address _saleFeesRecipient,
        uint256 _maxTokenAmount,
        uint256 _salesFeeBPS
    ) ERC721(name, symbol) Ownable() HasSecondarySaleFees() {
        transferOwnership(_admin);
        baseURI = _baseUri;
        saleFeesRecipient = _saleFeesRecipient;
        defaultSecondarySalePercentage = _salesFeeBPS; // 10000 Bps
        maxTokenAmount = _maxTokenAmount;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mint(address receiver) public onlyOwner returns (uint256) {
        //will increment one last time
        require(_tokenIds.current() < maxTokenAmount, "Max No. NFTS minted");
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(receiver, newItemId);

        return newItemId;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return string(abi.encodePacked(ERC721.tokenURI(tokenId), ""));
    }

    ////////////////////////////////////
    /// Secondary Fees implementation //
    ////////////////////////////////////

    function getFeeRecipients(
        uint256 id
    ) public view override returns (address payable[] memory) {
        address payable[] memory feeRecipients = new address payable[](1);
        feeRecipients[0] = payable(saleFeesRecipient);

        return feeRecipients;
    }

    function getFeeBps(
        uint256 id
    ) public view override returns (uint256[] memory) {
        uint256[] memory fees = new uint256[](1);
        fees[0] = defaultSecondarySalePercentage;

        return fees;
    }

    ////////////////////////////////////
    //////// ADMIN FUNCTIONS ///////////
    ////////////////////////////////////

    function setFeeRecipient(address _saleFeesRecipient) external onlyOwner {
        saleFeesRecipient = _saleFeesRecipient;
        emit UpdateSaleFeesRecipient(_saleFeesRecipient);
    }

    function changeDefaultSecondarySalePercentage(
        uint256 _basisPoints
    ) external onlyOwner {
        require(_basisPoints <= basisPointsDenominator);
        defaultSecondarySalePercentage = _basisPoints;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC165Storage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

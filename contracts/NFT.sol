// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./abstract/HasSecondarySaleFees.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";

/**
 * https://github.com/maticnetwork/pos-portal/blob/master/contracts/common/ContextMixin.sol
 */
abstract contract ContextMixin {
    function msgSender() internal view returns (address payable sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}

contract NFT is Ownable, HasSecondarySaleFees, ERC721, ContextMixin {
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

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(ERC721.tokenURI(tokenId), ""));
    }

    ////////////////////////////////////
    /// Opensea Compability functions //
    ////////////////////////////////////
    ///////////////See below for more details///////////////////
    ///https://docs.opensea.io/docs/polygon-basic-integration///
    ////////////////////////////////////////////////////////////
    /**
     * Override isApprovedForAll to auto-approve OS's proxy contract on Polygon
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721.isApprovedForAll(_owner, _operator);
    }

    //override _msgSender for gas-less transactions on polygon
    function _msgSender() internal view override returns (address sender) {
        return ContextMixin.msgSender();
    }

    ////////////////////////////////////
    /// Secondary Fees implementation //
    ////////////////////////////////////

    function getFeeRecipients(uint256 id)
        public
        view
        override
        returns (address payable[] memory)
    {
        address payable[] memory feeRecipients = new address payable[](1);
        feeRecipients[0] = payable(saleFeesRecipient);

        return feeRecipients;
    }

    function getFeeBps(uint256 id)
        public
        view
        override
        returns (uint256[] memory)
    {
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

    function changeDefaultSecondarySalePercentage(uint256 _basisPoints)
        external
        onlyOwner
    {
        require(_basisPoints <= basisPointsDenominator);
        defaultSecondarySalePercentage = _basisPoints;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC165Storage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { IERC721Receiver } from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import { getInvestorProposal } from "./getInvestorProposal.sol";

contract CollateralizedAuction is ERC721 {
    error NotOwner();
    
    struct CollateralDetails {
        uint256 collateralId;
        uint256 collateralValue;
        address collateralOwner;
        bool isApproved;
    }

    struct AuctionItem {
        uint256 itemId;
        string itemName;
        uint256 itemValue;
        address itemOwner;
        uint256 auctionDuration;
        bool onAuction;
        uint256 collateralId; // ID of the associated collateral
    }

    address owner;
    uint256 itemId;
    uint256 collateralId;
    
    mapping(uint256 => AuctionItem) public auctionItems;
    mapping(uint256 => CollateralDetails) public collateralDetails;

    event ItemListedForAuction(
        address indexed owner,
        uint256 indexed itemId,
        string itemName,
        uint256 itemValue,
        uint256 auctionDuration,
        uint256 collateralId
    );

    event AuctionContractCreated(
        address indexed owner,
        uint256 indexed itemId,
        address indexed auctionContract
    );

    constructor() ERC721("CollateralizedNFT", "CNFT") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert NotOwner();
        }
        _;
    }

    function mintNFT(address _to, uint256 _tokenId) internal returns (bool) {
        _safeMint(_to, _tokenId);
        return true;
    }

    function createAuction(
        string memory _itemName,
        uint256 _itemValue,
        uint256 _auctionDuration,
        uint256 _collateralValue,
        bool _isApproved
    ) external onlyOwner returns (address) {
        itemId++;
        collateralId++;
        
        // Mint an NFT for the auction item
        mintNFT(msg.sender, itemId);

        // Create a new auction item
        AuctionItem storage newItem = auctionItems[itemId];
        newItem.itemId = itemId;
        newItem.itemName = _itemName;
        newItem.itemValue = _itemValue;
        newItem.itemOwner = msg.sender;
        newItem.auctionDuration = _auctionDuration;
        newItem.onAuction = true;
        newItem.collateralId = collateralId;

        // Create a new collateral
        CollateralDetails storage newCollateral = collateralDetails[collateralId];
        newCollateral.collateralId = collateralId;
        newCollateral.collateralValue = _collateralValue;
        newCollateral.collateralOwner = msg.sender;
        newCollateral.isApproved = _isApproved;

        emit ItemListedForAuction(msg.sender, itemId, _itemName, _itemValue, _auctionDuration, collateralId);

        getInvestorProposal proposalContract = new getInvestorProposal(
            itemId,
            _itemName,
            _itemValue,
            _auctionDuration,
            collateralId
        );

        emit AuctionContractCreated(msg.sender, itemId, address(proposalContract));

        return address(proposalContract);
    }
}

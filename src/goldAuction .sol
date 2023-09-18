//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {getInvestorProposal} from "./getInvestorProposal.sol";


// ██████╗  █████╗  ██████╗███████╗
// ██╔══██╗██╔══██╗██╔════╝██╔════╝
// ██████╔╝███████║██║     █████╗  
// ██╔══██╗██╔══██║██║     ██╔══╝  
// ██║  ██║██║  ██║╚██████╗███████╗
// ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝
                                
/**
 * @title AuctionWatch
 * @author Abhijay Paliwal
 * The contract is designed for auction of an item on the platform.
 
 * The DIC would provide details of an item after all due-diligence by proposer and custodian.
 
 * The contract will serves as an gateway to mint auction contract where investors would place their proposals
 
 * Function would mint ERC-721 NFT of the item to the borrower when function setItemForAuction is called
 * @notice the contract has only one function and can only be called by admin (DIC)
 */

contract watchAuction is ERC721 {

    error watchAuction__NotOwner();

    struct goldDetails {
        uint256 goldId;
        uint256 goldPrice;
        uint256 askingPrice;
        uint256 borrowDuration;
        uint256 auctionDuration;
        string goldType;
        bool isApproved;
        bool onAuction;
        address borrower;
       // address investorProposalContract;
    }

    ///////////////////////
      //State Variable //
    //////////////////////

    address owner;
    uint256 goldId;
    goldDetails details;

    mapping(uint256 => goldDetails) public goldIdToGoldDetails;

    //////////////////
      //Events //
    /////////////////

        event ItemListedForAuction(
        address indexed owner,
        uint256 indexed watchNumber,
        string watchName,
        uint256 watchPrice,
        uint256 askingPrice,
        uint256 borrowDuration,
        uint256 auctionDuration
    );

    event AuctionContractCreated(
        address indexed owner,
        uint256 indexed watchNumber,
        address indexed auctionContract
    );

    constructor() ERC721("Gold", "GLD") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
    if (owner != msg.sender) {
        revert watchAuction__NotOwner();
    }
    _;
}

    ////////////////////
       // Functions //
    ////////////////////

    function mintNFT(address _to, uint256 _tokenId) internal returns (bool) {
        _safeMint(_to, _tokenId);
        return true;
    }


    /*
     * @param _watchname: Name of the item
     * @param _watchPrice: price of item on market (decided by DIC)
     * @param _askingPrice: asking price of item by borrower (decided by DIC)
     * @param _isApproved: boolean for approval by the DIC for item
     * @param _borrower: EOA address of the borrower
     * @param _auctionDuration: duration of auction
     * @notice The function would mint smart contract getInvestorProposal which would be unique for every item
     * @notice The function would mint ERC721 NFT to the borrower
     * @notice function can only be called by the owner
     * @returns THe contract address of the getInvestorProposal contract
     */

    function setItemForAuction(
        string memory _watchName,
        uint256 _watchPrice,
        uint256 _askingPrice,
        uint256 _borrowDuration,
        bool _isApproved,
        address _borrower,
        uint256 _auctionDuration
    ) external onlyOwner returns (address) {
        goldId++;
        details.goldId= goldId;
        details.goldType = _watchName;
        details.goldPrice = _watchPrice;
        details.askingPrice = _askingPrice;
        details.isApproved = _isApproved;
        details.onAuction = true;
        details.borrower = _borrower;
        details.borrowDuration = _borrowDuration;
        details.auctionDuration = _auctionDuration;
        mintNFT(msg.sender, goldId);
        emit ItemListedForAuction(
            msg.sender,
            goldId,
            _watchName,
            _watchPrice,
            _askingPrice,
            _borrowDuration,
            _auctionDuration
        );

        getInvestorProposal getProposal = new getInvestorProposal(
            goldId,
            _watchName,
            _watchPrice,
            _askingPrice,
            _borrowDuration,
            _isApproved,
            true,
            _borrower,
            _auctionDuration
        );
       // details.investorProposalContract = address(getProposal);
        goldIdToGoldDetails[goldId] = details;
        emit AuctionContractCreated(msg.sender, goldId, address(getProposal));
        return address(getProposal);
       
    }
}

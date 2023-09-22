//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {getInvestorProposal} from "./getInvestorProposal.sol";
//import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";



contract DICinitiateItemProposal is ERC721 {

    error DICinitiateItemProposal__NotDIC();

    struct ItemDetails {
        uint256 itemId;
        uint256 itemEstimatedValue;
        uint256 minLoanAmountRange;
        uint256 maxLoanAmountRange;
        uint256 minLoanDurantionRange;
        uint256 maxLoanDurationRange; 
        uint256 loanPeriod;
        //uint256 manufactureYear; 
        string itemBrandName;
        //bool isApproved;
        bool onAuction;
        address borrower;
       // address investorProposalContract;
    }

    ///////////////////////
      //State Variable //
    ////////////////////// 

    address owner;
    uint256 itemId;
    ItemDetails details;

    mapping(uint256 itemId=> ItemDetails) public s_itemIdToItemDetails;

    //////////////////
      //Events //
    /////////////////

    //     event ItemListedForAuction(
    //     uint256 indexed itemId,
    //     uint256 itemEstimatedValue,
    //     uint256 loanPeriod,
    //     string itemBrandName,
    //     address indexed owner
    // );

    // event AuctionContractCreated(
    //     address indexed owner,
    //     uint256 indexed watchNumber,
    //     address indexed auctionContract
    // );

     modifier onlyDIC(){
        if(msg.sender != owner){
            revert DICinitiateItemProposal__NotDIC();
        }
        _;
    }

    constructor() ERC721("AuctionNFT", "NFT") {
       
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
        
        uint256 _itemEstimatedValue,
        uint256 _minLoanAmountRange,
        uint256 _maxLoanAmountRange,
        uint256 _minLoanDurationRange,
        uint256 _maxLoanDurationRange,
        uint256 _loanPeriod,
        string memory _itemBrandName,
        address _borrower
    ) external onlyDIC returns (address) {
        itemId++;
        details.itemId= itemId;
        details.itemEstimatedValue = _itemEstimatedValue;
        details.minLoanAmountRange = _minLoanAmountRange;
        details.maxLoanAmountRange = _maxLoanAmountRange;
        details.minLoanDurantionRange =_minLoanDurationRange;
        details.maxLoanDurationRange =_maxLoanDurationRange;
        details.loanPeriod =_loanPeriod;
        details.itemBrandName = _itemBrandName;
        details.borrower = _borrower;
        
        mintNFT(msg.sender, itemId);
        // emit ItemListedForAuction(
        //     itemId,
        //     _itemEstimatedValue,
        //     _loanPeriod,
        //     _itemBrandName,
        //     msg.sender
        // );

        getInvestorProposal getProposal = new getInvestorProposal(
             
             _itemEstimatedValue,
             _minLoanAmountRange,
             _maxLoanAmountRange,
             _minLoanDurationRange,
             _maxLoanDurationRange,
            _loanPeriod,
            _itemBrandName,
            _borrower

            
        );
        s_itemIdToItemDetails[itemId] = details;
       
        //emit AuctionContractCreated(msg.sender, itemId, address(getProposal));
        return address(getProposal);
       
    }
  
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {Test, console} from "forge-std/Test.sol";
import "../src/watchAuction.sol";

contract auctionTest is Test {
    watchAuction auctionContract;

    function setUp() external {
        vm.prank(address(1));
        auctionContract = new watchAuction();
    }

    function testAuction() external {
        vm.startPrank(address(1));
        address getInvestorProposalAddr = auctionContract.setItemForAuction(
            "Rolex Watch",
            1500000000000000000,
            1500000000000000000,
            12,
            true,
            address(1),
            1694601478
        );

        console.log(getInvestorProposalAddr);
        vm.warp(1694601477);
        vm.deal(address(1), 100 ether);
        getInvestorProposal(payable(getInvestorProposalAddr)).getProposals{
            value: 1000000000000000000
        }(6);
        vm.stopPrank();
        vm.deal(address(2), 100 ether);
        vm.prank(address(2));
        getInvestorProposal(payable(getInvestorProposalAddr)).getProposals{
            value: 500000000000000000
        }(10);
        vm.deal(address(3), 100 ether);
        vm.prank(address(3));
        getInvestorProposal(payable(getInvestorProposalAddr)).getProposals{
            value: 500000000000000000
        }(10);
        vm.deal(address(4), 100 ether);
        vm.prank(address(4));
        getInvestorProposal(payable(getInvestorProposalAddr)).getProposals{
            value: 500000000000000000
        }(10);

        vm.warp(1694601479);
        vm.prank(address(1));
        getInvestorProposal(getInvestorProposalAddr).approveProposal(3);
        vm.prank(address(1));
        getInvestorProposal(getInvestorProposalAddr).approveProposal(2);
        vm.prank(address(1));
        getInvestorProposal(getInvestorProposalAddr).approveProposal(4);
        vm.prank(address(1));
        getInvestorProposal(getInvestorProposalAddr).borrowerClaimFunds(3);
        vm.prank(address(2));
        getInvestorProposal(getInvestorProposalAddr).investorClaimDebtToken(2);
        vm.prank(address(3));
        getInvestorProposal(getInvestorProposalAddr).investorClaimDebtToken(3);
        vm.prank(address(4));
        getInvestorProposal(getInvestorProposalAddr).investorClaimDebtToken(4);
        vm.warp(1697231200);
        vm.startPrank(address(1));
        console.log(msg.sender.balance);
        console.log(address(2).balance);
        console.log(address(3).balance);
        getInvestorProposal(getInvestorProposalAddr).transferFunds{
            value: 500000000000000000
        }();
        console.log(msg.sender.balance);
        console.log(address(2).balance);
        console.log(address(3).balance);

        // @dev testcade for penalty of 5 days
        vm.warp(1697231200 + 40 days);
        console.log("address 1 balance before", msg.sender.balance);
        console.log("address 2 balance before", address(2).balance);
        console.log("address 3 balance before", address(3).balance);
        getInvestorProposal(getInvestorProposalAddr).transferFunds{
            value: 500000000000000000
        }();
        console.log("address 1 balance after", msg.sender.balance);
        console.log("address 2 balance after", address(2).balance);
        console.log("address 3 balance after", address(3).balance);
        vm.stopPrank();
    }

    // function testEMI() external {
    //     console.log(emi.calculate_EMI());

    // }
}

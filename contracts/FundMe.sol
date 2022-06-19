// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

// Pragma
pragma solidity ^0.8.0;
// Imports
import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// Error Codes
error FundMe_NotOwner();

// Interfaces, Libraries, Contracts

contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State Variables!
    // uint256 public minimumUsd = 0.1 * 1e18;
    uint256 public constant minimumUsd = 0.1 * 1e18;
    // 将变量设置为常数之后不会再占用储存，并且节省gas！

    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunded;

    // address public owner;
    address public immutable i_owner;

    //将变量设置为immutable之后不可更改，节约gas

    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _;
    }

    //constructor构造函数，在合约部署时同步执行
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        // minimum USD
        // 1.How do we send ETH to this contract?
        require(
            msg.value.getConversionRate(s_priceFeed) > minimumUsd,
            "Didn't send enough!"
        ); // 1e18 == 1 * 10 ** 18
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // actually withdraw the funds

        // // transfer （2300gas max, throw err）
        // payable(msg.sender).transfer(address(this).balance);
        // // send  (2300gas max, return false)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // // call，最适用的方式
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    // Explainer from: https://solidity-by-example.org/fallback
    // Ether is sent to contract
    //     is msg.data empty?
    //         /   \
    //       yes   no
    //       /       \
    // receive()?    fallback()
    //     /   \
    //    yes   no
    //   /       \
    // receive()  fallback()
}

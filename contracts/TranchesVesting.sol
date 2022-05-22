//SPDX-License-Identifier:MIT
pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

error TranchesVesting__TransactionFailed();

contract TranchesVesting {
    address owner;
    IERC20 immutable TranchesV;
    uint256 deployDate;

    address[] private investors;
    mapping(address => uint256) private investorToLastWithdrawl;
    mapping(address => uint256) private investorToX;

    //Investor
    address payable investor1;
    uint256 x1;

    constructor() {
        owner = msg.sender;
        TranchesV = IERC20(0x16ECCfDbb4eE1A85A33f3A9B21175Cd7Ae753dB4); //ROUTE Address
        deployDate = block.timestamp;

        //init the investor1
        investors.push(investor1);
        investorToLastWithdrawl[investor1] = block.timestamp;
        investorToX[investor1] = x1;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only Owner of this contract can call this function"
        );
        _;
    }

    function whoIsOwner() public view returns (address) {
        return owner;
    }

    //Owner can add investor on his behalf
    function addInvestor(address _investor) public payable onlyOwner {
        investors.push(_investor);
        investorToLastWithdrawl[_investor] = block.timestamp;
        investorToX[msg.sender] = msg.value;
    }

    function claimTokens() public returns (bool) {
        uint256 lastWithdrawl = investorToLastWithdrawl[msg.sender];
        require(
            investorToX[msg.sender] > 0 &&
                block.timestamp >= lastWithdrawl + 24 weeks,
            "You are not and investor OR you can claim your tokens only in interval of 6 months"
        );

        address payable user = payable(msg.sender);

        bool done = TranchesV.transfer(user, investorToX[msg.sender] / 4);
        investorToLastWithdrawl[msg.sender] = lastWithdrawl + 24 weeks;

        if (!done) {
            revert TranchesVesting__TransactionFailed();
        }

        return done;
    }

    //Getter functions
    function getAllInvestors()
        public
        view
        onlyOwner
        returns (address[] memory)
    {
        return investors;
    }

    function getAllInvestorsAndTheirX() public view onlyOwner {
        for (uint256 i = 0; i < investors.length; i++) {
            console.log(investors[i], investorToX[investors[i]]);
        }
    }
}

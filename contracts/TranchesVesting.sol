//SPDX-License-Identifier:MIT
pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract TranchesVesting {
    address owner;
    IERC20 immutable TranchesV;
    uint256 deployDate;

    address[] private investors;
    mapping(address => uint256) private investorToLastWithdrawl;
    mapping(address => uint256) private investorToX;

    constructor(
        address payable _investor1,
        uint256 _x1,
        address payable _investor2,
        uint256 _x2
    ) {
        owner = msg.sender;
        TranchesV = IERC20(0x16ECCfDbb4eE1A85A33f3A9B21175Cd7Ae753dB4);
        deployDate = block.timestamp;

        //Init the two first investors.
        investors.push(_investor1);
        investors.push(_investor2);
        investorToLastWithdrawl[_investor1] = block.timestamp;
        investorToLastWithdrawl[_investor2] = block.timestamp;
        investorToX[_investor1] = _x1;
        investorToX[_investor2] = _x2;
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
        investorToLastWithdrawl[_investor] = block.timestamp;
        investorToX[msg.sender] = msg.value;
    }

    function claimTokens() public {
        uint256 lastWithdrawl = investorToLastWithdrawl[msg.sender];
        require(
            block.timestamp >= lastWithdrawl + 24 weeks,
            "You can claim your tokens only in interval of 6 months"
        );
        address payable sender = payable(msg.sender);
        TranchesV.transfer(sender, investorToX[msg.sender] / 4);
        investorToLastWithdrawl[msg.sender] = lastWithdrawl + 24 weeks;
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

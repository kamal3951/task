//SPDX-License-Identifier:MIT
pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract LinearVesting {
    address owner;
    IERC20 immutable TranchesL;
    uint256 deployDate;

    constructor() {
        owner = msg.sender;
        TranchesL = IERC20(0x16ECCfDbb4eE1A85A33f3A9B21175Cd7Ae753dB4);
        deployDate = block.timestamp;
    }

    struct Investor {
        address payable investor;
        uint256 totalAmount;
        uint256 startingDate;
        uint256 totalTimeForVesting;
        uint256 lastWithdrawl;
    }

    mapping(address => Investor) addressToInvestor;

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

    //Owner can add investor on behalf of the investor
    function addInvestor(address payable _investor, uint256 _totalVestingTime)
        public
        payable
        onlyOwner
    {
        Investor memory _Investor = Investor(
            _investor,
            msg.value,
            block.timestamp,
            _totalVestingTime,
            block.timestamp
        );

        addressToInvestor[_investor] = _Investor;
    }

    function claimTokens() public {
        require(
            addressToInvestor[msg.sender].investor == msg.sender,
            "You're not a investor"
        );
        address payable sender = payable(msg.sender);
        uint256 claimableTokens = (block.timestamp -
            addressToInvestor[msg.sender].lastWithdrawl) /
            addressToInvestor[msg.sender].totalTimeForVesting;

        TranchesL.transfer(sender, claimableTokens);

        addressToInvestor[sender].lastWithdrawl = block.timestamp;
    }
}

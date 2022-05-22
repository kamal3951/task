//SPDX-License-Identifier:MIT
pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract LinearVesting {
    address owner;
    IERC20 immutable LinearV;
    uint256 deployDate;

    struct Investor {
        address payable investor;
        uint256 totalAmount;
        uint256 startingDate;
        uint256 totalTimeForVesting;
        uint256 lastWithdrawl;
    }

    mapping(address => Investor) addressToInvestor;

    //investor
    address payable _investor1;
    uint256 _x1;
    uint256 _totalTimeForVesting1;

    constructor() {
        owner = msg.sender;
        LinearV = IERC20(0x16ECCfDbb4eE1A85A33f3A9B21175Cd7Ae753dB4); //ROUTE Address
        deployDate = block.timestamp;

        Investor memory Investor1 = Investor(
            _investor1,
            _x1,
            block.timestamp,
            _totalTimeForVesting1,
            block.timestamp
        );

        addressToInvestor[_investor1] = Investor1;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only Owner of this contract can call this function"
        );
        _;
    }

    event investorAdded(address payable investor);

    event tokensClaimed(address investor);

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

        emit investorAdded(_investor);
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

        LinearV.transfer(sender, claimableTokens);

        addressToInvestor[sender].lastWithdrawl = block.timestamp;

        emit tokensClaimed(msg.sender);
    }
}

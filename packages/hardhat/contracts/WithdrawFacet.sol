// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";

import "./WithStorage.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

contract WithdrawFacet is WithStorage, UsingDiamondOwner {
    using SafeTransferLib for address;
    
    function withdraw() external onlyOwner {
        s().withdrawAddress.safeTransferETH(address(this).balance);
    }
}

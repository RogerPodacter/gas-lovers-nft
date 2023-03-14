// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {UsingDiamondOwner} from "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

contract WithdrawFacet is UsingDiamondOwner {
    using SafeTransferLib for address;
    
    function withdraw() external onlyOwner {
        address middleMarch = 0xC2172a6315c1D7f6855768F843c420EbB36eDa97;
        middleMarch.safeTransferETH(address(this).balance);
    }
}

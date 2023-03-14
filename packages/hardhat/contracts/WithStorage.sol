// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import {LibDiamond} from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

struct GasLoverStorage {
    uint maxSupply;
    bool isInitialized;
    uint[] tokenIdToPackedInfo;
}

contract WithStorage {
    function s() internal pure returns (GasLoverStorage storage cs) {
        bytes32 position = keccak256("gas.lovers.nft.contract.storage");
        assembly {
           cs.slot := position
        }
    }
    
    function ds() internal pure returns (LibDiamond.DiamondStorage storage) {
        return LibDiamond.diamondStorage();
    }
}

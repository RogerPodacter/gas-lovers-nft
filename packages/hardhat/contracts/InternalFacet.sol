// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";

import "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";
import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

import { ERC721DInternal } from "./ERC721D/ERC721DInternal.sol";

struct ContractStorage {
    uint[] tokenIdToPackedInfo;
    uint24 maxSupply;
    bool mintActive;
    address withdrawAddress;
    uint mintCost;
    string externalLink;
    uint16 nextTokenId;
    bool isInitialized;
}

contract InternalFacet is ERC721DInternal, UsingDiamondOwner {
    function s() internal pure returns (ContractStorage storage cs) {
        bytes32 position = keccak256("gas.nft.storage.poster");
        assembly {
           cs.slot := position
        }
    }
    
    function ds() internal pure returns (LibDiamond.DiamondStorage storage) {
        return LibDiamond.diamondStorage();
    }
}

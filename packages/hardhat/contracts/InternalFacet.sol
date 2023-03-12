// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";

import "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat-deploy/solc_0.8/diamond/interfaces/IDiamondLoupe.sol";

import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

import { IERC173 } from "hardhat-deploy/solc_0.8/diamond/interfaces/IERC173.sol";

import { ERC721DInternal } from "./ERC721D/ERC721DInternal.sol";

import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import {LibBitmap} from "solady/src/utils/LibBitmap.sol";

struct ContractStorage {
    bool contractInitialized;
    uint[] tokenIdToPackedInfo;
    uint24 maxSupply;
    bool mintActive;
    address withdrawAddress;
    uint mintCost;
    string externalLink;
    uint16 nextTokenId;
    bool isInitialized;
    mapping(uint => address) tokenIdToCreator;
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

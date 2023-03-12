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

import {OperatorFilterer} from "closedsea/src/OperatorFilterer.sol";

import {ERC2981} from "@solidstate/contracts/token/common/ERC2981/ERC2981.sol";
import {IERC2981} from "@solidstate/contracts/interfaces/IERC2981.sol";

import {ERC2981Storage} from "@solidstate/contracts/token/common/ERC2981/ERC2981Storage.sol";

import "@solidstate/contracts/token/ERC721/metadata/IERC721Metadata.sol";
import {AccessControlInternal} from "@solidstate/contracts/access/access_control/AccessControlInternal.sol";

import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

import {LibBitmap} from "solady/src/utils/LibBitmap.sol";

struct ContractStorage {
    bool contractInitialized;
    uint[] tokenIdToPriorityFee;
    uint16 maxSupply;
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

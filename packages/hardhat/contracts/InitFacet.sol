// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat-deploy/solc_0.8/diamond/interfaces/IDiamondLoupe.sol";
import {IERC173} from "hardhat-deploy/solc_0.8/diamond/interfaces/IERC173.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";
import { ERC721AUpgradeableInternal } from "./ERC721AUpgradeable/ERC721AUpgradeableInternal.sol";
import { ERC721AStorage } from "./ERC721AUpgradeable/ERC721AStorage.sol";
import "./WithStorage.sol";

contract InitFacet is ERC721AUpgradeableInternal, UsingDiamondOwner, WithStorage {
    using ERC721AStorage for ERC721AStorage.Layout;
    
    function init() external onlyOwner {
        if (s().isInitialized) return;
        
        ERC721AStorage.layout()._name = "Gas Lovers";
        ERC721AStorage.layout()._symbol = "GASLOVE";
        
        s().maxSupply = 10_000;
        
        s().withdrawAddress = 0xC2172a6315c1D7f6855768F843c420EbB36eDa97;
        
        ds().supportedInterfaces[type(IERC165).interfaceId] = true;
        ds().supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds().supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds().supportedInterfaces[type(IERC173).interfaceId] = true;
        
        ds().supportedInterfaces[type(IERC721).interfaceId] = true;
        ds().supportedInterfaces[type(IERC721Metadata).interfaceId] = true;
        
        s().isInitialized = true;
    }
}

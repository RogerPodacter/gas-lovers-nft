// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat-deploy/solc_0.8/diamond/interfaces/IDiamondLoupe.sol";

import {IERC173} from "hardhat-deploy/solc_0.8/diamond/interfaces/IERC173.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import "./InternalFacet.sol";

contract InitFacet is InternalFacet {
    function init() external onlyOwner {
        if (s().isInitialized) return;
        
        _setName("Gas Lovers");
        _setSymbol("GASLOVE");
        
        s().mintActive = true;
        s().mintCost = 0;
        s().maxSupply = 100_000;
        
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

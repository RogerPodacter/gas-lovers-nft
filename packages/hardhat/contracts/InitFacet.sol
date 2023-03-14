// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IDiamondLoupe} from "hardhat-deploy/solc_0.8/diamond/interfaces/IDiamondLoupe.sol";
import {IERC173} from "hardhat-deploy/solc_0.8/diamond/interfaces/IERC173.sol";
import {IERC165, IERC721, IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {UsingDiamondOwner, IDiamondCut} from "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";
import {ERC721AStorage} from "./ERC721AUpgradeable/ERC721AStorage.sol";
import {GasLoverStorage, WithStorage} from "./WithStorage.sol";

contract InitFacet is UsingDiamondOwner, WithStorage {
    function a() internal pure returns (ERC721AStorage.Layout storage) {
        return ERC721AStorage.layout();
    }
    
    function init() external onlyOwner {
        if (s().isInitialized) return;
        
        a()._name = "Gas Lovers";
        a()._symbol = "GASLOVE";
        
        s().maxSupply = 10_000;
        
        ds().supportedInterfaces[type(IERC165).interfaceId] = true;
        ds().supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds().supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds().supportedInterfaces[type(IERC173).interfaceId] = true;
        ds().supportedInterfaces[type(IERC721).interfaceId] = true;
        ds().supportedInterfaces[type(IERC721Metadata).interfaceId] = true;
        
        s().isInitialized = true;
    }
}

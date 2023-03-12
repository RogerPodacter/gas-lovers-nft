// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "solady/src/utils/LibPRNG.sol";
import "solady/src/utils/DynamicBufferLib.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";
import "solady/src/utils/LibSort.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import { ERC721D } from "./ERC721D/ERC721D.sol";

import "./InternalFacet.sol";
import "solady/src/utils/SafeTransferLib.sol";


contract MintFacet is InternalFacet {
    using SafeTransferLib for address;
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    
    function mint() external payable {
        require(msg.value == s().mintCost, "Incorrect amount of ETH sent.");
        require(s().mintActive, "Minting needs to be enabled to start minting");
        
        uint priorityFee = tx.gasprice - block.basefee;
        
        require(priorityFee >= 1 gwei, "Priority fee must be at least 1 gwei.");
        
        // require the exact priority fee has not been done?
        
        uint tokenId = s().nextTokenId;
        
        require(tokenId < s().maxSupply, "Exceeds max supply.");
        
        _mint(msg.sender, tokenId);
        
        s().tokenIdToPriorityFee.push(priorityFee);
         
        emit BatchMetadataUpdate(0, tokenId);
        
        unchecked {++s().nextTokenId;}
        
        s().tokenIdToCreator[tokenId] = msg.sender;
        
        console.log(
            tx.gasprice,
            block.basefee
        );
    }
    
    function withdraw() external onlyOwner {
        s().withdrawAddress.forceSafeTransferETH(address(this).balance);
    }
}

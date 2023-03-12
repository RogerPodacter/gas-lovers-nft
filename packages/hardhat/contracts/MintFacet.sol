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
        uint tokenId = s().nextTokenId;

        require(msg.value == s().mintCost, "Incorrect amount of ETH sent.");
        require(s().mintActive, "Minting needs to be enabled to start minting");
        require(tx.gasprice <= type(uint64).max, "Gas price too high.");
        require(block.timestamp <= type(uint32).max, "Too far in future");
        require(tokenId < s().maxSupply, "Exceeds max supply.");
        
        _mint(msg.sender, tokenId);
        
        uint packed = packTokenInfo(tx.gasprice, block.timestamp, msg.sender);
        s().tokenIdToPackedInfo.push(packed);
        
        if (tokenId != 0) emit BatchMetadataUpdate(0, tokenId - 1);
        
        unchecked {++s().nextTokenId;}
    }
    
    function packTokenInfo(uint gasPrice, uint timestamp, address creator) public pure returns (uint) {
        uint packedGasPrice = uint256(uint64(gasPrice)) << 192;
        uint packedTimestamp = uint256(uint32(timestamp)) << 160;
        uint packedCreator = uint256(uint160(creator));
        
        return packedGasPrice | packedTimestamp | packedCreator;
    }
    
    function totalSupply() external view returns (uint) {
        return s().nextTokenId;
    }
    
    function withdraw() external onlyOwner {
        s().withdrawAddress.forceSafeTransferETH(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import { ERC721AUpgradeableInternal } from "./ERC721AUpgradeable/ERC721AUpgradeableInternal.sol";

import "./WithStorage.sol";
import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

contract MintFacet is ERC721AUpgradeableInternal, WithStorage {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    
    function mint() external {
        uint tokenId = _nextTokenId();

        require(tx.gasprice <= type(uint64).max, "Gas price too high.");
        require(block.timestamp <= type(uint32).max, "Too far in future");
        require(tokenId < s().maxSupply, "Exceeds max supply.");
        require(block.chainid == 31337 || _numberMinted(msg.sender) < 1, "One per wallet");
        require(msg.sender == tx.origin, "No contracts");
        
        _mint(msg.sender, 1);
        
        uint packed = packTokenInfo(tx.gasprice, block.timestamp, msg.sender);
        s().tokenIdToPackedInfo.push(packed);
        
        if (tokenId != 0) emit BatchMetadataUpdate(0, tokenId - 1);
    }
    
    function packTokenInfo(uint gasPrice, uint timestamp, address creator) internal pure returns (uint) {
        uint packedGasPrice = uint256(uint64(gasPrice)) << 192;
        uint packedTimestamp = uint256(uint32(timestamp)) << 160;
        uint packedCreator = uint256(uint160(creator));
        
        return packedGasPrice | packedTimestamp | packedCreator;
    }

    
    function maxSupply() external view returns (uint) {
        return s().maxSupply;
    }
}

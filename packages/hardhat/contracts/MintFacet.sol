// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721AUpgradeableInternal} from "./ERC721AUpgradeable/ERC721AUpgradeableInternal.sol";
import {GasLoverStorage, WithStorage} from "./WithStorage.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

contract MintFacet is ERC721AUpgradeableInternal, WithStorage {
    using SafeCastLib for *;
    
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    
    function mint() external {
        GasLoverStorage storage gs = s();
        
        uint tokenId = _nextTokenId();

        require(tokenId < gs.maxSupply, "Exceeds max supply");
        require(msg.sender == tx.origin, "Contract cannot mint");
        
        _mint(msg.sender, 1);
        
        uint packed = packTokenInfo(tx.gasprice, block.timestamp, msg.sender);
        gs.tokenIdToPackedInfo.push(packed);
        
        if (tokenId != 0) emit BatchMetadataUpdate(0, tokenId - 1);
    }
    
    function packTokenInfo(uint gasPrice, uint timestamp, address creator) internal pure returns (uint) {
        uint packedGasPrice = uint256(gasPrice.toUint64()) << 192;
        uint packedTimestamp = uint256(timestamp.toUint32()) << 160;
        uint packedCreator = uint256(uint160(creator));
        
        return packedGasPrice | packedTimestamp | packedCreator;
    }
}

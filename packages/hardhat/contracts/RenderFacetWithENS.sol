// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "solady/src/utils/LibPRNG.sol";
import "solady/src/utils/DynamicBufferLib.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";
import "solady/src/utils/LibSort.sol";
import "solady/src/utils/SSTORE2.sol";
import { ERC721AUpgradeableInternal } from "./ERC721AUpgradeable/ERC721AUpgradeableInternal.sol";

import "./WithStorage.sol";

import '@ensdomains/ens-contracts/contracts/registry/ENS.sol';
import '@ensdomains/ens-contracts/contracts/registry/ReverseRegistrar.sol';
import '@ensdomains/ens-contracts/contracts/resolvers/Resolver.sol';

import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

contract RenderFacetWithENS is ERC721AUpgradeableInternal, WithStorage, UsingDiamondOwner {
    using LibSort for uint[];
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;
    using LibString for *;
    
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    
    function addressToEthName(address addr) internal view returns (string memory) {
        address reverseResolverAddress = block.chainid == 5 ?
            0xD5610A08E370051a01fdfe4bB3ddf5270af1aA48 :
            0x084b1c3C81545d370f3634392De611CaaBFf8148;
        
        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        ReverseRegistrar reverseResolver = ReverseRegistrar(reverseResolverAddress);
        
        bytes32 node = reverseResolver.node(addr);
        address resolverAddr = ens.resolver(node);
        
        if (resolverAddr == address(0)) return addr.toHexStringChecksumed();
        
        string memory name = Resolver(resolverAddr).name(node);
        
        bytes32 tldNode = keccak256(abi.encodePacked(bytes32(0), keccak256(bytes("eth"))));
        
        bytes32 forwardNode = keccak256(abi.encodePacked(tldNode, keccak256(bytes(name.split(".")[0]))));
        
        address forwardResolver = ens.resolver(forwardNode);
        
        if (forwardResolver == address(0)) return addr.toHexStringChecksumed();
        
        address resolved = Resolver(forwardResolver).addr(forwardNode);
        
        if (resolved == addr) {
            return name;
        } else {
            return addr.toHexStringChecksumed();
        }
    }
    
    function initENS() external onlyOwner {
        emit BatchMetadataUpdate(0, _nextTokenId() - 1);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token doesn't exist");
        
        (uint rank, uint gasPrice, uint timestamp, address creator) = getAllTokenInfo(tokenId);
        
        string memory svg = _tokenSVG(rank, gasPrice, timestamp, creator);
        
        string memory name = string.concat("Gas Lover Rank #", rank.toString());
        
        return string(
            abi.encodePacked(
                'data:application/json;utf-8,{',
                '"name":"', name, '",'
                '"attributes":[', 
                    '{"display_type": "number", "trait_type":"Rank","value":', rank.toString(), '},',
                    '{"display_type": "number", "trait_type":"Mint Tx Gas Price","value":', gasPrice.toString(), '},',
                    '{"display_type": "date", "trait_type":"Timestamp","value":', timestamp.toString(), '},',
                    '{"trait_type":"Creator","value":"', creator.toHexStringChecksumed(), '"}],',
                '"image_data":"', svg,'"'
                '}'
            )
        );
    }
    
    function getAllTokenInfo(uint tokenId) internal view returns (
        uint rank, uint64 gasPrice, uint32 timestamp, address creator
    ) {
        uint[] memory allPackedInfo = s().tokenIdToPackedInfo;
        uint tokenPackedInfo = allPackedInfo[tokenId];
        
        allPackedInfo.sort();
        
        (, uint index) = allPackedInfo.searchSorted(tokenPackedInfo);
        
        rank = _nextTokenId() - index;
        gasPrice = uint64(tokenPackedInfo >> 192);
        timestamp = uint32(tokenPackedInfo >> 160);
        creator = address(uint160(tokenPackedInfo));
    }
    
    function weiToGweiString(uint weiAmount) internal pure returns (string memory) {
        string memory wholePart = (weiAmount / 1 gwei).toString();
        string memory decimalPart = ((weiAmount / 0.01 gwei) % 100).toString();
        
        if (bytes(decimalPart).length == 1) {
            decimalPart = string.concat("0", decimalPart);
        }
        
        return string.concat(
            wholePart, ".", decimalPart
        );
    }
    
    function _tokenSVG(
        uint rank,
        uint gasPrice,
        uint timestamp,
        address creator
    ) internal view returns (string memory) {
        DynamicBufferLib.DynamicBuffer memory buffer;
        
        string memory bgOpacity = string.concat('calc(1 - (', (rank - 1).toString(), ' / ', _nextTokenId().toString(), '))');
        
        string memory bg = string.concat('rgba(19, 78, 74, ', bgOpacity, ')');
        
        buffer.append(abi.encodePacked(unicode'<svg version="1.2" xmlns="http://www.w3.org/2000/svg" width="1200" height="1200" viewbox="0 0 1200 1200"><foreignObject x="0" y="0" width="100%" height="100%"><div class="outer" xmlns="http://www.w3.org/1999/xhtml"><style>*{-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility;margin:0;border:0;box-sizing:border-box}.outer{width:1200px;height:1200px;background:#eab308;display:grid;place-items:center}.inner{background:', bg, unicode';width:90%;height:90%;display:flex;justify-content:center;align-items:center;font-size:100px;font-family:monospace;color:#fff;flex-direction:column;justify-content:center;gap:25px}.icon{font-size:200px}.truncate{font-size:36px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;width:100%;text-align:center}.wpf{font-size:80px}</style><div class="inner"><div class="icon">⛽️</div><div style="font-family: sans-serif">#', rank.toString(), ' Gas Lover</div><div class="truncate">', addressToEthName(creator), '</div><div class="truncate" style="font-family: sans-serif; font-weight: bold;font-size: 170px;">', weiToGweiString(gasPrice),'</div><div class="wpf" style="font-family: sans-serif">Gas Price</div></div></div></foreignObject></svg>'));
        
        return string.concat(
                "data:image/svg+xml;base64,",
                Base64.encode(
                    abi.encodePacked(
                        '<svg width="100%" height="100%" viewBox="0 0 1200 1200" version="1.2" xmlns="http://www.w3.org/2000/svg"><image width="1200" height="1200" href="data:image/svg+xml;base64,',
                        Base64.encode(buffer.data),
                        '"></image></svg>'
                    )
                )
            );
    }
    
    function tokenSVG(uint tokenId) external view returns (string memory) {
        (uint rank, uint gasPrice, uint timestamp, address creator) = getAllTokenInfo(tokenId);
        
        return _tokenSVG(rank, gasPrice, timestamp, creator);
    }
}

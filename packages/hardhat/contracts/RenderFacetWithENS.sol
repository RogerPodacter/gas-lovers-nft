// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {DynamicBufferLib} from "solady/src/utils/DynamicBufferLib.sol";
import {Base64} from "solady/src/utils/Base64.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {LibSort} from "solady/src/utils/LibSort.sol";
import {ERC721AUpgradeableInternal} from "./ERC721AUpgradeable/ERC721AUpgradeableInternal.sol";
import {GasLoverStorage, WithStorage} from "./WithStorage.sol";
import {UsingDiamondOwner} from "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";
import {ENS} from '@ensdomains/ens-contracts/contracts/registry/ENS.sol';
import {ReverseRegistrar} from '@ensdomains/ens-contracts/contracts/registry/ReverseRegistrar.sol';
import {Resolver} from '@ensdomains/ens-contracts/contracts/resolvers/Resolver.sol';

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
        if (_nextTokenId() > 0) emit BatchMetadataUpdate(0, _nextTokenId() - 1);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token doesn't exist");
        
        (uint rank, uint gasPrice, uint timestamp, address creator) = getAllTokenInfo(tokenId);
        
        string memory svg = _tokenSVG(rank, gasPrice, creator);
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
        
        if (bytes(decimalPart).length == 1) decimalPart = string.concat("0", decimalPart);
        
        return string.concat(wholePart, ".", decimalPart);
    }
    
    function _tokenSVG(
        uint rank,
        uint gasPrice,
        address creator
    ) internal view returns (string memory) {
        DynamicBufferLib.DynamicBuffer memory buffer;
        
        string memory bgOpacity = string.concat('calc(', (rank - 1).toString(), ' / ', _nextTokenId().toString(), ')');
        
        buffer.append(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" version="1.2" width="1200" height="1200" viewbox="0 0 1200 1200"><foreignObject x="0" y="0" width="100%" height="100%"><div xmlns="http://www.w3.org/1999/xhtml" class="outer"><style>*{-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility;margin:0;border:0;box-sizing:border-box;font-family:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";color:#fff;font-size:40px;overflow:hidden}.mono{font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace}.outer{width:100%;height:100%;background-color:#0c4a6e;padding:3%;display:grid;grid-template-rows:repeat(3,minmax(0,1fr));place-items:center}.unit{display:flex;flex-direction:column;justify-content:center;align-items:center;height:100%;width:100%;gap:5px}.gradient{background-image:linear-gradient(to right,#ec4899,#ef4444,#eab308);color:rgba(255,255,255,', bgOpacity,');background-clip:text;-webkit-background-clip:text;font-weight:700;font-size:450%}.textlg{font-size:110%}.text3xl{font-size:230%}</style><div class="unit" style="justify-content:flex-start"><div>Mint Gas Price</div><div class="text3xl">', weiToGweiString(gasPrice),' gwei</div></div><div class="unit"><div class="gradient">Rank #', rank.toString(),'</div></div><div class="unit" style="justify-content:flex-end"><div>Minter</div><div class="textlg mono">', addressToEthName(creator),'</div></div></div></foreignObject></svg>'));
        
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
        (uint rank, uint gasPrice, , address creator) = getAllTokenInfo(tokenId);
        
        return _tokenSVG(rank, gasPrice, creator);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";
import "solady/src/utils/LibPRNG.sol";
import "solady/src/utils/DynamicBufferLib.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";
import "solady/src/utils/LibSort.sol";
import "solady/src/utils/SSTORE2.sol";
import { ERC721D } from "./ERC721D/ERC721D.sol";

import "./InternalFacet.sol";

contract RenderFacet is ERC721D, InternalFacet {
    using LibSort for *;
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;
    using LibString for *;

    // contract URI

    function tokenURI(uint256 tokenId) public view override(ERC721D) returns (string memory) {
        require(_exists(tokenId));
        
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
    
    function getAllTokenInfo(uint tokenId) internal view returns (uint rank, uint64 gasPrice, uint32 timestamp, address creator) {
        uint[] memory allPackedInfo = s().tokenIdToPackedInfo;
        uint tokenPackedInfo = allPackedInfo[tokenId];
        
        allPackedInfo.sort();
        
        (, uint index) = allPackedInfo.searchSorted(tokenPackedInfo);
        
        rank = (s().nextTokenId - index) + 1;
        gasPrice = uint64(tokenPackedInfo >> 192);
        timestamp = uint32(tokenPackedInfo >> 160);
        creator = address(uint160(tokenPackedInfo));
    }
    
    function formatAsGwei(uint256 value) internal pure returns (string memory) {
        uint256 gweiValue = value / 10**9;
        uint256 decimals = value % 10**9;
        string memory decimalsStr = decimals < 10**8 ? string(abi.encodePacked("0", decimals.toString())) : decimals.toString();
        return string(abi.encodePacked(gweiValue.toString(), ".", decimalsStr, " gwei"));
    }
    
    function _tokenSVG(
        uint rank,
        uint gasPrice,
        uint timestamp,
        address creator
    ) internal pure returns (string memory) {
        DynamicBufferLib.DynamicBuffer memory buffer;
        
        buffer.append(abi.encodePacked(unicode'<svg version="1.2" xmlns="http://www.w3.org/2000/svg" width="1200" height="1200" viewbox="0 0 1200 1200"><foreignObject x="0" y="0" width="100%" height="100%"><div class="outer" xmlns="http://www.w3.org/1999/xhtml"><style>*{-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility;margin:0;border:0;box-sizing:border-box}.outer{width:1200px;height:1200px;background:#eab308;display:grid;place-items:center}.inner{background:#134e4a;width:90%;height:90%;display:flex;justify-content:center;align-items:center;font-size:100px;font-family:monospace;color:#fff;flex-direction:column;justify-content:center;gap:25px}.icon{font-size:200px}.truncate{font-size:36px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;width:100%;text-align:center}.wpf{font-size:80px}</style><div class="inner"><div class="icon">⛽️</div><div style="font-family: sans-serif">#', rank.toString(), ' Gas Lover</div><div class="truncate">', creator.toHexStringChecksumed(), '</div><div class="truncate" style="font-family: sans-serif; font-weight: bold;font-size: 170px;">', formatAsGwei(gasPrice),'</div><div class="wpf" style="font-family: sans-serif">Gas Price</div></div></div></foreignObject></svg>'));
        
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

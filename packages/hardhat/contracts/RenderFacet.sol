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
        
        uint[] memory allFees = s().tokenIdToPriorityFee;
        allFees.sort();
        
        uint priorityFee = s().tokenIdToPriorityFee[tokenId];
        
        (, uint index) = allFees.searchSorted(priorityFee);

        uint rank = s().nextTokenId - index;
        
        string memory svg = tokenSVG(tokenId);
        
        string memory name = string.concat("Gas Lover Rank #", rank.toString());
        
        return string(
            abi.encodePacked(
                'data:application/json;utf-8,{',
                '"name":"', name, '",'
                '"image_data":"', svg,'"'
                '}'
            )
        );
    }
    
    // function weiToEtherString(uint weiAmount) public pure returns (string memory) {
    //     string memory wholePart = (weiAmount / 1e18).toString();
    //     string memory decimalPart = ((weiAmount / 1e16) % 100).toString();
        
    //     if (bytes(decimalPart).length == 1) {
    //         decimalPart = string.concat("0", decimalPart);
    //     }
        
    //     return string.concat(
    //         wholePart, ".", decimalPart
    //     );
    // }
    
    function weiToGweiString(uint weiAmount) internal pure returns (string memory) {
        string memory wholePart = (weiAmount / 1e9).toString();
        string memory decimalPart = ((weiAmount / 1e7) % 100).toString();
        
        if (bytes(decimalPart).length == 1) {
            decimalPart = string.concat("0", decimalPart);
        }
        
        return string.concat(
            wholePart, ".", decimalPart
        );
    }
    
    function tokenSVG(uint tokenId) public view returns (string memory) {
        DynamicBufferLib.DynamicBuffer memory buffer;
        uint[] memory allFees = s().tokenIdToPriorityFee;
        allFees.sort();

        uint priorityFee = s().tokenIdToPriorityFee[tokenId];

        (, uint index) = allFees.searchSorted(priorityFee);

        uint rank = s().nextTokenId - index;
        
        uint dec = (priorityFee / 0.1 gwei) % 10;
        uint whole = (priorityFee / 0.1 gwei ) / 10;
        
        string memory str = string.concat(
            whole.toString(), ".", dec.toString(), " gwei"
        );

        address creator = s().tokenIdToCreator[tokenId];
        
        buffer.append(abi.encodePacked(unicode'<svg version="1.2" xmlns="http://www.w3.org/2000/svg" width="1200" height="1200" viewbox="0 0 1200 1200"><foreignObject x="0" y="0" width="100%" height="100%"><div class="outer" xmlns="http://www.w3.org/1999/xhtml"><style>*{margin:0;border:0;box-sizing:border-box}.outer{width:1200px;height:1200px;background:#eab308;display:grid;place-items:center}.inner{background:#134e4a;width:90%;height:90%;display:flex;justify-content:center;align-items:center;font-size:100px;font-family:monospace;color:#fff;flex-direction:column;justify-content:center;gap:25px}.icon{font-size:200px}.truncate{font-size:36px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;width:100%;text-align:center}.wpf{font-size:80px}</style><div class="inner"><div class="icon">⛽️</div><div style="font-family: sans-serif">#', rank.toString(), ' Gas Lover</div><div class="truncate">', creator.toHexStringChecksumed(), '</div><div class="truncate" style="font-family: sans-serif; font-weight: bold;font-size: 170px;">', (priorityFee / 1 gwei).toString(),'</div><div class="wpf" style="font-family: sans-serif">Priority Fee</div></div></div></foreignObject></svg>'));
        
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
}

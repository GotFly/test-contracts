// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestContract {

    constructor() {}

    event GetHashEvent(bytes32 _hash);
    function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, uint _param1, string memory _param2, bytes memory _param3) public {
        // bytes memory payload = abi.encodePacked(_param1, _param2, _param3);
        bytes memory payload = abi.encodePacked(_param2);
        bytes memory packedData = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress, payload);
        emit GetHashEvent(_buildHash(packedData));
    }

    event CheckHashEvent(bool _result, uint _hash, bytes32 _resultHash);
    function checkHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, uint _param1, string memory _param2, bytes memory _param3, uint _hash) public {
        // bytes memory payload = abi.encodePacked(_param1, _param2, _param3);
        bytes memory payload = abi.encodePacked(_param2);
        bytes memory packedData = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress, payload);
        bytes32 resultHash = _buildHash(packedData);

        emit CheckHashEvent(resultHash == bytes32(_hash), _hash, resultHash);
    }


    function _buildHash(bytes memory _packed) private pure returns(bytes32) {
        bytes memory staticChunk = new bytes(80);
        for (uint i = 0; i < 80; i++) {
            staticChunk[i] = bytes(_packed)[i];
        }

        bytes memory payloadChunk = new bytes(_packed.length - staticChunk.length);
        for (uint i = staticChunk.length; i < _packed.length; i++) {
            payloadChunk[i - staticChunk.length] = bytes(_packed)[i];
        }

        uint length = payloadChunk.length;
        uint8 chunkLength = 127;

        bytes32 hash = sha256(staticChunk);

        for (uint i = 0; i <= length / chunkLength; i++) {
            uint from = chunkLength * i;
            uint to = from + chunkLength <= length ? from + chunkLength : length;
            bytes memory chunk = new bytes(to - from);
            for(uint j = from; j < to; j++){
                chunk[j - from] = bytes(payloadChunk)[j];
            }
            
            hash = sha256(abi.encode(hash, sha256(chunk)));
        }

        return hash;
    }
}

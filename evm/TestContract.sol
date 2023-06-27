// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestContract {

    constructor() {}
    event GetTestEvent(uint _i, uint _length, bytes _value, bytes32 _hash);
    event GetHashEvent(bytes32 _hash);
    function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, uint _txId, uint _dstAddressUint, uint _amount, uint _tokenAddressUint, uint8 _decimals) public {
        bytes memory payload = abi.encodePacked(_dstAddressUint, _amount, _txId, _tokenAddressUint, _decimals);
        bytes memory packedData = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress, _txId, payload);
        emit GetHashEvent(_buildHash(packedData));
    }

    event CheckHashEvent(bool _result, uint _hash, bytes32 _resultHash);
    function checkHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, uint _txId, uint _dstAddressUint, uint _amount, uint _tokenAddressUint, uint8 _decimals, uint _hash) public {
        bytes memory payload = abi.encodePacked(_dstAddressUint, _amount, _txId, _tokenAddressUint, _decimals);
        bytes memory packedData = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress, _txId, payload);
        bytes32 resultHash = _buildHash(packedData);

        emit CheckHashEvent(resultHash == bytes32(_hash), _hash, resultHash);
    }


    function _buildHash(bytes memory _packed) private returns(bytes32) {
        bytes memory staticChunk = new bytes(112);
        for (uint i = 0; i < 112; i++) {
            staticChunk[i] = bytes(_packed)[i];
        }

        bytes memory payloadChunk = new bytes(_packed.length - staticChunk.length);
        for (uint i = staticChunk.length; i < _packed.length; i++) {
            payloadChunk[i - staticChunk.length] = bytes(_packed)[i];
        }

        uint length = payloadChunk.length;
        uint8 chunkLength = 127;

        bytes32 hash = sha256(staticChunk);

        emit GetTestEvent(0, staticChunk.length, staticChunk, hash);

        for (uint i = 0; i <= length / chunkLength; i++) {
            uint from = chunkLength * i;
            uint to = from + chunkLength <= length ? from + chunkLength : length;
            bytes memory chunk = new bytes(to - from);
            for(uint j = from; j < to; j++){
                chunk[j - from] = bytes(payloadChunk)[j];
            }
            
            hash = sha256(abi.encode(hash, sha256(chunk)));
            emit GetTestEvent(i, chunk.length, chunk, sha256(chunk));
        }

        return hash;
    }
}

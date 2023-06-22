// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestContract {
    constructor() {}

    event GetLengthEvent(uint _length);
    event GetTestEvent(uint _i, uint _length, bytes _value, bytes32 _hash);
    event GetInputEvent(string _chunk, bytes _value);
    event GetHashEvent(bytes32 _hash);


    function _buildHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes memory _payload) private returns(bytes32) {
        bytes memory packed = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress, _payload);

        emit GetInputEvent("packed", packed);

        emit GetHashEvent(sha256(packed));

        bytes memory staticChunk = new bytes(80);
        for (uint i = 0; i < 80; i++) {
            staticChunk[i] = bytes(packed)[i];
        }

        emit GetLengthEvent(packed.length);
        emit GetLengthEvent(staticChunk.length);
        emit GetLengthEvent(packed.length - staticChunk.length);

        emit GetInputEvent("static", staticChunk);

        bytes memory payloadChunk = new bytes(packed.length - staticChunk.length);
        for (uint i = staticChunk.length; i < packed.length; i++) {
            payloadChunk[i - staticChunk.length] = bytes(packed)[i];
        }

        emit GetInputEvent("payload", payloadChunk);
        
        uint length = payloadChunk.length;
        uint8 chunkLength = 127;

        bytes32 hash = sha256(staticChunk);

        emit GetHashEvent(hash);

        for (uint i = 0; i <= length / chunkLength; i++) {
            uint from = chunkLength * i;
            uint to = from + chunkLength <= length ? from + chunkLength : length;
            bytes memory chunk = new bytes(to - from);
            for(uint j = from; j < to; j++){
                chunk[j - from] = bytes(payloadChunk)[j];
            }
            
            // emit GetInputEvent("chunk", chunk);
            
            hash = sha256(abi.encode(hash, sha256(chunk)));

            emit GetTestEvent(i, to - from, chunk, sha256(chunk));
        }

        return hash;
    }

    function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress,  uint _param1, uint _param2, string memory _param3) public {
        bytes memory payload = abi.encodePacked(_param1, _param2, _param3);
        emit GetHashEvent(_buildHash(_srcChainId, _dstChainId, _srcAddress, _dstAddress, payload));
    }

}
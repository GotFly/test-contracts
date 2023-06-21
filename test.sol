// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestContract {
    constructor() {}

    // function bytesHash(bytes memory _data) public pure returns (bytes memory b) {
    //     // bytes memory test = abi.encode(_data);
    //     // return test;
    //     b = new bytes(32);
    //     assembly { mstore(add(b, 32), _data) }
    // }

    // event GetHashEvent(bytes32 _value);
    event GetTestEvent(uint _i, uint _length,bytes _value, bytes32 _hash);
    event GetInputEvent(bytes _value);
    event GetHashEvent(bytes32 _hash);
    // event GetHashEvent(bytes32 _value);

    // function getHash(bytes memory _input) public {

    //     // bytes32 a = bytes32(_input[:32]);

    //     bytes memory a = abi.encodePacked(_input);
    //     bytes32 result = sha256(a);
    //     // bytes32 result = sha256(_input);

    //     // bytes memory result2 = abi.encode(_chainId, _nonce);
    //     emit GetInputEvent(a);

    //     emit GetHashEvent(result);
    // }


   function _buildHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes memory _payload) private returns(bytes32) {
        bytes memory staticPacked = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress);

        uint length = _payload.length;
        uint8 chunkLength = 127;

        bytes32 hash = sha256(staticPacked);

        bytes memory t  = new bytes(127);
        bytes32 t2;

        // if (length > chunkLength) {

            for (uint i = 0; i <= length / chunkLength; i++) {
                uint from = chunkLength * i;
                uint to = from + chunkLength <= length ? from + chunkLength : length;
                bytes memory chunk = new bytes(to - from);
                for(uint j = from; j < to; j++){
                    chunk[j - from] = bytes(_payload)[j];
                }
                emit GetInputEvent(chunk);
                // bytes memory dynamicPacked = abi.encodePacked(chunk);
                hash = sha256(abi.encode(hash, sha256(chunk)));

                t = chunk;
                t2 = sha256(chunk);
                emit GetTestEvent(i, to - from, t, t2);
            }

        // } else {
        //     // bytes memory dynamicPacked = abi.encodePacked(_payload);
        //     hash = sha256(abi.encode(hash, sha256(_payload)));
        // }

        return hash;

    }

    function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes memory _payload) public {
        emit GetHashEvent(_buildHash(_srcChainId, _dstChainId, _srcAddress, _dstAddress, _payload));
    }

}
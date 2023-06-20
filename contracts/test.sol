// EVM

function _buildHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes memory _payload) private returns(bytes32) {
    bytes memory staticPacked = abi.encodePacked(_srcChainId, _dstChainId, _srcAddress, _dstAddress);

    uint length = _payload.length;
    uint8 chunkLength = 127;

    bytes32 hash = sha256(staticPacked);

    if (length > chunkLength) {

        for (uint i = 0; i <= length / chunkLength; i++) {
            uint from = chunkLength * i;
            uint to = from + chunkLength <= length ? from + chunkLength : length;
            bytes memory chunk = new bytes(to - from);
            for(uint j = from; j < to; j++){
                chunk[j - from] = bytes(_payload)[j];
            }
            bytes memory dynamicPacked = abi.encodePacked(chunk);
            hash = sha256(abi.encode(hash, sha256(dynamicPacked)));
        }

    } else {
        bytes memory dynamicPacked = abi.encodePacked(_payload);
        hash = sha256(abi.encode(hash, sha256(dynamicPacked)));
    }

    return hash;

}

function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes memory _payload) public {
    emit GetHashEvent(_buildHash(_srcChainId, _dstChainId, _srcAddress, _dstAddress, _payload));
}


// TVM
function _buildHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes _payload) private returns(uint) {

    TvmCell staticCell = abi.encode(_srcChainId, _dstChainId, _srcAddress, _dstAddress);

    TvmSlice staticSlice = staticCell.toSlice();
    uint hash = sha256(staticSlice);

    uint length = _payload.length;
    uint chunkLength = 127;

    if (length > chunkLength) {
        for (uint i = 0; i < math.divc(length, chunkLength); i++) {
            uint from = chunkLength * i;
            uint to = from + chunkLength;
            bytes chunk = _payload[from:(to <= length ? to : length)];
            hash = sha256(abi.encode(hash, sha256(chunk)).toSlice());
        }
    } else {
        TvmSlice dynamicCell = abi.encode(_payload).toSlice();
        TvmSlice dynamicSlice = dynamicCell.loadRefAsSlice();
        hash = sha256(abi.encode(hash, sha256(dynamicSlice)).toSlice());
    }

    return hash;
}

function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes _payload) public pure {
    uint resultHash = _buildHash(_srcChainId, _dstChainId, _srcAddress, _dstAddress, _payload);

    emit GetHashEvent(resultHash);
    tvm.accept();
}
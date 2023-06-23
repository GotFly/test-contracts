pragma ever-solidity >= 0.70.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

// import "locklift/src/console.tsol";

contract Sample {

    event GetHashEvent(uint _hash); 
    // "_value": "te6ccgEBAQEAKgAAUAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE="
    event GetDecodedEvent(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes _payload);

    // 0x71C7656EC7ab88b098defB751B7401B5f6d8976F

    event GetRefsEvent(uint _i, uint8 _refs, uint16 _depth, uint16 _bits);
    event GetPayloadEvent(string _mark, bytes _data);
    event GetTestEvent(string _mark, uint _i, bytes _data);
    event GetStepEvent(uint _i, bytes _chunk, uint _hash);
    // event GetLengthEvent(uint _l);
    event GetChunkEvent(uint _bits, bytes _chunk);

    // function _buildNestedHash(TvmSlice _slice, uint _hash) private pure returns(uint) {

    //     TvmCell nestedCell = _slice.preloadRef(1);
    //     emit GetTestEvent("Nested", bytes(nestedCell.toSlice()));
    // }

    function _buildHashCell(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, TvmCell _payload) private pure returns(uint)
     {
        TvmCell encodedCell = abi.encode(_srcChainId, _dstChainId, _srcAddress, _dstAddress, bytes(_payload.toSlice()));

        TvmSlice encodedSlice = encodedCell.toSlice();

        uint hash = sha256(encodedSlice);

        TvmSlice payloadSlice = encodedSlice.loadRefAsSlice();

        uint16 payloadDepth = payloadSlice.depth();
        // emit GetLengthEvent(payloadDepth);

        emit GetPayloadEvent("Payload from ref", bytes(payloadSlice));

        bytes chunk = "";

        // uint padding = 0;

        for (uint i = 0; i <= payloadDepth; i++) {   

            uint8 r = payloadSlice.refs();
            uint16 d = payloadSlice.depth();
            uint16 b = payloadSlice.bits();

            // Nested refs
            // if (r > 1) {
            //     for (uint2 j = 1; j < r; j++) {   
            //         TvmCell nestedCell = payloadSlice.preloadRef(j);
            //         TvmSlice nestedSlice = nestedCell.toSlice();
            //         uint16 nestedBits = nestedSlice.bits();

            //         for (uint k = 0; k < nestedBits / 8; k++) {
            //             if (chunk.length + 1 < 127) {
            //                 chunk.append(bytes(bytes(nestedSlice)[k]));
            //             } else if (chunk.length + 1 == 127) {
            //                 hash = sha256(abi.encode(hash, sha256(chunk)).toSlice());
            //                 emit GetStepEvent(i, chunk, sha256(chunk));
            //                 chunk = "";
            //                 chunk.append(bytes(bytes(nestedSlice)[k]));
            //             }
            //         }
            //     }
            // }

            // Main tree
            if (b > 0) {

                for (uint j = 0; j < b / 8; j++) {
                    if (chunk.length + 1 < 127) {
                        chunk.append(bytes(bytes(payloadSlice)[j]));
                    } else if (chunk.length + 1 == 127) {
                        hash = sha256(abi.encode(hash, sha256(chunk)).toSlice());
                        emit GetStepEvent(i, chunk, sha256(chunk));
                        chunk = "";
                        chunk.append(bytes(bytes(payloadSlice)[j]));
                    }
                }
                
                emit GetRefsEvent(i, r, d, b);
                emit GetTestEvent("Slice", i, bytes(payloadSlice));
                emit GetTestEvent("Chunk", i, chunk);

                
                // emit GetTestEvent("Tree", bytes(payloadSlice));

                // if (chunk.length == 0 && padding == 0) {
                //     chunk = bytes(payloadSlice)[0:b / 8];
                //     padding = chunk.length - 1;
                // } else if (chunk.length > 0 && chunk.length < 127) {
                //     if (padding != 0  && b / 8 >= padding) {
                //         chunk.append(bytes(payloadSlice)[0:padding]);
                //     }
                //     if (padding != 0  && b / 8 < padding) {
                //         chunk.append(bytes(payloadSlice)[0:b / 8]);
                //     } 
                // }

                // emit GetChunkEvent(b, chunk);
                // if (chunk.length == 127) {
                //     hash = sha256(abi.encode(hash, sha256(chunk)).toSlice());
                //     emit GetStepEvent(i, chunk, sha256(chunk));
                //     chunk = "";
                //     chunk.append(bytes(payloadSlice)[padding:b / 8]);
                //     padding = chunk.length - 1;
                // }

                if (i == payloadDepth) {
                    hash = sha256(abi.encode(hash, sha256(chunk)).toSlice());
                    emit GetStepEvent(i, chunk, sha256(chunk));
                }
            }
            
             if (r > 0 && r <= 1) {
                payloadSlice = payloadSlice.loadRefAsSlice();
             }
        }

        return hash;
    }

    // function _buildHashBytes(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, bytes _payload) private pure returns(uint) {

    //     TvmCell staticCell = abi.encode(_srcChainId, _dstChainId, _srcAddress, _dstAddress);

    //     TvmSlice staticSlice = staticCell.toSlice();
    //     uint hash = sha256(staticSlice);

    //     uint length = _payload.length;
    //     uint chunkLength = 127;

    //     if (length > chunkLength) {
    //         for (uint i = 0; i < math.divc(length, chunkLength); i++) {
    //             uint from = chunkLength * i;
    //             uint to = from + chunkLength;
    //             bytes chunk = _payload[from:(to <= length ? to : length)];
    //             hash = sha256(abi.encode(hash, sha256(chunk)).toSlice());
    //         }

    //         // hash = sha256(abi.encode(hash, bytesHash(bytes(_payload))).toSlice());
    //         // for (uint i = 0; i < math.divc(length, chunkLength); i++) {
    //             // steps += 1;
    //             // uint from = chunkLength * i;
    //             // uint to = from + chunkLength <= length ? from + chunkLength : length;
    //             // uint to = from + chunkLength;
    //             // bytes chunk = _payload[from:(to <= length ? to : length)];
    //             // bytes chunk;
    //             // for(uint j = 0; j < 10; j++){
    //             //     // chunk.append(bytes(_payload[j]));
    //             // }
    //         // }
    //     //         // bytes chunk = _payload[from:to];

    //     // // //         // bytes chunk = _payload[from:to];
    //     // // //         // TvmSlice chunkCell = abi.encode(chunk).toSlice();
    //     // // //         // TvmSlice refSlice = chunkCell.loadRefAsSlice();
    //     // // //         // hash = sha256(abi.encode(hash, sha256(refSlice)).toSlice());
    //     // // //         bytes chunk = new bytes(to - from);
    //         // }

    //         // TvmSlice payload = _payload.toSlice();
    //         // // hash = sha256(abi.encode(hash, sha256(payload)).toSlice());
    //         // uint i = payload.depth();
    //         // emit GetLengthEvent(i);
    //         // while (i != 0) {
    //         //     // TvmSlice refSlice = payload.loadRefAsSlice();
    //         //     // i = refSlice.depth();
    //         //     // if (i != 0) {
    //         //     //     payload = payload.loadRefAsSlice();
    //         //     // }
    //         //     // hash = sha256(abi.encode(hash, sha256(refSlice)).toSlice());
    //         // }
    //     } else {
    //         TvmSlice dynamicCell = abi.encode(_payload).toSlice();
    //         TvmSlice dynamicSlice = dynamicCell.loadRefAsSlice();
    //         hash = sha256(abi.encode(hash, sha256(dynamicSlice)).toSlice());
    //     }

    //     return hash;
    // }

    function getHash(uint64 _srcChainId, uint64 _dstChainId, uint _srcAddress, uint _dstAddress, uint _param1, uint _param2, string _param3) public pure {
        tvm.accept();
        TvmCell payload = abi.encode(_param1, _param2, _param3);
        uint resultHash = _buildHashCell(_srcChainId, _dstChainId, _srcAddress, _dstAddress, payload);

        emit GetHashEvent(resultHash);
    }
}
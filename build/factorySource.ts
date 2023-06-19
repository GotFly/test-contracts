const sampleAbi = {"ABIversion":2,"version":"2.2","header":["pubkey","time","expire"],"functions":[{"name":"testFunc","inputs":[{"name":"_input","type":"bytes"}],"outputs":[]},{"name":"getHash","inputs":[{"name":"_srcChainId","type":"uint64"},{"name":"_dstChainId","type":"uint64"},{"name":"_srcAddress","type":"uint256"},{"name":"_dstAddress","type":"uint256"},{"name":"_payload","type":"string"}],"outputs":[]},{"name":"constructor","inputs":[],"outputs":[]}],"data":[],"events":[{"name":"GetInputEvent","inputs":[{"name":"_cell","type":"cell"},{"name":"_depth","type":"uint16"}],"outputs":[]},{"name":"GetHashEvent","inputs":[{"name":"_hash","type":"uint256"}],"outputs":[]},{"name":"GetDecodedEvent","inputs":[{"name":"_srcChainId","type":"uint64"},{"name":"_dstChainId","type":"uint64"},{"name":"_srcAddress","type":"uint256"},{"name":"_dstAddress","type":"uint256"},{"name":"_payload","type":"bytes"}],"outputs":[]},{"name":"GetTestEvent","inputs":[{"name":"_b","type":"bytes"}],"outputs":[]},{"name":"GetLengthEvent","inputs":[{"name":"_l","type":"uint256"}],"outputs":[]}],"fields":[{"name":"_pubkey","type":"uint256"},{"name":"_timestamp","type":"uint64"},{"name":"_constructorFlag","type":"bool"}]} as const

export const factorySource = {
    Sample: sampleAbi
} as const

export type FactorySource = typeof factorySource
export type SampleAbi = typeof sampleAbi

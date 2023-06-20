import { expect } from "chai";
import { Contract, Signer } from "locklift";
import { FactorySource } from "../build/factorySource";

let sample: Contract<FactorySource["Sample"]>;
let signer: Signer;

describe("Test Sample contract", async function () {
  before(async () => {
    signer = (await locklift.keystore.getSigner("0"))!;
  });
  describe("Contracts", async function () {
    it("Load contract factory", async function () {
      const sampleData = await locklift.factory.getContractArtifacts("Sample");

      expect(sampleData.code).not.to.equal(undefined, "Code should be available");
      expect(sampleData.abi).not.to.equal(undefined, "ABI should be available");
      expect(sampleData.tvc).not.to.equal(undefined, "tvc should be available");
    });

    it("Deploy contract", async function () {
      const INIT_STATE = 0;
      const { contract } = await locklift.factory.deployContract({
        contract: "Sample",
        publicKey: signer.publicKey,
        initParams: {
          _nonce: locklift.utils.getRandomNonce(),
        },
        constructorParams: {
          // _state: INIT_STATE,
        },
        value: locklift.utils.toNano(2),
      });
      sample = contract;

      expect(await locklift.provider.getBalance(sample.address).then(balance => Number(balance))).to.be.above(0);
    });

    it("Interact with contract", async function () {
      let utf8Encode = new TextEncoder();
      await locklift.tracing.trace(sample.methods.getHash(
        {
          _srcChainId: 1,
          _dstChainId: 1,
          _srcAddress: '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
          _dstAddress:'0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
          _payload: '4d6f6c65737469652072697375732064696374756d73742e2049642073617069656e206d6f6c6c6973206e6f6e2061656e65616e206573742e20436f6e7365637465747572206d6f6c6573746965207365642061656e65616e20686162697461737365206d6f726269206e6563206c656f2c206d6f726269206d6f6c657374696520726973757320697073756d20616d65742c20616d6574206d6f726269206d6f6c6573746965206964206a7573746f2073697420726973757320736564206e6f6e20616363756d73616e207669746165206f726e617265206573742e204d6f726269206e6f6e206c7563747573206461706962757320736974206d616c657375616461206f7263692c206d617474697320616d65742c206461706962757320736974206d6174746973206e6f6e206c65637475732064696374756d2e20446f6c6f722076656c69742065742e204d6f6c6573746965206f7263692c2076656c69742064617069627573206e756c6c6120696e74657264756d206c656f2c20726973757320696e2076756c70757461746520696e74657264756d2075726e6120656c656966656e642070656c6c656e7465737175652076656c697420696e20746f72746f722c20706c617465612064696374756d20656c69742e20546f72746f722c2073697420656c656966656e6420636f6e73' }).sendExternal({ publicKey: signer.publicKey }));

      // const NEW_STATE = 1;

      // await sample.methods.setState({ _state: NEW_STATE }).sendExternal({ publicKey: signer.publicKey });

      // const response = await sample.methods.getDetails({}).call();

      // expect(Number(response._state)).to.be.equal(NEW_STATE, "Wrong state");
    });
  });
});

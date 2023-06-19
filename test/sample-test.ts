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
          _payload: 'Molestie risus dictumst. Id sapien mollis non aenean est. Consectetur molestie sed aenean habitasse morbi nec leo, morbi molestie risus ipsum amet, amet morbi molestie id justo sit risus sed non accumsan vitae ornare est. Morbi non luctus dapibus sit malesuada orci, mattis amet, dapibus sit mattis non lectus dictum. Dolor velit et. Molestie orci, velit dapibus nulla interdum leo, risus in vulputate interdum urna eleifend pellentesque velit in tortor, platea dictum elit. Tortor, sit eleifend cons' }).sendExternal({ publicKey: signer.publicKey }));

      // const NEW_STATE = 1;

      // await sample.methods.setState({ _state: NEW_STATE }).sendExternal({ publicKey: signer.publicKey });

      // const response = await sample.methods.getDetails({}).call();

      // expect(Number(response._state)).to.be.equal(NEW_STATE, "Wrong state");
    });
  });
});

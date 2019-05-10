const truffleAssert = require("truffle-assertions");
const {reverts} = truffleAssert;
const {toBN, toWei} = web3.utils;
const {getBalance} = web3.eth;
const Remittance = artifacts.require("Remittance");

contract("Remittance", accounts => {

    const BN_0 = toBN("0");
    const BN_1ETH = toBN(toWei("1", "ether"));
    const BN_FEE = toBN(toWei("0.05", "ether"));
    const BN_MIN = toBN(60 * 60 * 24); // 24 hours in secs
    const BN_MAX = toBN(60 * 60 * 24 * 7); // 7 days in secs

    const [ALICE, BOB] = accounts;
    let REMITTANCE;

    beforeEach("Initialization", async () => {
        REMITTANCE = await Remittance.new(BN_FEE, BN_MIN, BN_MAX, {from: ALICE});
    });

    describe("Function: constructor", () => {
        it("should have initial balance of zero", async () => {
            const balance = toBN(await getBalance(REMITTANCE.address));
            assert(balance.eq(BN_0), "contract balance is not zero");
        });

        it("should set remittance fee accordingly", async () => {
            const fee = await REMITTANCE.fee({from: ALICE});
            assert.isTrue(fee.eq(BN_FEE), "remittance fee mismatch");
        });
    });

    describe("Contract: Ownable", () => {
        it("should have deployer as owner", async () => {
            const isOwner = await REMITTANCE.isOwner({from: ALICE});
            assert.isTrue(isOwner, "deployer is not owner");
        });

        it("should reject other account as owner", async () => {
            const isOwner = await REMITTANCE.isOwner({from: BOB});
            assert.isFalse(isOwner, "deployer is owner");
        });
    });

    describe("Contract: Pausable", () => {
        it("should have deployer as pauser", async () => {
            const isPauser = await REMITTANCE.isPauser(ALICE, {from: ALICE});
            assert.isTrue(isPauser, "deployer is not pauser");
        });

        it("should reject other account as pauser", async () => {
            const isPauser = await REMITTANCE.isPauser(BOB, {from: ALICE});
            assert.isFalse(isPauser, "deployer is pauser");
        });
    });

    describe("Function: fallback", () => {
        it("should revert on fallback", async () => {
            await reverts(
                REMITTANCE.sendTransaction({from: ALICE, value: BN_1ETH})
            );
        });
    });
});

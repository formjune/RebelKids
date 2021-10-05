const RebelKidsStickers = artifacts.require('RebelKidsStickers');
const RebelKids = artifacts.require('RebelKids');
const RebelFamiliars = artifacts.require('RebelKidsFamiliars');

const expectThrowsAsync = async (method, errorMessage) => {
    let error = null;
    try {
        await method();
    } catch (err) {
        error = err;
    }
    expect(error).to.be.an('Error');
    if (errorMessage) {
        expect(error.message).to.equal(errorMessage);
    }
};

const setBlockTimestamp = (date) => {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: '2.0',
            method: 'evm_mine',
            id: Date.now(),
            params: [date.getTime() / 1000],
        }, (err, res) => {
            if (err) return reject(err);
            resolve(res);
        });
    });
};

let minter1;
let minter2;
let minter3;
let minter4;
let minter5;

const makeArray = (x, len) => {
    let arr = [];
    for (let i = 0; i < len; i++) {
        arr.push(x);
    }
    return arr;
};

let kids;
let familiars;
let tickets;
const reward = 3000;
const startDate = new Date(2021, 9 - 1, 15 - 1);

contract('RebelKidsStickers test', async accounts => {
    it('Test configuration, set ganache block timestamp=2021-09-05', async () => {
        minter1 = (await web3.eth.getAccounts())[1];
        minter2 = (await web3.eth.getAccounts())[2];
        minter3 = (await web3.eth.getAccounts())[3];
        minter4 = (await web3.eth.getAccounts())[4];
        minter5 = (await web3.eth.getAccounts())[5];
        await setBlockTimestamp(startDate);
        kids = await RebelKids.deployed();
        familiars = await RebelFamiliars.deployed();
        tickets = await RebelKidsStickers.deployed();
    });
    it('Mint 2 token to kids, 6 to familiars', async () => {
        await kids.giftTokens(makeArray(minter1, 6));
        await familiars.giftTokens(makeArray(minter2, 6));
        await kids.giftTokens(makeArray(minter3, 15));
        await kids.giftTokens(makeArray(minter4, 100));
    });
    it('Claim with kids and familiars, check claim methods', async () => {
        let availableForKids = await tickets.findClaimableTokensForKids({from: minter1});
        await tickets.claimWithKids({from: minter1});
        let claimedWithKids = await tickets.balanceOf(minter1);
        assert.equal(availableForKids.toNumber(), claimedWithKids.toNumber());
        assert.equal(availableForKids.toNumber(), reward * 6);


        let availableForFamiliars = await tickets.findClaimableTokensForFamiliars({from: minter2});
        await tickets.claimWithFamiliars({from: minter2});
        let claimedWithFamiliars = await tickets.balanceOf(minter2);
        assert.equal(availableForFamiliars.toNumber(), claimedWithFamiliars.toNumber());
        assert.equal(availableForFamiliars.toNumber(), reward * 6 / 3);

        assert.equal(claimedWithFamiliars.toNumber(), claimedWithKids.toNumber() / 3);
    });
    it('Check claimed tickets is zero after claiming in this month', async () => {
        let availableForKids = await tickets.findClaimableTokensForKids({from: minter1});
        let balance = (await tickets.balanceOf(minter1)).toNumber();
        await tickets.claimWithKids({from: minter1});
        let claimedWithKids = (await tickets.balanceOf(minter1)).toNumber() - balance;
        assert.equal(availableForKids.toNumber(), claimedWithKids);
        assert.equal(0, claimedWithKids);


        let availableForFamiliars = await tickets.findClaimableTokensForFamiliars({from: minter2});
        balance = (await tickets.balanceOf(minter2)).toNumber();
        await tickets.claimWithFamiliars({from: minter2});
        let claimedWithFamiliars = (await tickets.balanceOf(minter2)).toNumber() - balance;
        assert.equal(availableForFamiliars.toNumber(), claimedWithFamiliars);
        assert.equal(0, claimedWithFamiliars);
    });
    it('Check claiming with 15 tokens', async () => {
        let availableForKids = await tickets.findClaimableTokensForKids({from: minter3});
        await tickets.claimWithKids({from: minter3});
        let claimedWithKids = (await tickets.balanceOf(minter3)).toNumber();
        assert.equal(claimedWithKids, availableForKids.toNumber());
        assert.equal(availableForKids, reward * 15);
    });
    it('Check claiming with 100 tokens', async () => {
        let availableForKids = await tickets.findClaimableTokensForKids({from: minter4});
        await tickets.claimWithKids({from: minter4});
        let claimedWithKids = (await tickets.balanceOf(minter4)).toNumber();
        assert.equal(claimedWithKids, availableForKids.toNumber());
        assert.equal(availableForKids.toNumber(), reward * 100);
    });
    it('Check claiming with 0 tokens', async () => {
        let availableForKids = await tickets.findClaimableTokensForKids({from: minter5});
        await tickets.claimWithKids({from: minter5});
        let claimedWithKids = (await tickets.balanceOf(minter5)).toNumber();
        assert.equal(claimedWithKids, availableForKids.toNumber());
        assert.equal(availableForKids.toNumber(), 0);
    });

    it('Check claiming tickets with same tokens', async () => {
        let lastClaim = (await tickets.balanceOf(minter1)).toNumber();
        for (let i = 1; i <= 7; i++) {
            let date = new Date(startDate);
            date.setMonth(startDate.getMonth() % 12 + i);

            await setBlockTimestamp(date);
            let balance = (await tickets.balanceOf(minter1)).toNumber();
            await tickets.claimWithKids({from: minter1});
            let claimedWithKids = (await tickets.balanceOf(minter1)).toNumber() - balance;

            assert.equal(claimedWithKids, i === 7 ? 0 : Math.floor(lastClaim / 2));
            lastClaim = claimedWithKids;
        }
    });
});

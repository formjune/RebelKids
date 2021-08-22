const RebelKids = artifacts.require('RebelKids');

PRICE = 60000000000000000;

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

let minter1;
let minter2;
let minter3;
let minter4;
let give1;
let give2;

contract('RebelKids test', async accounts => {
    it('Test configuration', async () => {
        minter1 = (await web3.eth.getAccounts())[1];
        minter2 = (await web3.eth.getAccounts())[2];
        minter3 = (await web3.eth.getAccounts())[3];
        minter4 = (await web3.eth.getAccounts())[4];
        give1 = (await web3.eth.getAccounts())[5];
        give2 = (await web3.eth.getAccounts())[6];
    });
    it('Giveaway 6 tokens, reserve 2', async () => {
        const instance = await RebelKids.deployed();
        await instance.giftTokens([minter2, minter2, minter2, minter2]);
        await instance.giftTokens([minter3, minter3]);
        await instance.sendTokensToOwner(2);
        assert.equal((await instance.balanceOf(minter2)).toNumber(), 4);
        assert.equal((await instance.balanceOf(minter3)).toNumber(), 2);
        assert.equal((await instance.balanceOf(await instance.owner())).toNumber(), 2);
    });
    it('Try mint right before deploy', async () => {
        const instance = await RebelKids.deployed();
        await expectThrowsAsync(
            async () => await instance.mint(1, {value: PRICE}),
            'Returned error: VM Exception while processing transaction: revert This sale has not started. -- Reason given: This sale has not started..'
        );
    });
    it('Config presale', async () => {
        const instance = await RebelKids.deployed();
        await instance.setPresaleActive(true);
        await instance.setReservedSupply(666);
        await instance.setMaxMintsPerWallet(222);
        await instance.setPresaleSupply(666);
        let presaleSupply = await instance.presaleSupply();
        let reservedSupply = await instance.reservedSupply();
        assert.equal(presaleSupply.toNumber(), 666);
        assert.equal(reservedSupply.toNumber(), 666);
    });
    it('Successful presale to first minter', async () => {
        const instance = await RebelKids.deployed();
        await instance.mint(111, {
            from: minter1,
            value: PRICE * 111
        });
        await instance.mint(111, {
            from: minter1,
            value: PRICE * 111
        });
        let presaleSupply = await instance.presaleSupply();
        let balance = await instance.balanceOf(minter1);
        assert.equal(presaleSupply.toNumber(), 444);
        assert.equal(balance.toNumber(), 222);
    });
    it('Trying to violate \'mint limit per wallet\' constraint', async () => {
        const instance = await RebelKids.deployed();
        await expectThrowsAsync(
            async () => await instance.mint(1, {
                from: minter1,
                value: PRICE
            }),
            'Returned error: VM Exception while processing transaction: revert Can\'t mint RebelKids more than maxMintsPerWallet -- Reason given: Can\'t mint RebelKids more than maxMintsPerWallet.'
        );
        await expectThrowsAsync(
            async () => await instance.mint(223, {
                from: minter2,
                value: PRICE * 223
            }),
            'Returned error: VM Exception while processing transaction: revert Can\'t mint RebelKids more than maxMintsPerWallet -- Reason given: Can\'t mint RebelKids more than maxMintsPerWallet.'
        );
    });
    it('Presale to minter2, minter3', async () => {
        const instance = await RebelKids.deployed();
        await instance.mint(222, {
            from: minter2,
            value: PRICE * 222
        });
        await instance.mint(222, {
            from: minter3,
            value: PRICE * 222
        });

        let presaleSupply = await instance.presaleSupply();
        let balance1 = await instance.balanceOf(minter1);
        let balance2 = await instance.balanceOf(minter2);
        let balance3 = await instance.balanceOf(minter3);
        assert.equal(presaleSupply.toNumber(), 0);
        assert.equal(balance1.toNumber(), 222);
        assert.equal(balance2.toNumber(), 222 + 4);
        assert.equal(balance3.toNumber(), 222 + 2);
        assert.equal((await instance.totalSupply()).toNumber(), 666 + 4 + 2 + 2);
    });
    it('Config main sale', async () => {
        const instance = await RebelKids.deployed();
        await instance.setPresaleActive(false);
        await instance.setSaleActive(true);
        await instance.setSalesStage(1);
        await instance.setMaxMintsPerWallet(2000);
    });
    it('Process main sale', async () => {
        const instance = await RebelKids.deployed();
        await instance.mint(2000, {
            from: minter1,
            value: PRICE * 2000
        });
        await instance.mint(2000, {
            from: minter2,
            value: PRICE * 2000
        });
        await instance.mint(1326, {
            from: minter3,
            value: PRICE * 1326
        });
        let balance1 = await instance.balanceOf(minter1);
        let balance2 = await instance.balanceOf(minter2);
        let balance3 = await instance.balanceOf(minter3);
        assert.equal(balance1.toNumber(), 2000 + 222);
        assert.equal(balance2.toNumber(), 2000 + 222 + 4);
        assert.equal(balance3.toNumber(), 1326 + 222 + 2);
        assert.equal((await instance.totalSupply()).toNumber(), 2000 + 2000 + 1326 + 666 + 4 + 2 + 2);
    });
    it('Try to mint reserved tokens', async () => {
        const instance = await RebelKids.deployed();
        await expectThrowsAsync(
            async () => await instance.mint(1, {
                from: minter4,
                value: PRICE
            }),
            'Returned error: VM Exception while processing transaction: revert The amount of tokens you are trying to mint exceeds the MAX_SUPPLY - reservedSupply. -- Reason given: The amount of tokens you are trying to mint exceeds the MAX_SUPPLY - reservedSupply..'
        );
    });
    it('Airdrop', async () => {
        const instance = await RebelKids.deployed();
        let addresses = [];
        for (let i = 0; i < 666; i++) {
            addresses.push(minter4);
        }
        await instance.giftTokens(addresses);
        let balance4 = await instance.balanceOf(minter4);
        assert.equal(balance4.toNumber(), 666);
        assert.equal((await instance.totalSupply()).toNumber(), 6666);
    });
    it('Try to mint over the MAX SUPPLY LIMIY', async () => {
        const instance = await RebelKids.deployed();
        await expectThrowsAsync(
            async () => await instance.mint(1, {
                from: minter4,
                value: PRICE
            }),
            'Returned error: VM Exception while processing transaction: revert All NFTs have been minted. -- Reason given: All NFTs have been minted..'
        );
    });
});
const yargs = require('yargs');
const fs = require('fs');


const argv = yargs
    .option('input-file', {
        alias: 'i',
        demandOption: true,
        description: 'File with addresses',
        type: 'string'
    })
    .option('contract', {
        alias: 'c',
        description: 'File with addresses',
        demandOption: true,
        type: 'string'
    })
    .option('batch-size', {
        description: 'Batch mint size',
        demandOption: false,
        type: 'number'
    })
    .help()
    .alias('help', 'h')
    .argv;

async function makeGiftTransaction(contract, fromAddress, to, nonce) {
    return contract
        .giftToken(to, {
            from: fromAddress
        })
        .on('confirmation', function (confirmationNumber, receipt) {
            if (confirmationNumber == 2) {
                console.log(`Gift sent to ${to}`);
            }
        })
        .on('error', function (error, receipt) {
            console.error(`Couldn't send gift to ${to}`, error)
        });
}

let sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

module.exports = async function (callback) {
    try {
        const callerAddress = (await web3.eth.getAccounts())[0];
        const batchSize = argv.batchSize || 5;
        const fileName = argv.inputFile;
        let contract = artifacts.require(argv.contract);
        if (!contract.isDeployed()) {
            console.error('Contract ' + argv.contract + ' not deployed!');
            return -1;
        }
        contract = await contract.deployed();
        let contractOwner = await contract.owner.call();
        if (callerAddress !== contractOwner) {
            console.error(`Caller address ${callerAddress}; Contract owner address is ${contractOwner}.`);
            callback();
            return -1;
        }

        const addresses = fs.readFileSync(fileName, 'utf8').trim().split(/\r?\n/);
        console.log(`Processing ${addresses.length} addresses`);
        for (let i = 0; i < addresses.length; i += batchSize) {
            let chunk = addresses.slice(i, i + batchSize);
            console.log(`Processing ${i + 1}...${Math.min(i + batchSize, addresses.length)} addresses`);
            let nonce = await web3.eth.getTransactionCount(callerAddress, 'pending');
            let txs = chunk.map(function (adr, index) {
                makeGiftTransaction(contract, callerAddress, adr, nonce + index)
            });
            await Promise.all(txs);
            await sleep(10000)
        }
        // callback();
    } catch (e) {
        callback(e);
    }
};
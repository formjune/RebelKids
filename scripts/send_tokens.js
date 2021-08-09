const yargs = require('yargs');
const fs = require('fs');
const winston = require('winston');

const logger = winston.createLogger({
    format: winston.format.combine(
        winston.format.colorize({all: true}),
        winston.format.timestamp({
            format: 'YYYY-MM-DD HH:mm:ss',
        }),
        winston.format.splat(),
        winston.format.printf(
            info => `${info.timestamp} [${info.level}]: ${info.message}`
        )
    ),
    transports: [
        new winston.transports.File({
            filename: 'error.log',
            level: 'error'
        }),
        new winston.transports.File({filename: 'app.log'}),
        new winston.transports.Console()
    ],
});

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


let sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

let activeTransactions = 0;
let giftOkCount = 0;
let giftErrCount = 0;

async function awaitActiveTransactionsCountLTE(txCount) {
    while (activeTransactions > txCount) {
        await sleep(2000);
    }
}

async function makeGiftTransaction(contract, fromAddress, tos) {
    activeTransactions += 1;
    const tx = contract
        .giftTokens(tos, {
            from: fromAddress
        })
        .on('confirmation', function (confirmationNumber, receipt) {
            if (confirmationNumber === 2) {
                for (let to of tos) {
                    logger.info('Gift sent to %s', to);
                    giftOkCount += 1;
                }
                tx.removeListener('confirmation');
                tx.removeListener('error');
                activeTransactions -= 1;
            }
        })
        .on('error', function (error, receipt) {
            for (let to of tos) {
                logger.error('Couldn\'t send gift to %s', to);
                giftErrCount += 1;
            }
            logger.error(error);
            activeTransactions -= 1;
        });
    return tx;
}

module.exports = async function (callback) {
    try {
        const callerAddress = (await web3.eth.getAccounts())[0];
        const batchSize = argv.batchSize || 5;
        const fileName = argv.inputFile;
        let contract = artifacts.require(argv.contract);
        if (!contract.isDeployed()) {
            logger.error('Contract ' + argv.contract + ' not deployed!');
            callback();
            return -1;
        }
        contract = await contract.deployed();
        let contractOwner = await contract.owner.call();
        if (callerAddress !== contractOwner) {
            logger.error(`Caller address ${callerAddress}; Contract owner address is ${contractOwner}.`);
            callback();
            return -1;
        }

        const addresses = fs.readFileSync(fileName, 'utf8').trim().split(/\r?\n/);
        logger.info(`Processing ${addresses.length} addresses`);
        for (let i = 0; i < addresses.length; i += batchSize) {
            let chunk = addresses.slice(i, i + batchSize);
            logger.info(`Processing ${i + 1}...${Math.min(i + batchSize, addresses.length)} addresses`);
            await makeGiftTransaction(contract, callerAddress, chunk);
            await awaitActiveTransactionsCountLTE(0);
        }
        logger.info('Done! %d successful gifts, %d errors', giftOkCount, giftErrCount);
        callback();
    } catch (e) {
        logger.error(e);
        callback(e);
    }
};
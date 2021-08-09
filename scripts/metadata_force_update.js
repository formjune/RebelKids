const request = require('requestretry');
const yargs = require('yargs');


const argv = yargs
    .option('test', {
        alias: 't',
        description: 'Is test net',
        type: 'boolean',
        demandOption: true
    })
    .option('contract', {
        alias: 'c',
        description: 'Contract name',
        demandOption: true,
        type: 'string'
    })
    .option('delay', {
        alias: 'd',
        description: 'Delay between requests(ms)',
        type: 'number'
    })
    .option('retries-num', {
        alias: 'r',
        description: 'Number of retries',
        type: 'number'
    })
    .option('start', {
        alias: 's',
        description: 'Start tokenId',
        demandOption: true,
        type: 'number',
    })
    .option('end', {
        alias: 'e',
        description: 'End tokenId',
        demandOption: true,
        type: 'number',
    })
    .help()
    .alias('help', 'h')
    .argv;

let sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

module.exports = async function (callback) {
    try {
        const contract = await artifacts.require(argv.contract).deployed();
        const contractAddress = contract.address;
        const delay = argv.delay || 200;
        const retries = argv.retriesNum || 3;
        const start = argv.start;
        const end = argv.end;
        const host = yargs.test ? 'https://testnets-api.opensea.io' : 'https://api.opensea.io';
        for (let i = start; i <= end; i++) {
            console.log(`Updating ${i}-th token`);
            const response = await request({
                url: `${host}/api/v1/asset/${contractAddress}/${i}/?force_update=true`,
                json: true,
                maxAttempts: retries,
                retryDelay: delay,
                retryStrategy: request.RetryStrategies.HTTPOrNetworkError
            }).then(function (response) {
                if (response.statusCode === 200) {
                    console.log(`Successful update of ${i}-th token`);
                } else {
                    console.error(`Couldn't update ${i}-th token, code=${response.statusCode}`);
                }
            }).catch(function (error) {
                console.error(error);
            });
            await response;
            await sleep(delay);
        }
        callback();
    } catch (e) {
        callback(e);
    }
};
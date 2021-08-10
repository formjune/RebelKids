const yargs = require('yargs');
const fs = require('fs');


const argv = yargs
    .option('block-number', {
        alias: 'i',
        demandOption: true,
        description: 'block number',
        type: 'number'
    })
    .option('contract', {
        alias: 'c',
        description: 'Contract name',
        demandOption: true,
        type: 'string'
    })
    .option('output-file', {
        alias: 'o',
        description: 'Output file',
        demandOption: true,
        type: 'string'
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

module.exports = async function (callback) {
    try {
        let contract = await artifacts.require(argv.contract);
        contract.web3.eth.defaultBlock = argv.blockNumber;
        contract = await contract.deployed();
        let totalSupply = await contract.totalSupply();
        console.log(`End token = min(totalSupply=${totalSupply}, end=${argv.end}`);
        console.log(`Dumping owners of ${contract.address}, tokens=[${argv.start}...${Math.min(totalSupply, argv.end)}]`);
        let owners = [];
        for (let i = argv.start; i <= Math.min(argv.end, totalSupply); i++) {
            let owner = await contract.ownerOf(i);
            console.log(i, owner);
            owners.push([i, owner]);
            if (i % 10 === 0) {
                console.log(`${i}th token dumped`);
            }
        }
        let data = owners.map(function ([i, owner]) {
            return `${i} ${owner}`;
        }).join('\n') + '\n';
        console.log(`Writing owners`);
        fs.writeFileSync(argv.outputFile, data);
        callback();
    } catch (e) {
        callback(e);
    }
};
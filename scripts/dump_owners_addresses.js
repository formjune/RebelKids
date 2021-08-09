const yargs = require('yargs');
const fs = require('fs');
const winston = require('winston');

const argv = yargs
    .option('block-number', {
        alias: 'i',
        demandOption: true,
        description: 'block number',
        type: 'string'
    })
    .option('contract', {
        alias: 'c',
        description: 'Contract name',
        demandOption: true,
        type: 'string'
    })
    .help()
    .alias('help', 'h')
    .argv;

module.exports = async function (callback) {
    try {

        callback();
    } catch (e) {
        callback(e);
    }
};
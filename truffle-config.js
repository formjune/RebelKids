require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const { ALCHEMY_API_KEY, MNEMONIC, ETHERSCAN_API_KEY } = process.env;


module.exports = {
    plugins: [
        'truffle-plugin-verify'
    ],
    api_keys: {
        etherscan: ETHERSCAN_API_KEY
    },

    networks: {
        development: {
            host: '127.0.0.1',     // Localhost (default: none)
            port: 7545,            // Standard Ethereum port (default: none)
            network_id: '*',       // Any network (default: none)
            gas: 6721975,
        },
        rinkeby: {
            provider: () =>
            new HDWalletProvider(MNEMONIC, `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`),
            network_id: 4,
            gas: 5000000,
            timeoutBlocks: 200,
            skipDryRun: true,
            production: true
        },
        ropstein: {provider: () =>
            new HDWalletProvider(MNEMONIC, `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`),
            network_id: 3,
            gas: 5000000,
            timeoutBlocks: 200,
            skipDryRun: true,
            production: true
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: '0.8.6',
            settings: {          // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200
                },
            }
        }
    },

    db: {
        enabled: false
    }
};

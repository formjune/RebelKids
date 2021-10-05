require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const {createProvider} = require('@rarible/trezor-provider');


const {
    ALCHEMY_API_KEY,
    MNEMONIC,
    ETHERSCAN_API_KEY
} = process.env;


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
            gas: 1000000000,
            gasPrice: 20000000000,
        },
        ropsten: {
            provider: () => createProvider({
                url: `wss://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
                path: "m/44'/60'/0'/0/0",
                chainId: 3
            }),
            network_id: 3,
            networkCheckTimeout: 60 * 1000,
            gas: 5000000,
            timeoutBlocks: 200,
            skipDryRun: true,
            production: true
        },
        rinkebyTrezor: {
            provider: () => createProvider({
                url: `wss://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
                path: "m/44'/60'/0'/0/0",
                chainId: 4
            }),
            network_id: 4,
            networkCheckTimeout: 60 * 1000,
            gas: 5000000,
            timeoutBlocks: 200,
            skipDryRun: true,
            production: true
        },
        rinkeby: {
            provider: () => new HDWalletProvider(MNEMONIC, `wss://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`),
            network_id: 4,
            networkCheckTimeout: 60 * 1000,
            gas: 5000000,
            timeoutBlocks: 200,
            skipDryRun: true,
            production: true
        },
        mainnet: {
            provider: () => createProvider({
                url: `wss://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
                path: "m/44'/60'/0'/0/0",
                chainId: 1
            }),
            network_id: 1,
            networkCheckTimeout: 60 * 1000,
            gas: 1400000,
            gasPrice: 90 * 1000000000,
            timeoutBlocks: 200,
            skipDryRun: false,
            confirmations: 2,
            production: true
        },
        mainnetMnemonics: {
            provider: () => new HDWalletProvider(MNEMONIC, `https://eth-mainnet.alchemyapi.io/v2/M8JEPF27JCIjmqKN-Y4I1hpvzD2l_UCx`),
            network_id: 1,
            networkCheckTimeout: 60 * 1000,
            gas: 1400000,
            gasPrice: 90 * 1000000000,
            timeoutBlocks: 200,
            skipDryRun: false,
            confirmations: 2,
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

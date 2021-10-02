require("@nomiclabs/hardhat-waffle");
// require('@nomiclabs/hardhat-etherscan') // need to verify smart contracts

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {},
    },

    // define all compiler versions here
    solidity: {
        compilers: [
            {
                version: "0.8.7",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.6.12",
                settings: {
                    optimizer: {
                        enabled: false,
                        runs: 0,
                    },
                },
            },
        ],
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },
    mocha: {
        timeout: 20000,
    },
};

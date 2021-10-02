import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { Fixture } from "ethereum-waffle";
import { NFT } from "../typechain/NFT.d";

import { Greeter } from "../typechain/Greeter.d";

declare module "mocha" {
    export interface Context {
        greeter: Greeter;
        loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
        signers: Signers;
    }
    export interface Context {
        nft: NFT;
        loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
        signers: Signers;
    }
}

export interface Signers {
    admin: SignerWithAddress;
}

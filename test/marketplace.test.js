const { ethers, waffle } = require("hardhat");
const { expect, use } = require("chai");
const { solidity } = require("ethereum-waffle");
const { BigNumber, utils, provider } = ethers;

use(solidity);

const ZERO = new BigNumber.from("0");
const ONE = new BigNumber.from("1");
const ONE_ETH = utils.parseUnits("1", 5);
const LESS_ETH = utils.parseUnits("0.01", 5);
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const MAX_UINT = "115792089237316195423570985008687907853269984665640564039457584007913129639935";

describe("NFT", () => {
    let marketplace, nft, tokenId;
    let deployer, user;

    it("it should deploy marketplace contract", async function () {
        [deployer, taker, maker] = await ethers.getSigners();
        const marketplaceContract = await ethers.getContractFactory("NFTMarket");
        marketplace = await marketplaceContract.deploy();

        const nftContract = await ethers.getContractFactory("NFT");
        nft = await nftContract.deploy();
    });

    it("it should mint token", async function () {
        const token = await nft.connect(maker).mint("smaple uri");
        tokenId = await nft.currentId();
    });

    it("it should not create marketplace item", async function () {
        await expect(marketplace.connect(maker).createMarketItem(nft.address, tokenId, ONE_ETH)).to.be.reverted;
    });

    it("it should create marketplace item", async function () {
        await nft.connect(maker).setApprovalForAll(marketplace.address, true);
        await expect(marketplace.connect(maker).createMarketItem(nft.address, tokenId, ONE_ETH)).to.emit(marketplace, "MarketItemCreated");
    });

    it("it should create marketplace sale", async function () {
        expect(await nft.ownerOf(tokenId)).to.not.equal(taker.address);

        await expect(marketplace.connect(taker).createMarketSale(nft.address, tokenId, { value: ONE_ETH })).to.emit(
            marketplace,
            "ItemSold",
        );

        expect(await nft.ownerOf(tokenId)).to.equal(taker.address);
    });
});

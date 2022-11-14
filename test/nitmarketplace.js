const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NITMarketplace Contract", async () => {
    let NITMarketplace, hardhatNITMarketplace, owner, addr1, addr2, addrs, contractName = "NITMarkerplace", contractSymbol = "NIT";

    beforeEach(async() => {
        
        NITMarketplace = await ethers.getContractFactory("NITMarketplace");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        hardhatNITMarketplace = await NITMarketplace.deploy(contractName, contractSymbol, "");

    });

    describe("NITMarketplace Deployed", async () => {

        it("Should have a marktplace name, symbol and owner", async () => {
            
            expect(await hardhatNITMarketplace.name()).to.equals(contractName);
            expect(await hardhatNITMarketplace.symbol()).to.equals(contractSymbol);
            expect(await hardhatNITMarketplace.owner()).to.equals(owner.address);
            
        })

    });

    describe("Mint", async () => { 
        const tokenId = 1;
        it("Should mint the tokenId 1", async () => {
            await hardhatNITMarketplace.safeMint(owner.address, tokenId);
            expect(await hardhatNITMarketplace.ownerOf(tokenId)).to.equals(owner.address);
        });

    });

});
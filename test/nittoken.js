const { expect } = require("chai")
const { ethers } = require("hardhat");

describe("NITToken Contract", async () => {

    let hardhatNITToken, NITToken, owner, addr1, addr2, addrs, name = "NITESH", symbol = "NIT", decimals = 18, initialAmount = 100000, address0 = "0x0000000000000000000000000000000000000000";

    beforeEach(async () => {
        NITToken = await ethers.getContractFactory("NITToken");
        [owner, addr1, addr2, addrs] = await ethers.getSigners();
        hardhatNITToken = await NITToken.deploy(name, symbol, decimals);
        await hardhatNITToken.mint(addr1.address, initialAmount);
        await hardhatNITToken.mint(addr2.address, initialAmount);
        await hardhatNITToken.mint(owner.address, initialAmount);

    });

    describe("Deployment", async () => {

        it("Should have a correct owner, name, symbol", async() => {
            expect(await hardhatNITToken.owner()).to.equals(owner.address);
            expect(await hardhatNITToken.name()).to.equals(name);
            expect(await hardhatNITToken.symbol()).to.equals(symbol);
            expect(await hardhatNITToken.decimals()).to.equals(decimals);
        });

    });

    describe("Transactions", async () => {

        it("Should send transaction from addr1 to addr2", async () => {
            const amount = 1000;
            await hardhatNITToken.connect(addr1).transfer(addr2.address, amount);
            expect(await hardhatNITToken.balanceOf(addr1.address)).to.equal(initialAmount - amount);
            expect(await hardhatNITToken.balanceOf(addr2.address)).to.equal(initialAmount + amount);
        });

        it("Should fail with insufficient balance message", async () => {        
            const amount = 10000000;
            await expect(hardhatNITToken.connect(addr1).transfer(addr2.address, amount)).to.be.revertedWith("insufficient balance");
        });

        it("Should fail with Invalid to adress message", async () => {        
            const amount = 10000000;
            await expect(hardhatNITToken.connect(addr1).transfer(address0, amount)).to.be.revertedWith("Invalid to adress");
        });

        it("Should perform on multiple transaction", async () => {

            const amount = 1000;
            await hardhatNITToken.transfer(addr2.address, amount);
            await hardhatNITToken.connect(addr1).transfer(addr2.address, amount);

            expect(await hardhatNITToken.balanceOf(addr1.address)).to.be.equal(initialAmount - amount);
            expect(await hardhatNITToken.balanceOf(owner.address)).to.be.equal(initialAmount - amount);
            expect(await hardhatNITToken.balanceOf(addr2.address)).to.be.equal(initialAmount + (amount * 2));

            await expect(hardhatNITToken.transfer(addr2.address, initialAmount)).to.be.revertedWith("insufficient balance");
            await expect(hardhatNITToken.connect(addr1).transfer(addr2.address, initialAmount)).to.be.revertedWith("insufficient balance");
        });



    });

})
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("TITOToken Contract", () => {
    
    let TITOToken, OITTToken, owner, addr1, addr2, addrs, hardhatTITOToken, hardhatOITTToken;

    beforeEach(async() => {
        OITTToken = await ethers.getContractFactory("OITTToken");
        TITOToken = await ethers.getContractFactory("TITOToken");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        hardhatOITTToken = await OITTToken.deploy("ONEISTOTWO", "OITT");
        hardhatTITOToken = await TITOToken.deploy("TWOISTOONE", "TITO", hardhatOITTToken.address);
        // console.log( await hardhatOITTToken.balanceOf(owner.address));
    });

    describe("Deployment", async () => {

        it("it should have OITT address", async () => {
            const oitt = await hardhatTITOToken.OITT();
            expect(oitt).to.equal(hardhatOITTToken.address);
        });
    });

    describe("Deposite OITT token", async () => {

        it("Should give error for allowance", async () => {
            const depositOITTToken = 100;
            await expect(hardhatTITOToken.deposit(depositOITTToken)).to.be.revertedWith("insufficient allowance");
        });

        it("Should allow to deposite amount and in return send TITT token to users wallet", async() => {
            const amount = 1000000;
            await hardhatOITTToken.approve(hardhatTITOToken.address, amount);
            const depositOITTToken = 100;
            await hardhatTITOToken.deposit(depositOITTToken);
            const TITOTokenBalance = await hardhatTITOToken.balanceOf(owner.address);
            expect(TITOTokenBalance).to.equal(depositOITTToken * 2);
        });

        it("Should allow to deposite amount by other user then admin", async() => {
            const amount = 10000;
            await hardhatOITTToken.transfer(addr1.address, amount);
            const addr1OITOBalance = await hardhatOITTToken.balanceOf(addr1.address);
            await hardhatOITTToken.connect(addr1).approve(hardhatTITOToken.address, amount);
            const depositeAmount = 1000;
            await hardhatTITOToken.connect(addr1).deposit(depositeAmount);
            const addr1TITObalance = await hardhatTITOToken.balanceOf(addr1.address);
            expect(addr1TITObalance).to.equal(depositeAmount * 2);
            expect(await hardhatOITTToken.balanceOf(addr1.address)).to.equal(amount - depositeAmount);
        });

    });

    describe("Withdraw OITT token", async () => {
        
        it("Should fail insufficient balance of TITO tokens",async () => {
            const amount = 1000;
            await expect(hardhatTITOToken.withdraw(amount)).to.be.revertedWith("insufficient balance");
        });

        it("Should successfully withdraw the amount", async() => {

            const amount = 1000000;
            await hardhatOITTToken.approve(hardhatTITOToken.address, amount);
            const depositOITTToken = 100;
            await hardhatTITOToken.deposit(depositOITTToken);
            const TITOTokenBalance = await hardhatTITOToken.balanceOf(owner.address);
            await hardhatTITOToken.withdraw(depositOITTToken);
            expect(await hardhatTITOToken.balanceOf(owner.address)).to.equal(0);

        });

        it("Should successfully withdraw the amount from different account", async() => {
        
            const amount = 10000;
            await hardhatOITTToken.transfer(addr1.address, amount);
            const addr1OITOBalance = await hardhatOITTToken.balanceOf(addr1.address);
            await hardhatOITTToken.connect(addr1).approve(hardhatTITOToken.address, amount);
            const depositeAmount = 1000;
            await hardhatTITOToken.connect(addr1).deposit(depositeAmount);
            const withdrawAmount = 500;
            await hardhatTITOToken.connect(addr1).withdraw(withdrawAmount);

            expect(await hardhatOITTToken.balanceOf(addr1.address)).to.equal(amount - withdrawAmount);
            expect(await hardhatTITOToken.balanceOf(addr1.address)).to.equal((depositeAmount - withdrawAmount) * 2);
        });

    });

});
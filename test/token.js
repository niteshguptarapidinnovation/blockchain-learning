const {expect} = require('chai');
const { ethers } = require('hardhat');

describe("Token Contract", async () => {
    let Token, hardhaToken, owner, addr1, addr2, addrs;

    beforeEach(async () => {
        Token = await ethers.getContractFactory("Token");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        hardhaToken = await Token.deploy();
    });

    describe("Deployment", async () => {
        it("Should set the right owner", async () => {
            expect(await hardhaToken.owner()).to.equal(owner.address);
        });

        it("Should assign totalSupply to owner", async () => {
            expect(await hardhaToken.totalSupply()).to.equal(await hardhaToken.balanceOf(owner.address));
        });
    });

    describe("Transactions", async() => {
        it("Should transfer tokens between accounts", async () => {
            // Transfer from owner account to address1
            const amount1 = 10;
            await hardhaToken.transfer(addr1.address, amount1);
            expect(await hardhaToken.balanceOf(addr1.address)).to.equal(amount1);
            expect(await hardhaToken.balanceOf(owner.address)).to.equal((await hardhaToken.totalSupply()) - amount1);
            
            // Transfer tokens from address1 to address2
            amount2 = 5;
            await hardhaToken.connect(addr1).transfer(addr2.address, amount2);
            expect(await hardhaToken.balanceOf(addr1.address)).to.equal(amount1 - amount2);
            expect(await hardhaToken.balanceOf(addr2.address)).to.equal(amount2);
        });

        it('Should fail if sender does not have enough balance', async () => {
            const intialOwnerBalance = await hardhaToken.balanceOf(owner.address);
            await expect(hardhaToken.connect(addr1).transfer(addr2.address, 1)).to.be.revertedWith("Not enougth tokens");
            expect(await hardhaToken.balanceOf(owner.address)).to.equal(intialOwnerBalance);
        });

        it("it should update balances after transfers", async () => {
            const intialOwnerBalance = await hardhaToken.balanceOf(owner.address);
            const amount1 = 5, amount2 = 10;
            await hardhaToken.transfer(addr1.address, amount1);
            await hardhaToken.transfer(addr2.address, amount2);

            const finalOwnerBalance = await hardhaToken.balanceOf(owner.address);
            expect(finalOwnerBalance).to.equal(intialOwnerBalance - amount1 - amount2);
            
            const address1Balance = await hardhaToken.balanceOf(addr1.address);
            expect(address1Balance).to.equal(amount1);

            const addr2Balance = await hardhaToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(amount2);

        });
    })

});
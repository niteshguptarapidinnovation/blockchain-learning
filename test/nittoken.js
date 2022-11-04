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

    describe("Transfer Ownership", async () => {

        it("Should transfer ownership to address1", async () => {
            await hardhatNITToken.transferOwnership(addr1.address);
            expect(await hardhatNITToken.owner()).to.equal(addr1.address);
        });

        it("Should fail with Not the Owner", async () => {
            await expect(hardhatNITToken.connect(addr1).transferOwnership(addr2.address)).to.be.revertedWith("Not the Owner");
        });

        it("Should fail with Not valid address", async() => {
            await expect(hardhatNITToken.transferOwnership(address0)).to.be.revertedWith("Not valid address");
        });

        it("Should fail with Already owner", async() => {
            await expect(hardhatNITToken.transferOwnership(owner.address)).to.be.revertedWith("Already owner");
        });

        it("Should transfer ownership multiple times", async() => {
            await hardhatNITToken.transferOwnership(addr1.address);
            expect(await hardhatNITToken.owner()).to.equal(addr1.address);
            await hardhatNITToken.connect(addr1).transferOwnership(addr2.address);
            expect(await hardhatNITToken.owner()).to.equal(addr2.address);
            await hardhatNITToken.connect(addr2).transferOwnership(owner.address);
            expect(await hardhatNITToken.owner()).to.equal(owner.address);
        });
    });

    describe("Mint", () => {

        it("Should mint amount to owners wallet address",async () => {
            await hardhatNITToken.mint(owner.address, initialAmount);
            expect(await hardhatNITToken.balanceOf(owner.address)).to.equal(initialAmount * 2);
        });

        it("Should mint amount from addr1 wallet address",async () => {
            await hardhatNITToken.mint(addr1.address, initialAmount);
            expect(await hardhatNITToken.balanceOf(addr1.address)).to.equal(initialAmount * 2);
        });

        it("Should fail with addr1 wallet address",async () => {
            await expect(hardhatNITToken.connect(addr1).mint(addr1.address, initialAmount)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should fail with 0 amount",async () => {
            await expect(hardhatNITToken.mint(addr1.address, 0)).to.be.revertedWith("Invalid amount");
        });

        it("Should fail if minting token with wallet address 0",async () => {
            await expect(hardhatNITToken.mint(address0, initialAmount)).to.be.revertedWith("cannot minted to address 0");
        });

        it("Should pass if transfer ownership to address1 and mint tokens to addr2",async () => {
            await hardhatNITToken.transferOwnership(addr1.address);
            await hardhatNITToken.connect(addr1).mint(addr2.address, initialAmount);
            expect(await hardhatNITToken.balanceOf(addr2.address)).to.equal( initialAmount * 2 );
        });
    });

    describe("Burn", async () => {

        it("Should burn amount from owners wallet address",async () => {
            await hardhatNITToken.burn(owner.address, initialAmount);
            expect(await hardhatNITToken.balanceOf(owner.address)).to.equal(initialAmount - initialAmount);
        });

        it("Should burn amount from addr1 wallet address",async () => {
            await hardhatNITToken.burn(addr1.address, initialAmount);
            expect(await hardhatNITToken.balanceOf(addr1.address)).to.equal(initialAmount - initialAmount);
        });

        it("Should fail with addr1 wallet address",async () => {
            await expect(hardhatNITToken.connect(addr1).burn(addr1.address, initialAmount)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should fail with 0 amount",async () => {
            await expect(hardhatNITToken.burn(addr1.address, 0)).to.be.revertedWith("Invalid amount");
        });

        it("Should fail if burning token with wallet address 0",async () => {
            await expect(hardhatNITToken.burn(address0, initialAmount)).to.be.revertedWith("Invalid account");
        });

        it("Should fail if burning token more then the user owns",async () => {
            await expect(hardhatNITToken.burn(addr1.address, initialAmount + 5)).to.be.revertedWith("insufficient balance");
        });


        it("Should pass if transfer ownership to address1 and burn tokens to addr2",async () => {
            await hardhatNITToken.transferOwnership(addr1.address);
            await hardhatNITToken.connect(addr1).burn(addr2.address, initialAmount);
            expect(await hardhatNITToken.balanceOf(addr2.address)).to.equal( initialAmount - initialAmount );
        });        

    });

    describe("Approve", async () => {

        it("Should give a access to address1 for owners balance", async() => {
            await hardhatNITToken.approve(addr1.address, initialAmount);
            expect(await hardhatNITToken.allowance(owner.address, addr1.address)).to.equal(initialAmount);
        });

        it("Should give a access to address2 for address1 balance", async() => {
            await hardhatNITToken.connect(addr1).approve(addr2.address, initialAmount);
            expect(await hardhatNITToken.allowance(addr1.address, addr2.address)).to.equal(initialAmount);
        });


        it("Should fail to give approval to address 0", async() => {
            await expect(hardhatNITToken.approve(address0, initialAmount)).to.be.revertedWith("Invalid spender");
        });

        it("Should fail to give approval to amount 0", async() => {
            await expect(hardhatNITToken.approve(addr1.address, 0)).to.be.revertedWith("Invalid amount");
        });

        describe("Increase Allowance", () => {

            it("Should increase allownace to address1 for owners balance", async() => {
                await hardhatNITToken.approve(addr1.address, initialAmount);
                expect(await hardhatNITToken.allowance(owner.address, addr1.address)).to.equal(initialAmount);
                await hardhatNITToken.increaseAllowance(addr1.address, initialAmount);
                expect(await hardhatNITToken.allowance(owner.address, addr1.address)).to.equal(initialAmount * 2);
            });            

            it("Should increase allownace to address2 for address1 balance", async() => {
                await hardhatNITToken.connect(addr1).approve(addr2.address, initialAmount);
                expect(await hardhatNITToken.allowance(addr1.address, addr2.address)).to.equal(initialAmount);
                await hardhatNITToken.connect(addr1).increaseAllowance(addr2.address, initialAmount);
                expect(await hardhatNITToken.allowance(addr1.address, addr2.address)).to.equal(initialAmount * 2);
            });

            it("Should fail for 0 amount", async() => {
                await expect(hardhatNITToken.approve(addr1.address, 0)).to.be.revertedWith("Invalid amount");
            });

            it("Should fail for address 0", async() => {
                await expect(hardhatNITToken.approve(address0, initialAmount)).to.be.revertedWith("Invalid spender");
            });

        });


        describe("Decrease Allowance", () => {

            it("Should decrease allownace to address1 for owners balance", async() => {
                const amount = 1000;
                await hardhatNITToken.approve(addr1.address, initialAmount);
                expect(await hardhatNITToken.allowance(owner.address, addr1.address)).to.equal(initialAmount);
                await hardhatNITToken.decreaseAllowance(addr1.address, amount);
                expect(await hardhatNITToken.allowance(owner.address, addr1.address)).to.equal(initialAmount - amount);
            });            

            it("Should decrease allownace to address2 for address1 balance", async() => {
                const amount = 1000;
                await hardhatNITToken.connect(addr1).approve(addr2.address, initialAmount);
                expect(await hardhatNITToken.allowance(addr1.address, addr2.address)).to.equal(initialAmount);
                await hardhatNITToken.connect(addr1).decreaseAllowance(addr2.address, amount);
                expect(await hardhatNITToken.allowance(addr1.address, addr2.address)).to.equal(initialAmount - amount);
            });

            it("Should fail for 0 amount", async() => {
                await expect(hardhatNITToken.approve(addr1.address, 0)).to.be.revertedWith("Invalid amount");
            });

            it("Should fail for address 0", async() => {
                await expect(hardhatNITToken.approve(address0, initialAmount)).to.be.revertedWith("Invalid spender");
            });

        });
    });


    describe("Transfer From", async () => {

        it("Should send transaction from owners account by addr1", async () => {
            const amount = 1000;
            await hardhatNITToken.approve(addr1.address, initialAmount);
            await hardhatNITToken.connect(addr1).transferFrom(owner.address, addr2.address, amount);
            expect(await hardhatNITToken.balanceOf(owner.address)).to.equal(initialAmount - amount);
            expect(await hardhatNITToken.balanceOf(addr2.address)).to.equal(initialAmount + amount);
            expect(await hardhatNITToken.allowance(owner.address, addr1.address)).to.equal(initialAmount - amount);
        });

        it("Should fail with Invalid allowance message", async () => {        
            const amount = 1000;
            await hardhatNITToken.approve(addr1.address, amount);
            await expect(hardhatNITToken.connect(addr1).transferFrom(owner.address, addr2.address, initialAmount)).to.be.revertedWith("Invalid allowance");
        });

        it("Should fail with Invalid to address message", async () => {        
            const amount = 10000000;
            await hardhatNITToken.approve(addr1.address, amount);
            await expect(hardhatNITToken.connect(addr1).transferFrom(addr1.address, address0, amount)).to.be.revertedWith("Invalid to address");
        });

        it("Should fail with Invalid amount message", async () => {        
            const amount = 0;
            await expect(hardhatNITToken.connect(addr1).transferFrom(addr2.address, owner.address, amount)).to.be.revertedWith("Invalid amount");
        });
    });    

    describe("Blacklist", async() => {

        it("Should blacklist user",async () => {
            await hardhatNITToken.blackListAddress(addr1.address);
            expect(await hardhatNITToken.balanceOf(addr1.address)).to.equal(0);
            expect(await hardhatNITToken.isBlacklisted(addr1.address)).to.equal(true);
        });

        it("Should fail if normal user tries to blacklist", async () => {
            await expect(hardhatNITToken.connect(addr1).blackListAddress(addr1.address)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should fail if if try to blacklist address", async () => {
            await expect(hardhatNITToken.blackListAddress(address0)).to.be.revertedWith("Invalid address");
        });

        it("Should remove blacklist flag", async () => {
            await hardhatNITToken.blackListAddress(addr1.address);
            expect(await hardhatNITToken.balanceOf(addr1.address)).to.equal(0);
            expect(await hardhatNITToken.isBlacklisted(addr1.address)).to.equal(true);

            await hardhatNITToken.removedBlackListAddress(addr1.address);
            expect(await hardhatNITToken.balanceOf(addr1.address)).to.equal(initialAmount);
            expect(await hardhatNITToken.isBlacklisted(addr1.address)).to.equal(false);

        });

    });

})
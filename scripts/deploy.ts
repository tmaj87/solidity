const {ethers} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying from:", deployer.address);
    const accountBalance = await deployer.provider.getBalance(deployer.address);
    console.log("Account balance:", accountBalance.toString());
    const Token = await ethers.getContractFactory("TokenX");
    const token = await Token.deploy();
    console.log("Contract address:", await token.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
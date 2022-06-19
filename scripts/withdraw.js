const { ethers, getNamedAccounts } = require("hardhat");

async function main() {
    const deployer = (await getNamedAccounts()).deployer;
    const fundMe = await ethers.getContract("FundMe", deployer);
    await fundMe.withdraw();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

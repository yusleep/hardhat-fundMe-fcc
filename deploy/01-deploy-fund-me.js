// function deployFunc() {
//   console.log("Hi!");
// }

// module.exports.default = deployFunc;

// module.exports = async (hre) => {
//     const {getNamedAccounts, deployments} = hre;
//     // hre.getNamedAccounts
//     // hre.deployments
// };

const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  // 本地或者hardhat调试时，常用mock去模拟一些情况
  //   const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }
  const args = [ethUsdPriceFeedAddress];
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args, // put address feed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
};
module.exports.tags = ["all", "fundme"];

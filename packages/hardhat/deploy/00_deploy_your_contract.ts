import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, diamond } = hre.deployments;
  
  await diamond.deploy("GasLover", {
    from: deployer,
    autoMine: true,
    log: true,
    waitConfirmations: 1,
    // upgradeIndex: 0,
    facets: [
      "InitFacet",
      "InternalFacet",
      "MintFacet",
      "RenderFacet",
    ],
    execute: {
      contract: 'InitFacet',
      methodName: 'init',
      args: []
    },
  })
  
  var GasLover = await ethers.getContract("GasLover");
  
  for (var i = 0; i < 10; i++) {
    await GasLover.mint({
      gasPrice: ethers.utils.parseUnits(Math.round((Math.random() * 100)).toString(), "gwei"),
    });
  }
};

export default deployYourContract;

deployYourContract.tags = ["YourContract"];

import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

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
};

export default deployYourContract;

deployYourContract.tags = ["YourContract"];

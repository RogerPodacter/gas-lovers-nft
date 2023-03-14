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
    facets: [
      "InitFacet",
      "MintFacet",
      "RenderFacetWithENS",
      "ERC721AUpgradeable",
    ],
    execute: {
      contract: 'RenderFacetWithENS',
      methodName: 'initENS',
      args: []
    },
  })
};

export default deployYourContract;

deployYourContract.tags = ["YourContract"];

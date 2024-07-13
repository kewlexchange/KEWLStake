import { ethers } from "hardhat";
import {formatEther, parseEther, parseUnits} from "ethers/lib/utils";
import { Factory } from "../typechain";
import moment from "moment";
const {DiamondFacetList} = require("../libs/facets.js")
const {getSelectors, FacetCutAction} = require("../libs/diamond.js")

async function main() {
  ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);
  const [deployer, otherAccount] = await ethers.getSigners();
  // deploy DiamondCutFacet



  const KEWLDIAMONDFactory = await ethers.getContractFactory('KEWL')

    const KEWL = await KEWLDIAMONDFactory.deploy("KEWL STAKE","KEWL")
    await KEWL.deployed();
    const cut = []
    for (const FacetName of DiamondFacetList) {
      console.log("FACET NAME:",FacetName)
      const Facet = await ethers.getContractFactory(FacetName);
      // @ts-ignore
      const facet = await Facet.deploy()
      await facet.deployed()
      console.log(`${FacetName} deployed: ${facet.address}`)
      cut.push({target: facet.address, action: FacetCutAction.Add, selectors: getSelectors(facet)})
    }
    const tx = await KEWL.diamondCut(cut, ethers.constants.AddressZero, '0x');
    await tx.wait(1);

    console.log("Facets Added Successfuly.")


    const SettingsFacet = await ethers.getContractAt("Settings", KEWL.address);
    const VaultFacet = await ethers.getContractAt("Vault", KEWL.address);
    const FactoryFacet = await ethers.getContractAt("Factory",KEWL.address)


    const setKWLToken = await SettingsFacet.setKEWLToken("0xEd5740209FcF6974d6f3a5F11e295b5E468aC27c")
    await setKWLToken.wait();
    const setWETH9Token  = await SettingsFacet.setWETH9Token("0x721EF6871f1c4Efe730Dce047D40D1743B886946")
    await setWETH9Token.wait();

    const setCNS = await SettingsFacet.setCNS("0x1C55a6e9A736C6d86d9ff1ba4700e64583c18f50")
    await setCNS.wait();

    const setFeeReceiver = await SettingsFacet.setFeeReceiver(deployer.address);
    await setFeeReceiver.wait();



    console.log('IMON deployed:', KEWL.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

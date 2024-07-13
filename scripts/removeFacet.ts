import { ethers } from "hardhat";
const {DiamondFacetList} = require("../libs/facets.js")
const {getSelectors, FacetCutAction} = require("../libs/diamond.js")

async function main() {
    ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);
    const [deployer, otherAccount] = await ethers.getSigners();
    // deploy DiamondCutFacet


    const KEWL_DIAMOND_ADDRESS = ethers.constants.AddressZero

    const KEWLDIAMONDFactory = await ethers.getContractFactory('KEWLSTAKE')
    const KEWLDIAMOND = await KEWLDIAMONDFactory.attach("")
    await KEWLDIAMOND.deployed()
    console.log('KEWLDIAMOND deployed:', KEWLDIAMOND.address)


    const cut = []
    const facetList = ['OldVault'];

    for (const FacetName of facetList) {
       
        const facet = await ethers.getContractAt(FacetName,KEWLDIAMOND.address);
        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
            target: ethers.constants.AddressZero,
            action: FacetCutAction.Remove,
            selectors: getSelectors(facet)
        })
    }
    const tx = await KEWLDIAMOND.diamondCut(cut, ethers.constants.AddressZero, '0x');
    await tx.wait(2);
    console.log("Updated");

    console.log("DONE!");







}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

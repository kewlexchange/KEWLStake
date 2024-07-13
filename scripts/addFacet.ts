import { ethers } from "hardhat";
const {DiamondFacetList} = require("../libs/facets.js")
const {getSelectors, FacetCutAction} = require("../libs/diamond.js")

async function main() {
    ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);
    const [deployer, otherAccount] = await ethers.getSigners();
    // deploy DiamondCutFacet


    const KEWLSTAKECONTRACT = ethers.constants.AddressZero

    const KEWLSTAKEFACTORY = await ethers.getContractFactory('KEWLSTAKE')
    const KEWLSTAKE = await KEWLSTAKEFACTORY.attach(KEWLSTAKECONTRACT)
    await KEWLSTAKE.deployed()
    console.log('KEWLSTAKE deployed:', KEWLSTAKE.address)

    const cut = []
    const facetList = ['Vault'];
    for (const FacetName of facetList) {
        const Facet = await ethers.getContractFactory(FacetName);
        // @ts-ignore
        const facet = await Facet.deploy()
        await facet.deployed()
        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
            target: facet.address,
            action: FacetCutAction.Add,
            selectors: getSelectors(facet)
        })
    }
    const tx = await KEWLSTAKE.diamondCut(cut, ethers.constants.AddressZero, '0x');
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

import {time, loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import {expect, use} from "chai";
import {ethers} from "hardhat";
import {BigNumber} from "ethers";
import {AbiCoder, formatEther, formatUnits, parseEther, parseUnits} from 'ethers/lib/utils';
import moment from "moment";
import {base64} from "ethers/lib.esm/utils";

const {DiamondFacetList} = require("../libs/facets.js")

const {getSelectors, FacetCutAction} = require("../libs/diamond.js")
ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);

describe("Deploy KEWL STAKE", function () {
    
    async function deployKEWL() { 



        const [deployer, user1, user2, user3, user4, user5,user6,user7,user8,user9,user10] = await ethers.getSigners();
        console.log("DEPLOYER:",deployer.address)
        const KEWLFactory = await ethers.getContractFactory('KEWL')
        const KEWL = await KEWLFactory.deploy("KEWL STAKE","KEWL")
        await KEWL.deployed()
        console.log('KEWL deployed:', KEWL.address)

        const IMONTokenFactory = await ethers.getContractFactory("IMONToken");
        const IMONTokenContract = await IMONTokenFactory.deploy("KEWL TEST TOKEN", "KEWLTEST");

        const cut = []
        for (const FacetName of DiamondFacetList) {
            console.log("FACET NAME:", FacetName)
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

        const FactoryFacet = await ethers.getContractAt("Factory",KEWL.address);
        const SettingsFacet = await ethers.getContractAt("Settings",KEWL.address);



        const WRAPPED_TOKEN_FACTORY = await ethers.getContractFactory("WETH9")
        const WRAPEPD_TOKEN = await WRAPPED_TOKEN_FACTORY.deploy();

        const setIMONTokenAddress = await SettingsFacet.setKEWLToken(IMONTokenContract.address);
        await setIMONTokenAddress.wait();

        const setWETH9Token = await SettingsFacet.setWETH9Token(WRAPEPD_TOKEN.address);
        await setWETH9Token.wait();

        const setFeeReceiver = await SettingsFacet.setFeeReceiver(deployer.address);
        await setFeeReceiver.wait();



        return {
            KEWL,
            IMONTokenContract,
            FactoryFacet,
            SettingsFacet,
            deployer,
            user1,
            user2,
            user3,
            user4,
            user5,
            user6,
            user7,
            user8,
            user9,
            user10,
        };

    }

    describe("Deployment", function () {


        it("Reward Pools", async function(){

            const {
                KEWL,
                IMONTokenContract,
                FactoryFacet,
                SettingsFacet,
                deployer,
                user1,
                user2,
                user3,
                user4,
                user5,
                user6,
                user7,
                user8,
                user9,
                user10
            } = await loadFixture(deployKEWL);



        
            const amount = parseEther("1")
            const expiredAt = moment().add(1, 'year').unix();
            await IMONTokenContract.connect(deployer).mintAndTransferReward(deployer.address,amount);            

            console.log(`EXPIRED AT`, expiredAt)



            await IMONTokenContract.connect(deployer).approve(FactoryFacet.address,amount)
            await FactoryFacet.connect(deployer).create(IMONTokenContract.address,IMONTokenContract.address,amount,expiredAt);

            const stakePools = await FactoryFacet.fetch();
            console.log('stakePools',stakePools)
        
            
            const users = [deployer,user1,user2,user3,user4,user5,user6,user7, user8,user9,user10]

            for (const user of users) {

                const randomAmount = Math.floor(Math.random() * 10) + 1;
                const amount = parseEther(randomAmount.toString());

                await IMONTokenContract.connect(deployer).mintAndTransferReward(user.address,amount);
                await IMONTokenContract.deployed();
            

                const approveTx = await IMONTokenContract.connect(user).approve(FactoryFacet.address,amount);
                await approveTx.wait();

                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));
                await FactoryFacet.connect(user).stake(0,amount.div(100));

                
            }


            const blockNumBefore = await ethers.provider.getBlockNumber();
            const blockBefore = await ethers.provider.getBlock(blockNumBefore);
            const timestampBefore = blockBefore.timestamp;


            var tenDays = blockBefore.timestamp+(86400 * (366));
            await ethers.provider.send('evm_increaseTime', [tenDays]);
            await ethers.provider.send('evm_mine',[tenDays]);



            var totalReward = parseUnits("0",18);
            for (const user of users) {
                const rewardAmount = await FactoryFacet.pendingRewardsByPoolId(0,user.address,0);
                console.log(user.address, formatUnits(rewardAmount,18))
                totalReward = totalReward.add(rewardAmount)
                
            }
            console.log("Total Reward",formatUnits(totalReward,18))


            // UNSTAKE
            for (const user of users) {
                const beforeRewards = await FactoryFacet.connect(user).pendingRewardsByPoolId(0,user.address,0);

                const unstakeTx = await FactoryFacet.connect(user).unstake(0,0);    
                await unstakeTx.wait()      
                const afterRewards = await FactoryFacet.connect(user).pendingRewardsByPoolId(0,user.address,0);
                console.log("AFTER",formatEther(afterRewards))

            }


            const userInfo = await FactoryFacet.getUserInfoByPoolAddress(stakePools[0].pool,deployer.address)
            console.log(userInfo)
            
            const stakePoolsEx = await FactoryFacet.fetch();
            console.log('stakePools',stakePoolsEx)
        });







    });

});

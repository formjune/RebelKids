const RebelKidsFamiliars = artifacts.require('RebelKidsFamiliars');
const RebelKids = artifacts.require('RebelKids');
const RebelKidsStickers = artifacts.require('RebelKidsStickers');

module.exports = async function (deployer) {
    let kids = await RebelKids.deployed();
    let familiars = await RebelKidsFamiliars.deployed();
    await deployer.deploy(RebelKidsStickers, kids.address, familiars.address);
};
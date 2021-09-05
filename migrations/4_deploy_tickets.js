const RebelKidsFamiliars = artifacts.require('RebelKidsFamiliars');
const RebelKids = artifacts.require('RebelKids');
const RebelTickets = artifacts.require('RebelTickets');

module.exports = async function (deployer) {
    let kids = await RebelKids.deployed();
    let familiars = await RebelKidsFamiliars.deployed();
    await deployer.deploy(RebelTickets, kids.address, familiars.address);
};
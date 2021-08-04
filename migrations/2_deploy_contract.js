const RebelKidsFamiliars = artifacts.require('RebelKidsFamiliars');
const RebelKids = artifacts.require('RebelKids');

module.exports = function (deployer) {
    deployer.deploy(RebelKidsFamiliars);
    deployer.deploy(RebelKids);
};
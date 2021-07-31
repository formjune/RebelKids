const People = artifacts.require("People");
const initMessage = "People are uploaded";

module.exports = function(deployer) {
  deployer.deploy(People, initMessage);
};
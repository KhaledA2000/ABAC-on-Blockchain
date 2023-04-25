const { ethers } = require("hardhat");

async function main() { 
    // Get deployer account
    const [deployer] = await ethers.getSigners();
    console.log('Deploying contracts with the account: ' + deployer.address); 

    // Deployer's Balance
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Deploy First
    const Subject = await ethers.getContractFactory('SubjectAttribute');
    const subject = await Subject.deploy();

    // Deploy Second
    const Object = await ethers.getContractFactory('ObjectAttributes');
    const object = await Object.deploy();

    // Deploy Third
    const Policy = await ethers.getContractFactory('PolicyManagement');
    const policy = await Policy.deploy();

    // Deploy Fourth 
    const Access = await ethers.getContractFactory('AccessControl');
    const access = await Access.deploy(subject.address, object.address, policy.address );


    console.log( "Subject Contract: " + subject.address );
    console.log( "Object Contract: " + object.address ); 
    console.log( "Policy Contract: " + policy.address );
    console.log( "Access Contract: " + access.address ); 

}

main()
    .then(() => process.exit())
    .catch(error => {
        console.error(error);
        process.exit(1);
})

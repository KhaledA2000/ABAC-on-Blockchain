// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;



contract AccessControl {

    struct Store {
        string attribute_1;
        string attribute_2;
        string attribute_3;
        string attribute_4;
        string attribute_5;

    }

    // VARIABLES
    // These are contract addresses:

    address subject_address;
    address object_address;

    mapping(address => bool) public authorities;

    // EVENTS
    event AccessGranted (address sub_addr, address obj_addr);
    event AccessDenied (address sub_addr, address obj_addr, string message);
    
    // These are only to show that authentication succeeded or 
    // failed and wont be there in the productionized versioon of the smart contract
    event AuthenticationSuccess (address sub_addr);
    event AuthenticationFailure (address sub_addr);


    //Modifiers
    modifier authorities_only(){
        require(authorities[msg.sender] = true);
        _;
    }

    //Functions

    constructor(address sub_con, address obj_con){
        authorities[msg.sender] = true;
        subject_address = sub_con;
        object_address = obj_con;
    }


    //Change Subject and Object Addresses
    function changeAddress(address sub_con, address obj_con) public authorities_only() {

        subject_address = sub_con;
        object_address = obj_con;
    }


    //Add Authority
    function addAuthority(address authority) public authorities_only(){
        authorities[authority] = true;
    }


    //Remove Authority
    function removeAuthority(address authority) public authorities_only() {
        authorities[authority] = false;
    }

    
}
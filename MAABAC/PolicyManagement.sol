// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "contracts/SubjectAttribute.sol";
import "contracts/ObjectAttribute.sol";


contract PolicyManagement {
    // ENUMS
    enum PolicyState {NotActive, Active, Suspended}

    // STRUCTS
    // Object Attributes
    struct Object {
        string location;
        string date;
    }

    // Subject Attributes
    
    struct Subject {

        string name;
        string username;
        string department;
        string position;
    }
    
    // Actions allowed
    struct Action{
        bool read;
        bool write;
        bool execute;
    }
    
   

    // Policy Structure
    // Contains sub/obj attribs, possible actions and context.
    struct Policy {
        PolicyState state;
        Subject subject;
        Object object;
        Action action;
       
    }

    // EVENTS
    event PolicyAdded(uint256 pol_id);
    event DuplicatePolicyExist(string[4] subject, string[2] object);
    event PolicyChanged(uint256 pol_id);
    event PolicyDeleted(uint256 pol_id);
    event PolicyNotExist(string[4] subject, string[2] object);

    //Modifiers
    modifier authorities_only(){
        require(authorities[msg.sender] = true);
        _;
    }

    // VARIABLES
    mapping(address => bool) private authorities;
    uint256 public total_policies;

    Policy[]  policies;
    uint256[] ret_list;

    // FUNCTIONS
    constructor() {
        authorities[msg.sender] = true;
        total_policies = 0;
    }

     // VARIABLES
    // These are contract addresses
    address subject_address;
    address object_address;
    

    // EVENTS that show either access was granted or denied
    event AccessGrantedMsg (address sub_addr, address obj_addr, string message);
    event AccessGranted (address sub_addr, address obj_addr);
    event AccessDenied (address sub_addr, address obj_addr, string message);
    
    // These are only to show that authentication succeeded or 
    // failed and wont be there in the productionized version of the smart contract
    event AuthenticationSuccess (address sub_addr);
    event AuthenticationFailure (address sub_addr);


// Main access control function
    // Checks bloom filter for existance of subject
    // Gets Subject/Object attributes from Subject/Object Contracts
    // From all the actions decides whether to allow access to object
    // Emits AccessGranted for successful access request
    // Emits AccessDenied with failure message otherwise
/*
SUBJECT ATTRIBUTES:
sAttr[0] = name
sAttr[1] = username
sAttr[2] = department
sAttr[3] = position

OBJECT ATTRIBUTES:
oAttr[0] = location
oAttr[1] = date



*/
    function match_Policies(
        string[4] memory sAttr,
        // uint256 sAge, 
        string[2] memory oAttr,
        address obj_addr
    )
        /**MODIFIERS**/
        public
    {

        // Integer used for defining access control
        uint8 access = 0;

        // Check for policy matches which are hardcoded for now
        // Admins would be able to add polcies dynamically later on

        if (keccak256(abi.encodePacked(oAttr[0])) == keccak256(abi.encodePacked("CGI")) && 
        keccak256(abi.encodePacked(sAttr[2])) == keccak256(abi.encodePacked("blockchain"))) {
          access = 1;
        } else if (keccak256(abi.encodePacked(oAttr[0])) == keccak256(abi.encodePacked("CGI")) && 
        keccak256(abi.encodePacked(sAttr[2])) != keccak256(abi.encodePacked("blockchain"))) {
            access = 2;
        } else if (keccak256(abi.encodePacked(oAttr[0])) != keccak256(abi.encodePacked("CGI")) && 
        keccak256(abi.encodePacked(sAttr[2])) == keccak256(abi.encodePacked("blockchain"))) {
            access = 3;
        } else if (keccak256(abi.encodePacked(oAttr[0])) != keccak256(abi.encodePacked("CGI")) && 
        keccak256(abi.encodePacked(sAttr[2])) != keccak256(abi.encodePacked("blockchain"))) {
            access = 4;
        } else if (keccak256(abi.encodePacked(oAttr[0])) == keccak256(abi.encodePacked("04302023"))){
            access = 5;
        } else if  (keccak256(abi.encodePacked(oAttr[0])) == keccak256(abi.encodePacked("CGI")) && 
        keccak256(abi.encodePacked(sAttr[2])) == keccak256(abi.encodePacked("HR Manager"))){
            access = 6;
        }
        else {
            access = 7;
        }
        
        // Emit AccessGranted or AccessDenied events if subject has 
        // access to that object depending on access code from above
        if (access == 1) {
          emit AccessGranted(msg.sender, obj_addr);
        } else if (access == 2){
            emit AccessDenied(msg.sender, obj_addr, "From CGI, but not blockchain department");
        } else if (access == 3){
            emit AccessDenied(msg.sender, obj_addr, "Not from CGI, but from some random blockchain department");
        } else if (access == 4){
            emit AccessDenied(msg.sender, obj_addr, "Neither from CGI, nor from blockchain department");
        } else if (access == 5){
            emit AccessDenied(msg.sender, obj_addr, "YOU ARE SUPPOSED TO BE ENJOYING THE HOLIDAY!");
        } else if (access == 6){
            emit AccessGrantedMsg(msg.sender, obj_addr, "Hello Manager, here are the employees info.");
        } else if (access == 7){
            emit AccessDenied(msg.sender, obj_addr, "Stop Bruteforcing!");
        }

    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@KhaledA2000/ABAC-Blockchain/MAABAC/ObjectAttributes.sol";
import "@KhaledA2000/ABAC-Blockchain/MAABAC/ObjectAttributes.sol";
import "@KhaledA2000/ABAC-Blockchain/MAABAC/PolicyManagement.sol";

contract AccessControl {

    
    struct Subject {
        
        string name;
        string username;
        string department;
        string position;
        
    }

    struct Object {
        string location;
        string date;
    }



    // VARIABLES
    // These are contract addresses:

    address policy_address;
    address subject_address;
    address object_address;

    mapping(address => bool) public authorities;

    // EVENTS
    event AccessGranted (address sub_addr, address obj_addr, uint8 action);
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

    constructor(address sub_con, address obj_con, address pol_con){
        authorities[msg.sender] = true;
        subject_address = sub_con;
        object_address = obj_con;
        policy_address = pol_con;
    }

    function change_address(
        /**CONTRACT ADDRESSES**/
        address pol,
        address sub,
        address obj
    )
        /**MODIFIERS**/
        public
        authorities_only()
    {
        policy_address = pol;
        subject_address = sub;
        object_address = obj;
    }


    //Add Authority
    function addAuthority(address authority) public authorities_only(){
        authorities[authority] = true;
    }


    //Remove Authority
    function removeAuthority(address authority) public authorities_only() {
        authorities[authority] = false;
    }

    function access_control(
        
        address obj_addr
       
        
    )
        /**MODIFIERS**/
        public
    {
        // Check Bloom Filter for existance of subject
        SubjectAttribute subject_contract = SubjectAttribute(subject_address);
        if(!subject_contract.check_bitmap(msg.sender)){
            emit AccessDenied(msg.sender, obj_addr, "Subject Not Found!");
            emit AuthenticationFailure(msg.sender);
            return;
        }
        else emit AuthenticationSuccess(msg.sender);

        //Subject info
        SubjectAttribute.SubjectState sub_state;
        Subject memory sub_arg;
        (sub_state,
            sub_arg.name,
            sub_arg.username,
            sub_arg.department,
            sub_arg.position
            
        )
        = subject_contract.subjects(msg.sender);


        // Object Information Struct Initialization
        Object memory obj_arg;

        // Object Information
        ObjectAttributes object_contract = ObjectAttributes(object_address);
        (obj_arg.location, obj_arg.date) = object_contract.objects(obj_addr);

        // Send Subject and Object info to Policy Management contract
        // and get list of policies relating to Subject and Object
        PolicyManagement policy_contract = PolicyManagement(policy_address);
        policy_contract.match_policies(sub_arg.name, sub_arg.username, sub_arg.department, sub_arg.position,
            obj_arg.location, obj_arg.date, obj_addr);

         

        
    }   
    
}  

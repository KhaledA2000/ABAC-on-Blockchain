// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "contracts/SubjectAttribute.sol";
import "contracts/ObjectAttribute.sol";
import "contracts/PolicyManagement.sol";

contract AccessControl {
    
    // STRUCTS
    struct SubjectInfo {
        SubjectAttribute.SubjectState state;
        string name;
        string username;
        string department;
        string position;
    }

    struct ObjectInfo {
        string location;
        string date;
    }

    // VARIABLES
    // These are contract addresses:
    address public policy_address;
    address public subject_address;
    address public object_address;

    mapping(address => bool) public authorities;

    // EVENTS
    event AccessGranted(address indexed sub_addr, address indexed obj_addr, uint8 action);
    event AccessDenied(address indexed sub_addr, address indexed obj_addr, string message);
    event AuthenticationSuccess(address indexed sub_addr);
    event AuthenticationFailure(address indexed sub_addr);

    //Modifiers
    modifier authorities_only(){
        require(authorities[msg.sender] == true, "Sender is not an authority.");
        _;
    }

    //Functions

    constructor(address sub_con, address obj_con, address pol_con) {
        authorities[msg.sender] = true;
        subject_address = sub_con;
        object_address = obj_con;
        policy_address = pol_con;
    }

    function change_address(
        address pol,
        address sub,
        address obj
    )
        public
        authorities_only()
    {
        policy_address = pol;
        subject_address = sub;
        object_address = obj;
    }

    //Add Authority
    function addAuthority(address authority) public authorities_only() {
        authorities[authority] = true;
    }

    //Remove Authority
    function removeAuthority(address authority) public authorities_only() {
        authorities[authority] = false;
    }

    function access_control(
        address sub_addr,
        address obj_addr
    )
        public
    {
        // Check Bloom Filter for existance of subject
        SubjectAttribute subject_contract = SubjectAttribute(subject_address);
        if(!subject_contract.check_bitmap(msg.sender)) {
            emit AccessDenied(msg.sender, obj_addr, "Subject not found.");
            emit AuthenticationFailure(msg.sender);
            return;
        } else {
            emit AuthenticationSuccess(msg.sender);
        }

        // Get subject info
        SubjectInfo memory sub_info;
        (sub_info.state, sub_info.name, sub_info.username, sub_info.department, sub_info.position) = subject_contract.subjects(msg.sender);

        // Get object info
        ObjectInfo memory obj_info;
        ObjectAttributes object_contract = ObjectAttributes(object_address);
        (obj_info.location, obj_info.date) = object_contract.objects(obj_addr);

        // Send subject and object info to Policy Management contract
        PolicyManagement policy_contract = PolicyManagement(policy_address);
        policy_contract.match_policies(
            sub_info.name,
            sub_info.username,
            sub_info.department,
            sub_info.position,
            obj_info.location,
            obj_info.date,
            obj_addr,
            sub_addr
        );

    }   
    
}

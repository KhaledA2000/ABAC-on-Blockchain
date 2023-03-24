// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "contracts/SubjectAttribute.sol";
import "contracts/ObjectAttribute.sol";

contract PolicyManagement {
    // ENUMS
    enum PolicyState { NotActive, Active, Suspended }

    // STRUCTS
    struct Object {
        string location;
        string date;
    }

    struct Subject {
        string name;
        string username;
        string department;
        string position;
    }

    struct Policy {
        PolicyState state;
        Subject subject;
        Object object;
        mapping(string => bool) actions;
    }

    // EVENTS
    event PolicyAdded(uint256 pol_id);
    event DuplicatePolicyExist(string[4] subject, string[2] object);
    event PolicyChanged(uint256 pol_id);
    event PolicyDeleted(uint256 pol_id);
    event PolicyNotExist(string[4] subject, string[2] object);
    event AccessGrantedMsg(address sub_addr, address obj_addr, string message);
    event AccessGranted(address sub_addr, address obj_addr, string message);
    event AccessDenied(address sub_addr, address obj_addr, string message);
    event AuthenticationSuccess(address sub_addr);
    event AuthenticationFailure(address sub_addr);

    // MODIFIERS
    modifier authorities_only() {
        require(authorities[msg.sender] == true);
        _;
    }

    // VARIABLES
    mapping(address => bool) private authorities;
    uint256 public total_policies;
    Policy[] policies;
    address subject_address;
    address object_address;

    // FUNCTIONS
    constructor() {
        authorities[msg.sender] = true;
        total_policies = 0;
    }

    // Adds a policy to the list of policies
    function add_policy(
        string memory s_name,
        string memory s_username,
        string memory s_department,
        string memory s_position,
        string memory o_location,
        string memory o_date,
        bool read_permission,
        bool write_permission,
        bool execute_permission
    )
        public
        authorities_only()
    {
        Policy storage policy = policies.push();
        policy.state = PolicyState.Active;
        policy.subject = Subject(s_name, s_username, s_department, s_position);
        policy.object = Object(o_location, o_date);
        policy.actions["read"] = read_permission;
        policy.actions["write"] = write_permission;
        policy.actions["execute"] = execute_permission;
        total_policies++;
        emit PolicyAdded(total_policies);
    }

    // Main access control function
    function match_policies(
        string memory s_name,
        string memory s_username,
        string memory s_department,
        string memory s_position,
        string memory o_location,
        string memory o_date,
        address obj_addr
    )   
        public 
        
    {
        uint8 access = 0;
        for (uint256 i = 0; i < policies.length; i++) {
            Policy storage policy = policies[i];
            if (
                keccak256(abi.encodePacked(policy.subject.name)) == keccak256(abi.encodePacked(s_name)) &&
                keccak256(abi.encodePacked(policy.subject.username)) == keccak256(abi.encodePacked(s_username)) &&
                keccak256(abi.encodePacked(policy.subject.department)) == keccak256(abi.encodePacked(s_department)) &&
                keccak256(abi.encodePacked(policy.subject.position)) == keccak256(abi.encodePacked(s_position)) &&
                keccak256(abi.encodePacked(policy.object.location)) == keccak256(abi.encodePacked(o_location)) &&
                keccak256(abi.encodePacked(policy.object.date)) == keccak256(abi.encodePacked(o_date))
            ) {access = 1; }

            else {access = 2;}
            
        }
        if (access == 1) {
          emit AccessGranted(msg.sender, obj_addr, "Welcome!");
        }
        else if (access == 2){
            emit AccessDenied(msg.sender, obj_addr, "Acecess Denied");
        }
        

       

       

    }

    
}
            
            
                

                
                
                
    


    

                

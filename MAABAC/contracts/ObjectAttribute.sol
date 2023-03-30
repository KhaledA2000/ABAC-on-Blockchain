// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract ObjectAttributes {

    struct Object {

        string location;
        string date;

    }

    struct BloomFilter {
    uint256 bitmap;
    uint8 hash_count; }

    // local variables
    mapping(address => bool) public authorities;
    uint256 num_objects;
    BloomFilter filter;
    address[] users;

    //mapping addresses of objects
    mapping (address => Object) public objects;


    //Authorities Only
    modifier authorities_only(){
        require(authorities[msg.sender] = true);
        _;
    }

    constructor() {
    authorities[msg.sender] = true;
    num_objects = 0;
    filter.bitmap = 0;
    filter.hash_count = 5;
    }

    // Events
    event NewObjectAdded(address obj_addr, string location, string date);


    //Adding an Object
    function add_object (address obj_addr, string[2] memory objects_arg) public authorities_only() {

        num_objects++;

        objects[obj_addr].location = objects_arg[0];
        objects[obj_addr].date = objects_arg[1];


        add_bitmap(obj_addr);

        emit NewObjectAdded(obj_addr, objects[obj_addr].location, objects[obj_addr].date);
        
        }

    // Adds a subject to bloom filter
    // By default hash_count is 5 in constructor
    // hash_count is number of times the sub_addr gets hashed
    function add_bitmap(
        /**SUBJECT ID**/
        address sub_addr
    )

        internal 
        
    {

        require(filter.hash_count > 0, "Hash count cannot be zero!");
        for(uint i = 0; i < filter.hash_count; i++) {
            uint256 index = uint256(keccak256(abi.encodePacked(sub_addr, i))) % 256;
            require(index < 256, "Overflow Error!");
            uint256 bit_place = 1 << index;
            filter.bitmap = filter.bitmap | bit_place;
        }    
        
    }
}
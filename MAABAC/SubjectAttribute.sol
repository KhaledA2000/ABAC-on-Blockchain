// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract SubjectAttribute {
    // ENUMS
    enum SubjectState {NotCreated, Active, Suspended, Deactivated}
    

    struct Subject {

        SubjectState state;
        string name;
        string username;
        string department;
        string position;
    }

    struct BloomFilter{
        uint256 bitmap;
        uint8 hash_count;
    }
    
    // VARIABLES
    address admin;
    uint256 num_subjects;
    BloomFilter filter;
    address[] users;

    mapping (address => Subject) public subjects;

    //Admin Only
    modifier admin_only(){
        require(msg.sender == admin);
        _;
    }

    modifier sub_active(address sub_addr){
        require(subjects[sub_addr].state == SubjectState.Active);
        _;
    }


    constructor() {
        admin = msg.sender;
        num_subjects = 0;
        filter.bitmap = 0;
        filter.hash_count = 5;
    }

    event NewSubjectAdded(address sub_addr, string sub);
    event SubjectChanged(address sub_addr);

    function addSubject (address sub_addr, string[4] memory subject_arg) public admin_only() {

        num_subjects++;
        subjects[sub_addr].state = SubjectState.Active;
        //Subject Attributes:
        subjects[sub_addr].name = subject_arg[0];
        subjects[sub_addr].username = subject_arg[1];
        subjects[sub_addr].department = subject_arg[2];
        subjects[sub_addr].position = subject_arg[3];

        add_bitmap(sub_addr);

        emit NewSubjectAdded(sub_addr, subjects[sub_addr].name);
    }

    // Adds a subject to bloom filter
    // By default hash_count is 5 in constructor
    // hash_count is number of times the sub_addr gets hashed
    function add_bitmap(
        /**SUBJECT ID**/
        address sub_addr
    )

    /**MODIFIERS**/
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

     // Check the sub_addr with the existing bloom filter
    // to see if sub_addr exists.
    // Returns true if sub_addr may exist
    // Returns false if sub_addr definitely doesn't exist
    function check_bitmap(
        /**SUBJECT ID**/
        address sub_addr
    )

            /**MODIFIERS**/
        external
        view
        returns(bool)
    {
        require(filter.hash_count > 0, "Hash count cannot be zero");
        for(uint256 i = 0; i < filter.hash_count; i++){
            uint256 index = uint256(keccak256(abi.encodePacked(sub_addr, i))) % 256;
            require(index < 256, "Overflow Error!");
            uint256 bit_place = 1 << index;
            if((filter.bitmap & bit_place) == 0) return false;
        }
        return true;
    }

    // Changes the attributes of a subject
    // If attribute are blank "" skip to next attribute (no change done)
    // Note: Cannot set any attribute to empty string (blank)
    // Emits SubjectChanged event
    function change_attribs(
        /**SUBJECT ID**/
        address sub_addr,
        /**SUBJECT ATTRIBUTES**/
        string[5] memory sub_arg
    )
    /**MODIFIERS**/
        public
        admin_only()
        sub_active(sub_addr)

    {
         // CHANGE MAIN ATTRIBS
        bytes memory empty_test = bytes(sub_arg[0]);
        if (empty_test.length != 0) subjects[sub_addr].name = sub_arg[0];
        empty_test = bytes(sub_arg[1]);
        if (empty_test.length != 0) subjects[sub_addr].username = sub_arg[1];
        empty_test = bytes(sub_arg[2]);
        if (empty_test.length != 0) subjects[sub_addr].department = sub_arg[2];
        empty_test = bytes(sub_arg[3]);
        if (empty_test.length != 0) subjects[sub_addr].position = sub_arg[3];
        empty_test = bytes(sub_arg[4]);
        emit SubjectChanged(sub_addr);

    }


}




    

        
    


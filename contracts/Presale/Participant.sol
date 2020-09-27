// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

struct Participant{
    uint256 entryDate;    
    uint256 entryAmount;
    uint256 entryRecieved;
}

contract Test{
    mapping (address => Participant) _participants;
    

    function TestFunction() public{
        _participants[address(0x0)] = Participant(block.timestamp, 1, 1);
    }
    
}
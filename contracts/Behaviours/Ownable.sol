// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

abstract contract Ownable {
    address public Owner;
    bool public OwnershipRenounced = false;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);   

    modifier onlyOwner() {
        require(Owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(Owner, address(0));
        Owner = address(0);
        OwnershipRenounced = true;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(Owner, newOwner);
        Owner = newOwner;
    }
}
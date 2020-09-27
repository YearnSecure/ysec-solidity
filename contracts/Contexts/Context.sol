// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}
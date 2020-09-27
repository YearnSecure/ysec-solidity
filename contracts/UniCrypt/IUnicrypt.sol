// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

interface IUnicrypt{
    function depositToken(address token, uint256 amount, uint256 unlock_date) external payable;
    function withdrawToken(address token, uint256 amount) external;
    function getWithdrawableBalance(address token, address user) external view returns (uint256);
}
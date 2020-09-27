// SPDX-License-Identifier: MIT
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Tokens/YSEC.sol";

pragma solidity 0.7.0;

contract TestYsec{
    function testInitialBalanceOFYsecUsingDeployedContract() public {
        YSEC ysec = YSEC(DeployedAddresses.YSEC());

        uint expected = 0;

        Assert.equal(ysec.totalSupply(), expected, "Total supply should be 0 on init");        
    }

    function testInitialBalanceOfYsec() public{
        YSEC ysec = new YSEC();

        uint expected = 0;

        Assert.equal(ysec.totalSupply(), expected, "Total supply should be 0 on init");

        ysec.add(1000);

        Assert.equal(ysec.totalSupply(), 1000, "Total supply shoud be 1000");        

        Assert.equal(ysec.balanceOf(address(this)), 1000, "Supply of owner should be 1000");        
    }
}
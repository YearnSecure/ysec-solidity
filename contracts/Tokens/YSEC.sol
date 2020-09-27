/*
__/\\\________/\\\_____/\\\\\\\\\\\____/\\\\\\\\\\\\\\\________/\\\\\\\\\_        
 _\///\\\____/\\\/____/\\\/////////\\\_\/\\\///////////______/\\\////////__       
  ___\///\\\/\\\/_____\//\\\______\///__\/\\\_______________/\\\/___________      
   _____\///\\\/________\////\\\_________\/\\\\\\\\\\\______/\\\_____________     
    _______\/\\\____________\////\\\______\/\\\///////______\/\\\_____________    
     _______\/\\\_______________\////\\\___\/\\\_____________\//\\\____________   
      _______\/\\\________/\\\______\//\\\__\/\\\______________\///\\\__________  
       _______\/\\\_______\///\\\\\\\\\\\/___\/\\\\\\\\\\\\\\\____\////\\\\\\\\\_ 
        _______\///__________\///////////_____\///////////////________\/////////__

Visit and follow!

* Website: https://www.ysec.finance

* Twitter: https://twitter.com/ysec

* Telegram: https://t.me/ysec

* Medium: https://medium.com/@ysec"

*/

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "../Behaviours/Ownable.sol";

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

contract YSEC is ERC20, ERC20Detailed, Ownable {    
    using SafeMath for uint;   

    constructor () ERC20Detailed("yearnsecure", "YSEC", 18) {
        Owner = msg.sender;
    }

    function GetAddress() public view returns(address tokenAddress){
        return address(this);
    }

    function Burn(uint amount) public {        
        _burn(msg.sender, amount);
    }

    // owner is presale contract, so only presale contract can call mint!
    // presale contract will renounce ownership upon completion! (see OwnershipRenounced in Ownable)
    function Mint(address account, uint amount) public onlyOwner {
       _mint(account, amount);
    }       
}
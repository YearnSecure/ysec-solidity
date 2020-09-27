// SPDX-License-Identifier: MIT

import "../Tokens/YSEC.sol";
import "../Behaviours/Ownable.sol";
import "../Uniswap/IUniswapV2Factory.sol";
import "../Uniswap/IUniswapV2Router.sol";
import "../Unicrypt/IUnicrypt.sol";

pragma solidity 0.7.0;

contract YSECPresale is Ownable{
    using SafeMath for uint;   

    YSEC private Token;
    IUniswapV2Factory private _uniswapFactory;
    IUniswapV2Router private _uniswapRouter;
    IUnicrypt private _uniCrypt;

    uint256 public StartDate;
    uint256 public LiquidityLockedDate;
    uint256 public LiquidityLockedUntillDate;
    uint256 public recievedEth;
    bool public PresaleEnded = false;
    bool public LiquidityProvided = false;
    bool public LiquidityLocked = false;
    uint256 public totalTokensDistributed;

    uint256 private _totalUniswapLiquidityTokens;

    uint256 public constant SoftCap = 2000000000000000000; // is 2 
    uint256 public constant HardCap = 5000000000000000000; // is 5
    uint256 public constant TokensPerEth = 200;       

    address private constant _uniswapRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant _uniCryptAddress = 0x17e00383A843A9922bCA3B280C0ADE9f8BA48449;

    mapping(address => uint256) private _ethContributedPerAddress;    

    constructor() {
        Owner = msg.sender;
        Token = new YSEC(); //creates new token contract with this contract address as owner               
        _uniswapRouter = IUniswapV2Router(_uniswapRouterAddress);
        _uniswapFactory = IUniswapV2Factory(_uniswapRouter.factory());
        _uniCrypt = IUnicrypt(_uniCryptAddress);
    }

    receive () external payable {
        require(PresaleStarted(), "Presale has not started yet");
        require(!HardcapMet(), "Hardcap has been met!");
        require(!PresaleEnded, "Presale has ended!");        

        uint256 amountToDistribute = msg.value.mul(TokensPerEth);
        uint256 amountRecieved = msg.value;

        if(recievedEth + amountRecieved > HardCap)// incoming contribution will go past hardcap, so round of and resend eth 
        {
            uint256 amountToReturn = amountRecieved - (HardCap - recievedEth);//calc return amount of eth
            amountRecieved = amountRecieved - amountToReturn;//adjust amountrecieved;
            amountToDistribute = amountRecieved.mul(TokensPerEth);//adjust token distribution amount;
            
            msg.sender.transfer(amountToReturn);//return the leftover eth to sender;
        }
        GenerateTokensToRatio(msg.sender, amountToDistribute);        
        totalTokensDistributed = totalTokensDistributed.add(amountToDistribute);
        recievedEth = recievedEth.add(amountRecieved);   
        _ethContributedPerAddress[msg.sender] = _ethContributedPerAddress[msg.sender].add(amountRecieved);//log contibuted eth per address   
    }    

    //Seperate call to finish presale before softcap has been met TODO MAX TIME
    function FinishPresalePreSoftcap() public onlyOwner{
        require(!SoftcapMet(), "Softcap has been met presale cannot be reverted");// 
        require(!PresaleEnded, "Presale has already been finished");
        PresaleEnded = true;
    }

    //seperate call because high gas is used, and we can't charge that to the last person calling the contract TODO MAX TIME
    function FinishPresale() public onlyOwner{
        require(SoftcapMet(), "Softcap has not been met, presale cannot be finished!");
        require(!PresaleEnded, "Presale has already been finished");//can only call this once! (what about failed add liq to uni? build retry mech?)
        PresaleEnded = true;        
        Token.renounceOwnership();
        AddLiquidity();
        LockLiquidity();        
    }


    // manual call useable in case of failure on close of presale
    function ManuallyAddLiquidity() public onlyOwner{
        AddLiquidity();
    }

    // manual call useable in case of failure on lock of liquidity
    function ManuallyLockLiquidity() public onlyOwner{
        LockLiquidity();
    }

    //TODO not finished
    // function to generate remaining tokens.. -> team, marketing, farming and liquidity pool   
    function GenerateTokensToRatio(address contributor, uint256 amountToDistribute) private{
        //first allocate tokens to contributor == 40% of total tokens
        Token.Mint(contributor, amountToDistribute);//generate amount of tokens for participant directly to sender address

        uint256 perPercentage = amountToDistribute.div(40);

        //allocate team tokens 10%
        uint256 amountOfTeamTokens = perPercentage.mul(10);
        Token.Mint(address(this), amountOfTeamTokens); //todo -> time locked vault

        //allocate marketing tokens 10%
        uint256 amountOfMarketingTokens = perPercentage.mul(10);
        Token.Mint(address(this), amountOfMarketingTokens); 

        //allocate uniswap liquidity tokens 10%
        uint256 amountOfUniTokens = perPercentage.mul(10);
        Token.Mint(address(this), amountOfUniTokens); 
        _totalUniswapLiquidityTokens = _totalUniswapLiquidityTokens.add(amountOfUniTokens);

        //allocate farming tokens 30%
        uint256 amountOfFarmingTokens = perPercentage.mul(30);
        Token.Mint(address(this), amountOfFarmingTokens); //todo -> time locked vault
    }

    //TODO not finished
    //function to automatically add liquidity to uniswap
    function AddLiquidity() private{
        require(SoftcapMet());
        require(PresaleEnded);
        require(!LiquidityProvided);
        require(!LiquidityLocked);

        //create factory to see if pair exists and see ratio
        //add liquidity

        address pairAddress = _uniswapFactory.getPair(Token.GetAddress(), _uniswapRouter.WETH());
        if(pairAddress != address(0))
        {
            //pair already has been added, determine ratio and see if this falls within desired?
        }
        uint256 amountOfEth = _totalUniswapLiquidityTokens.div(175);
        Token.approve(_uniswapRouterAddress, _totalUniswapLiquidityTokens);//approve unirouter
        _uniswapRouter.addLiquidityETH{ value: amountOfEth }(Token.GetAddress(), _totalUniswapLiquidityTokens, 1, 1, address(this), 33136721748);//todo rato

        LiquidityProvided = true;
    }

    //function to automatically lock liquidity
    function LockLiquidity() private{
        require(SoftcapMet());
        require(PresaleEnded);
        require(LiquidityProvided);
        require(!LiquidityLocked);

        address pairAddress = _uniswapFactory.getPair(Token.GetAddress(), _uniswapRouter.WETH());
        IERC20 uniV2Pair = IERC20(pairAddress);
        uint256 uniV2Balance = uniV2Pair.balanceOf(address(this));
        uniV2Pair.approve(_uniCryptAddress, uniV2Balance);
        _uniCrypt.depositToken(pairAddress, uniV2Balance), block.timestamp.add(365 days));

        LiquidityLocked = true;
        LiquidityLockedDate = block.timestamp;
        LiquidityLockedUntillDate = LiquidityLockedDate.add(365 days);
    }

    // in case of failed presale allow users to retrieve invested eth
    function RetrieveEth(address payable from) public{
        require(!SoftcapMet(), "Softcap has been met! you are not able to retrieve ETH");
        require(PresaleEnded, "Presale has not yet ended");
        require(_ethContributedPerAddress[from] > 0, "You have not contributed, or have already retrieved contribution");

        uint256 ethContributedForAddress = _ethContributedPerAddress[from];
        _ethContributedPerAddress[from] = 0;

        from.transfer(ethContributedForAddress);
    }

    //TODO not finished
    //withdraw eth in the contract (time lock?)
    function withdrawETH() public onlyOwner{

    }

    //withdraw uni v2 liq tokens after unlock
    function WithdrawUniV2() public onlyOwner{
        require(LiquidityLocked);//can only be withdrawn after liquidity lock
        require(LiquidityLockedUntillDate < block.timestamp, "Liquidity is still locked");
        address pairAddress = _uniswapFactory.getPair(Token.GetAddress(), _uniswapRouter.WETH());       
        uint256 amountRetrievable = _uniCrypt.getWithdrawableBalance(pairAddress, address(this));        
        require(amountRetrievable > 0, "No uniV2 tokens to withdraw");
        _uniCrypt.withdrawToken(pairAddress, amountRetrievable);
        
        IERC20 uniV2Pair = IERC20(pairAddress);        
        uniV2Pair.transfer(msg.sender, uniV2Pair.balanceOf(address(this)));
    }

    //Manual call to start presale restricted to owner
    function StartPresale() public onlyOwner{
        StartDate = block.timestamp;
    }

    function PresaleStarted() public view returns(bool){
        return StartDate != 0 && StartDate <= block.timestamp;
    }

    function SoftcapMet() public view returns (bool){
        return recievedEth >= SoftCap;
    }

    function HardcapMet() public view returns (bool)
    {
        return recievedEth >= HardCap;
    }
}
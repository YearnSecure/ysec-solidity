const YSEC = artifacts.require("YSEC");

contract('YSEC', (accounts) =>{
    it('should be 0 ', async () =>{
        const YSECInstance = await YSEC.deployed();
        const balance = await YSECInstance.balanceOf.call(accounts[0]);
        assert.equal(balance.valueOf(), 0, "0 wasn't in the first account");
    });
    it('should be 1000', async () =>{
        const YSECInstance = await YSEC.deployed();
        YSECInstance.add(1000);
        const balance = await YSECInstance.balanceOf.call(accounts[0]);
        assert.equal(balance.valueOf(), 1000, "1000 wasn't in the first account");
    })
});
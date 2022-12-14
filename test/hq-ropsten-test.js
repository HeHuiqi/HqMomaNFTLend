const HqUtils = require('./HqUtils');
const HqConfig = require('../HqConfig');
const fs = require('fs');
const path = require('path');


const ropsten = {
    url:'https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
    accounts: [HqConfig.lender.privateKey]
};

let lenderMasterAddress = '0x62d36a245c35c2c6ccb6b72a5c83d7DeB436E2e4';
lenderMasterAddress = '0x3a71e9A4d27BEA1B6Dd4A2263C3415ac9351213B';
let marketAddress = '0x41d73395D9ac9E3AFbCbE5303658d1A64BEDfe71';
marketAddress = '0xCbd2eAe05Cc82Ad407DFe31e8d4a97e254AF1749';

const wallet_address = HqConfig.lender.account;
const b_wallet_address = HqConfig.borrower.account;
let query_address = '';
query_address = '0x677B919B5559EE1f6997B708E06D5b5912a1E318';
query_address = '0xa103BC1E985efCaba46B2Fe7019fd8D8c1c255F0';
query_address = '0xD696Fcea897c1D06996e078F6b0c813D2a938AA9';
query_address = '0x76f4b131e99D8a59558CCF7B8C29782884F2149A';
query_address = '0xF9B2262039e2E5da8E79DDF86FbC6597c49dfaa0';
query_address = '0x30fE4cE8187283Abd2f6f6bBd060F065A6efbd43';
query_address = '0x71f2763a8dEfcFFa6F158A42dbE2Fd6Fc0Db4555';

const query_abi = HqUtils.hardhatContractABI('MQuery');
const provider = HqUtils.signerProvider(ropsten.accounts[0],ropsten.url);
const query = HqUtils.createContract(query_address,query_abi,provider);


async function testAll() {
    let out;
    out = await query.marketDetail(marketAddress);
    console.log('marketDetail:',out);

    out = await query.allMarket();
    console.log('allMarket:',out);
  

    out = await query.marketSupplyOrders(marketAddress);
    console.log('marketSupplyOrders:',out);
    

    out = await query.orderDetail(marketAddress,2);
    console.log('orderDetail:',out);

    out = await query.userOdersInMarket(b_wallet_address,marketAddress,false);
    console.log('userOdersInMarket:',out);
    

    out = await query.userOdersInMarket(b_wallet_address,marketAddress,false);
    console.log('userOdersInMarket:',out);
    
    out = await query.userOrders(b_wallet_address,false);
    console.log('userOrders:',out);



    out = await query.userLiquidityInMarket(wallet_address,marketAddress);
    console.log('userLiquidityInMarket:',out);

    out = await query.userLiquidity(wallet_address);
    console.log('userLiquidity:',out);
    


    out = await query.userAssetInMarket(wallet_address,marketAddress);
    console.log('userAssetInMarket:',out);

    out = await query.userAllAsset(wallet_address);
    console.log('userAllAsset:',out);
}

async function main(){
    

    let isupdateabi = true;
    if(isupdateabi){
        const fileName = path.join(__dirname,'/abis/MQuery.json');
        fs.writeFileSync(fileName,JSON.stringify(query_abi));
    }
    let isTestAll = true;
    if(isTestAll){
        await testAll();
        return;
    }
    let out;
    // out = await query.marketDetail(marketAddress);
    // console.log('marketDetail:',out);

    // out = await query.allMarket();
    // console.log('allMarket:',out);
  

    out = await query.marketSupplyOrders(marketAddress);
    console.log('marketSupplyOrders:',out);
    

    // out = await query.orderDetail(marketAddress,2);
    // console.log('orderDetail:',out);

    // out = await query.userOdersInMarket(b_wallet_address,marketAddress,false);
    // console.log('userOdersInMarket:',out);
    

    // out = await query.userOdersInMarket(b_wallet_address,marketAddress,false);
    // console.log('userOdersInMarket:',out);
    
    // out = await query.userOrders(b_wallet_address,false);
    // console.log('userOrders:',out);



    // out = await query.userLiquidityInMarket(wallet_address,marketAddress);
    // console.log('userLiquidityInMarket:',out);

    // out = await query.userLiquidity(wallet_address);
    // console.log('userLiquidity:',out);
    


    // out = await query.userAssetInMarket(wallet_address,marketAddress);
    // console.log('userAssetInMarket:',out);

    // out = await query.userAllAsset(wallet_address);
    // console.log('userAllAsset:',out);
}
main();
const HqUtils = require('./HqUtils');
const HqConfig = require('../HqConfig');

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
// ok
query_address = '0x76Fcb5310a7Cf774EcD9A8987BDC2ad0911FF14F';
query_address = '0x6a4DfFAA70DB4EC3F53C055F06E7AcA63a50789d';
query_address = '0x6c83C8a584f80Cecca5B4AC0Ed3Aac19f5C4F8a5';
query_address = '0xd4b219bf7b85C1b5eAc100011FA8C389A4dbad8A';
query_address = '0x7A2e1ebC5A59d0caE53C106b7D23f36494Fe6f72';
query_address = '0x2964e2FDA052fADf577a350afDb8559A692D3cB8';

const query_abi = HqUtils.hardhatContractABI('MQuery');
const provider = HqUtils.signerProvider(ropsten.accounts[0],ropsten.url);
const query = HqUtils.createContract(query_address,query_abi,provider);



async function main(){

    let out;

    
    out = await query.marketDetail(marketAddress);
    console.log('marketDetail:',out);

    // out = await query.allMarket();
    // console.log('allMarket:',out);
  

    // out = await query.marketSupplyOrders(marketAddress);
    // console.log('marketSupplyOrders:',out);
    

    // out = await query.orderDetail(marketAddress,2);
    // console.log('orderDetail:',out);

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
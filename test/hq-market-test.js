//0x536990D0f1844fcbC06168BB018d862782588fA6
const { BigNumber } = require('ethers');
const HqUtils = require('./HqUtils');
const HqConfig = require('../HqConfig');

const ropsten = {
    url:'https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
    accounts: [HqConfig.lender.privateKey]
};
const wallet_address = HqConfig.lender.account;
const b_wallet_address = HqConfig.borrower.account;//借款人地址

let lenderMasterAddress = '0x62d36a245c35c2c6ccb6b72a5c83d7DeB436E2e4';
lenderMasterAddress = '0x3a71e9A4d27BEA1B6Dd4A2263C3415ac9351213B';

let marketAddress = '0x41d73395D9ac9E3AFbCbE5303658d1A64BEDfe71';
marketAddress = '0xCbd2eAe05Cc82Ad407DFe31e8d4a97e254AF1749';

let oracle_address = '0x38BF53f6fA8bbA1a45E7113b7CAFe5D5ef7c0430';
oracle_address = '0x6DBC5bc4893ac01f25D9b049f69F779DF540a798';

const provider = HqUtils.signerProvider(ropsten.accounts[0],ropsten.url);

const lender_abi = HqUtils.hardhatContractABI('ILenderMasterEther');
const lenderMaster = HqUtils.createContract(lenderMasterAddress,lender_abi,provider);


const price_oracle_abi = HqUtils.hardhatContractABI('IPriceOracle');
const priceOracle = HqUtils.createContract(oracle_address,price_oracle_abi,provider);



let merc721_address = '0x737Db6a825024cb9d94d3bf364e6268A9276e1b6';//cNFT
// merc721_address = '0x1c3834f3b5CFA87C9C1713261d5F5b8a0ed826d2';//lenderNFT
// merc721_address = '0x9aF0d3E5e6Bf43CE3219807C8EAa9e4F19B339f9';//borrowerNFT


const erc20_abi = HqUtils.hardhatContractABI('IMToken');
const erc20 = HqUtils.createContract(lenderMasterAddress,erc20_abi,provider);

async function lenderMasterBasInfo(lender_address) {
    console.log('------------------------------LenderMaster------------------------------');

    out = await erc20.totalSupply();
    console.log('mETH totalSupply:',out);
    
    out = await lenderMaster.marketStates(marketAddress);
    let totalMCash = out[1].toString();
    console.log('marketStates:',out);
    out = await lenderMaster.isLender(b_wallet_address);
    console.log('isLender:',out);

    out = await lenderMaster.exchangeRate();
    console.log("exchangeRate:",out);

    out = await lenderMaster.oracle();
    console.log('oracle:',out);

    console.log('------------------------------priceOracle------------------------------');

    out = await priceOracle.getFloorPriceByMarket(marketAddress);
    console.log('getFloorPriceByMarket:',out);
}
async function depostEth(isAddLp,value,markets) {
    let out;
    // out = await lenderMaster.estimateGas.deposit(markets,override);
    let override = {
        value:value,//存1个eth
    }
    if(isAddLp){
        console.log('addLp');
        override.value = value;
        console.log('override:',override);
        out = await lenderMaster.deposit([],override);
        out = await out.wait();
    }else{
        out = await lenderMaster.deposit(markets,override);
        out = await out.wait();
    }
    console.log('deposit:',out.transactionHash);
}
async function withdrawEth(value,markets) {
    let out;
    out = await lenderMaster.withdraw(value,markets);
    out = await out.wait();
    console.log("withdraw:",out.transactionHash);
}

async function erc721(nftAddress) {
    const merc721_abi = HqUtils.hardhatContractABI('IMERC721Borrower');
    let merc721 = HqUtils.createContract(nftAddress,merc721_abi,provider);
    return merc721;
}
async function erc721BaseInfo(nftAddress) {
    console.log('------------------------------erc721------------------------------');
    const merc721 = erc721(nftAddress);
    out = await merc721.name();
    console.log('erc721 name:',out);
    out = await merc721.balanceOf(marketAddress);
    console.log('erc721 market balance:',out);

    out = await merc721.totalSupply();
    console.log('erc721 totalSupply:',out);
}


async function marketBaseInfo(market_address) {
    console.log('------------------------------BorrowerMaster------------------------------');
    let borrowerMaster = createMarket(market_address,provider);
    // out = await borrowerMaster.signer();
    // console.log('signer:',out);
    let marketStates = await lenderMaster.marketStates(market_address);
    let totalMCash = marketStates[1].toString();
    console.log('totalMCash:',totalMCash);
    let secondsPerYear = await borrowerMaster.secondsPerYear();
    console.log('secondsPerYear:',secondsPerYear);
    let tokenTotalBorrows = await borrowerMaster.tokenTotalBorrows(HqUtils.ZeroAddress);
    console.log('tokenTotalBorrows:',tokenTotalBorrows);
    let baseRatePerSecond = await borrowerMaster.baseRatePerSecond();
    console.log('baseRatePerSecond:',baseRatePerSecond);
    let multiplierPerSecond = await borrowerMaster.multiplierPerSecond();
    console.log('multiplierPerSecond:',multiplierPerSecond);
   
    let utilizationRate = await borrowerMaster.utilizationRate(totalMCash,tokenTotalBorrows);
    console.log("utilizationRate:",utilizationRate);
    let myBorrowRatePerSecond = utilizationRate.mul(multiplierPerSecond).div(HqUtils.BigOne).add(baseRatePerSecond);
    console.log('myBorrowRatePerSecond:',myBorrowRatePerSecond);
    let getBorrowRatePerSecond = await borrowerMaster.getBorrowRatePerSecond(totalMCash,tokenTotalBorrows);
    console.log('getBorrowRatePerSecond:',getBorrowRatePerSecond);
    out = await borrowerMaster.collateral();
    
    console.log('collateral:',out);
    
    out = await borrowerMaster.lenderNFT();
    console.log('lenderNFT:',out);
    out = await borrowerMaster.borrowerNFT();
    console.log('borrowerNFT:',out);
    
  
}

function localSigner() {
    // 0x7b597a25563155bFE3447Ba74b7F99B91cEf284D
    const sign_walle_pri = HqConfig.borrower.privateKey;
    const wallet = HqUtils.signerProvider(sign_walle_pri,ropsten.url);
    return wallet;
}
async function localSignMessage(messageBytes) {
    const wallet = localSigner();
    const signature = await wallet.signMessage(messageBytes);
    // console.log('signature:',signature);
    return signature;
}
function createMarket(market_address,wallet) {
    const borrower_abi = HqUtils.hardhatContractABI('IBorrowerMaster');
    let borrowerMaster = HqUtils.createContract(market_address,borrower_abi,wallet);
    return borrowerMaster;
}
 function msgHash(collateralId,token,market_address,expiration,chainId) {
    const hash = HqUtils.messageHash(['uint256','address','address','uint256','uint256'],
    [collateralId,token,market_address,expiration,chainId]);
    return hash;
}
async function borrowInMarket(market_address) {

    //抵押NFT记得先向BorrowMaster市场合约approve 
    console.log('------------------------------BorrowerMaster------------------------------');
    const wallet = localSigner();
    let borrowerMaster = createMarket(market_address,wallet);
    // console.log('borrowerMaster.signer:',borrowerMaster.signer);

    
    let out;
    const borrowParams = {
        collateralId:2, 
        token: HqUtils.ZeroAddress,
        minBorrowAmount:0, 
        lender:wallet_address, 
        expiration:'99999999999', 
        signature:'',
    };
    const chainId = 3;//ropsten
    // borrowParams.hash = HqUtils.messageHash(['uint256','address','address','uint256','uint256'],
    // [borrowParams.collateralId,borrowParams.token,market_address,borrowParams.expiration,chainId]);
    borrowParams.hash = msgHash(borrowParams.collateralId,borrowParams.token,market_address,borrowParams.expiration,chainId);
    const signature = await localSignMessage(borrowParams.hash);
    borrowParams.signature = signature;

    console.log('borrowParams:',borrowParams);
    out = await borrowerMaster.borrow(borrowParams.collateralId,borrowParams.token,borrowParams.minBorrowAmount,
        borrowParams.lender,borrowParams.expiration,borrowParams.signature);
    out = await out.wait();
    console.log('borrow:',out.transactionHash);
    // 0xf6a4bafadfc68768191af1a820e6f0fd6a0310475bbfcd2a2d26900446827083


}
async function orderDetail(market_address,tokenId) {
    let out;
   
    let borrowerMaster = createMarket(market_address,provider);

     /*
        address tAdr,
            uint96 borrowedAmount,
            uint40 borrowRatePerSecond,
            uint16 penaltyFactor,
            uint40 startTime,
            uint40 expireTime
    */

    out = await borrowerMaster.idOfOrderState(tokenId);
    console.log('idOfOrderState:',out);
    const borrowedAmount = out[1].toString();
    const borrowRatePerSecond = out[2];
    const penaltyFactor = out[3];
    const startTime = out[4];
    const expireTime = out[5];
    const block = await provider.provider.getBlock();
    console.log('block:',block.timestamp);
    let time = new Date().getTime()/1000;
    // time = parseInt(time);
    time = block.timestamp;
    console.log('time:',time);
    let p = BigNumber.from(penaltyFactor);
    p = p.div(BigNumber.from('10000'));
    console.log('p',p);
    out = await borrowerMaster.getChargeSeconds(startTime,time,expireTime,p.toString());
    console.log('getChargeSeconds:',out);
}
async function repayBorrow(market_address) {

    let out;
    const wallet = localSigner();
    let borrowerMaster = createMarket(market_address,wallet);
    const  collateralId = 2;
    // function repayBorrow(uint256 collateralId, uint256 amountIn, address referral) external returns (uint256 repayAmount);
    out = await borrowerMaster.getTotalRepayAmount(2);
    console.log('getTotalRepayAmount:',out);

    let repayParams = {
        collateralId:collateralId,
        amountIn: 0,
        referral: b_wallet_address,
    }
    let override = {
        from: b_wallet_address,
        value:out.repayAmount.toString(),
    }

    console.log('repayParams:',repayParams);
    console.log('override',override);
 
    out = await borrowerMaster.repayBorrow(repayParams.collateralId,repayParams.amountIn,repayParams.referral,override);
    out = await out.wait();
    console.log('repayBorrow:',out.transactionHash);


}
async function main(){

    // await lenderMasterBasInfo(lenderMasterAddress);
    await marketBaseInfo(marketAddress);
    // await withdrawEth(HqUtils.UnitOne,[marketAddress]);
    // await borrowInMarket(marketAddress);
    // await orderDetail(marketAddress,2);
    // await repayBorrow(marketAddress);

}
main();
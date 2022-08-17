const hre = require("hardhat");
const ethers = require('ethers');
const { BigNumber } = require('ethers');

const ZeroAddress = '0x0000000000000000000000000000000000000000';
const UnitOne = '1000000000000000000';
const BigOne = BigNumber.from(UnitOne);
function hardhatContractABI(contractName) {
  const abi = hre.artifacts.readArtifactSync(contractName).abi;
//   console.log('abi:', abi);
  return abi;
}


function signerProvider(privateKey,rpc) {``
     // 通过定制 URL 连接 :
     let provider = new ethers.providers.JsonRpcProvider(rpc);
     // 从私钥获取一个签名器 Signer
     let myWallet = new ethers.Wallet(privateKey, provider);
     return myWallet;
}
function createContract(contractAddress,abi,signerProvider){
    // 创建合约对象
    let contract  = new ethers.Contract(contractAddress, abi, signerProvider);
    return contract;
}
// use messageHash(['address','uint256','uint256'],[adr,minCount,saleState]);
function messageHash(types,values) {
  // const hash = ethers.utils.solidityKeccak256(types,values);
  const msg_hash = ethers.utils.defaultAbiCoder.encode(types,values);
  // const msg_hash = ethers.utils.solidityPack(types,values);
  const hash = ethers.utils.keccak256(msg_hash);
  let messageBytes = ethers.utils.arrayify(hash);
  // console.log("Message Hash: ", messageBytes);
  return messageBytes;
}
const HqUtils = {
    ZeroAddress,
    UnitOne,
    BigOne,
    hardhatContractABI,
    signerProvider,
    createContract,
    messageHash,
};
module.exports =  HqUtils;

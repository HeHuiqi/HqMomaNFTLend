const hre = require("hardhat");
const ZeroAddress = '0x0000000000000000000000000000000000000000';
const UnitOne = '1000000000000000000';
function hardhatContractABI(contractName) {
  const abi = hre.artifacts.readArtifactSync(contractName).abi;
//   console.log('abi:', abi);
  return abi;
}


function signerProvider(privateKey,rpc) {
     // 通过定制 URL 连接 :
     let provider = new hre.ethers.providers.JsonRpcProvider(rpc);
     // 从私钥获取一个签名器 Signer
     let myWallet = new hre.ethers.Wallet(privateKey, provider);
     return myWallet;
}
function createContract(contractAddress,abi,signerProvider){
    // 创建合约对象
    let contract  = new hre.ethers.Contract(contractAddress, abi, signerProvider);
    return contract;
}
function HqTokenContract(contractAddress){
    const GreeterABI = hardhatContractABI('HqToken')
    return createContract(contractAddress,GreeterABI);
}
// use messageHash(['address','uint256','uint256'],[adr,minCount,saleState]);
function messageHash(types,values) {
  // const hash = hre.ethers.utils.solidityKeccak256(types,values);
  const msg_hash = hre.ethers.utils.defaultAbiCoder.encode(types,values);
  // const msg_hash = hre.ethers.utils.solidityPack(types,values);
  const hash = hre.ethers.utils.keccak256(msg_hash);
  let messageBytes = hre.ethers.utils.arrayify(hash);
  // console.log("Message Hash: ", messageBytes);
  return messageBytes;
}
const HqUtils = {
    ZeroAddress,
    UnitOne,
    hardhatContractABI,
    signerProvider,
    createContract,
    HqTokenContract,
    messageHash,
};
module.exports =  HqUtils;

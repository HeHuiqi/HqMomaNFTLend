const HqConfig = {
    //借款人账户信息
    borrower:{
        account:'',
        privateKey:'',
    },
    //存款人的信息
    lender:{
        account:'',
        privateKey:'',
    },
    //验证代码的apikey
    apiKey: {
        mainnet: '',
        rinkeby: '',
        ropsten: '',
        bsc: '',
        bscTestnet:''
    },
}
module.exports =  HqConfig;
# GNC Smart-Contract

This contracts is for testing purposes only, do not use it for real deployment.

# Testnet deployment

Functional deployment running on kovan testnet. The deployed contracts are as below.

1. TokenSale address = [0xFF58C66D157B38964eBb3D52ED1Ff4e043cC4F0a](https://kovan.etherscan.io/address/0xff58c66d157b38964ebb3d52ed1ff4e043cc4f0a)


2. Token address = [0x6CDAE038DFf1c38ECE1ba9e7e5f4fD403f431AE2](https://kovan.etherscan.io/address/0x6cdae038dff1c38ece1ba9e7e5f4fd403f431ae2#readContract)


## Main functions
Describe the main functions of the contracts as below.
### BuyTokens function
```
    function buyTokens(address beneficiary)
```

`beneficiary` who got the tokens

tokensSumBonus means amount of tokens purchased.

### getTimeBonus function
```
    function getTimeBonus() public view returns (uint256)
```

The function returns bonus value and value depends on time.


# Deploy
A user needs to deploy
[Token](https://kovan.etherscan.io/address/0x6cdae038dff1c38ece1ba9e7e5f4fd403f431ae2#code) contract without parameters, after that deploy [TokenSale](https://kovan.etherscan.io/address/0xff58c66d157b38964ebb3d52ed1ff4e043cc4f0a#code) contract with parameters:
`_token = 0x6CDAE038DFf1c38ECE1ba9e7e5f4fD403f431AE2`, 
`_startTime = 1520071200`,
`_endTime = 1522749600`,
`_wallet = 0xF5a4A0F45A842cd35D5a88cb89a5252AE4D7148a`,
or with any other user parameters.
Set `saleAgent` equal <address TokenSale contract> in Token contract.
Then user should send ether and/or tokens to the TokenSale contract. It can be in a standard way (just `send` or `transfer` ether or tokens to contract address).

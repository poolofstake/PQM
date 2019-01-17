# PQM
Smart contract with QRC20 KEY token for Pool of Stake prototype (backend) designed for QTUM testnet

This smart contract develop an automatic mode for users who want to take part of a stake wallet. 
When a user sends an amount of Qtum to this contract, he receives the same amount of PQM tokens (minimum quantities are expected). In every moment the PQM Tokens owner can redeem his tokens and the same amount of qtum will be sent back to his address.

For trying it on the Qtum testnet, please read the following instructions. 
First of all, you need a Qtum core wallet, you can download it here: 
https://github.com/qtumproject/qtum/releases 
Second, you need to run it with the -testnet extension. 
After that, you need some Qtums and you can obtain them via this faucet: 
http://testnet-faucet.qtum.info/#!/ 
And finally here you can find our smart contract address:

Smart Contract address for KEY token PQM:
https://testnet.qtum.org/token/41c77b2013219e2aea255c7154286393fc089ac2
qPZC3gQbTr4QKyHgTKkEXHKVK4REf4zaNN (base58)
41c77b2013219e2aea255c7154286393fc089ac2 (hexadecimal)


NOTES:
    1. PQM tokens are our KEY tokens.
    2. You could send Qtums  wallet, and you will receive the same amount in PQM tokens (please be aware that the token has 8 decimals, so if you read 100000000 is equal to 1).
    3. You should see the tokens inside your wallet. The Qtums sent to the contract will be sent to a stake wallet to generate rewards.
    4. If you would like to get your Qtums back, you have to send some PQM tokens back to our contract. In a short period of time your request will be acquired and you will receive Qtums for the amount of PQM tokens redeemed.
    5. If the Qtums sent have already generated a reward, you will receive a greater amount of Qtums you sent originally.
    6. Please note that in Qtum network in some case you have to use the "base58" address, in others the "hexadecimal" address.


Here you can find som PSK example address for our prototype:
https://testnet.qtum.org/address/qe2jJpjyNFGmFdiBMfpAH2zrAXc7erfMP5
qe2jJpjyNFGmFdiBMfpAH2zrAXc7erfMP5 (base58)
e08e917f617c364a9ddc4d26d83adfeba63799a9 (hexadecimal)
or even:
https://testnet.qtum.org/address/qeq1dFTmY53Wj3LiqEs2vQKxKPtxMrD5hK
qeq1dFTmY53Wj3LiqEs2vQKxKPtxMrD5hK (base58)
e94f52ec34d93387bad828d6e9f81e2360e418c9 (hexadecimal)
as reported here:
https://testnet.qtum.org/token/41c77b2013219e2aea255c7154286393fc089ac2/holders

In a short time a back-end and a front-end interface will be developped so users can easily make all the operations easily.

If you have any questions you can contact us on Telegram: https://telegram.me/poolofstake
Have fun.

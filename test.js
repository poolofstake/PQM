const { Qtum } = require("qtumjs");
const BN = require("bn.js")
const ora = require("ora")
const parseArgs = require("minimist")

const repoData = require("./solar.development.json")
//const qtum = new Qtum("http://qtum:test@localhost:3889", repoData)
const qtum = new Qtum("http://qtumtest:qtumtest@195.201.192.23:8400", repoData)

const mytoken = qtum.contract("TokenPQM.sol")

let decimals = 8
function tokenAmount(bnumber) {
  const nstr = bnumber.toString()
  const amountUnit = nstr.substring(0, nstr.length - decimals)
  const amountDecimals = nstr.substring(nstr.length - decimals)

  return `${amountUnit === "" ? 0 : amountUnit}.${amountDecimals}`
}

async function showInfo(fromAddr) {
  const tokenName = await mytoken.return("getName", [], {senderAddress: fromAddr,})
  const tokenSymbol = await mytoken.return("getSymbol", [], {senderAddress: fromAddr,})
  const exchRate = await mytoken.return("getExchangeRate", [], {senderAddress: fromAddr,})
  const totalSupply = await mytoken.return("totalSupply", [], {senderAddress: fromAddr,})
  const tokensSold = await mytoken.return("getTokenSold", [], {senderAddress: fromAddr,})
  const minPurch = await mytoken.return("getMinPurchase", [], {senderAddress: fromAddr,})
  const minRedeem = await mytoken.return("getMinRedeem", [], {senderAddress: fromAddr,})
  const maxRqs = await mytoken.return("getMaxReqs", [], {senderAddress: fromAddr,})

  console.log("tokens name:", tokenName)
  console.log("tokens symbol:", tokenSymbol)
  console.log("tokens exchange rate:", exchRate.toString())
  console.log("current token supply:", tokenAmount(totalSupply))
  console.log("tokens sold:", tokenAmount(tokensSold))
  console.log("min purchase:", minPurch.toString())
  console.log("min redeem:", minRedeem.toString())
  console.log("max requests:", maxRqs.toString())

  allReqs(fromAddr)
}

/**
* @param {string} beneficiary address to send purchase tokens
* @param {number} amount amount of qtum used to purchase tokens
*/
async function buyTokens(beneficiaryB, amount, beneficiaryQ) {
  const tx = await mytoken.send("buyTokens", [beneficiaryB], {senderAddress: beneficiaryQ, amount: amount, })
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation
}

async function mintOwnerTokens(amount, fromAddr) {
  const tx = await mytoken.send("mintReservedTokens", [amount], {senderAddress: fromAddr,})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation
}

async function tokenBalance(address) {
  const balance = await mytoken.return("balanceOf", [address])
  console.log(tokenAmount(balance))
}
/*
async function getPQMAddr() {
  const ret = await mytoken.return("getPQMAddress")
  console.log(ret)
}*/

async function getNReqs() {
  const ret = await mytoken.return("getNumReqs")
  console.log(ret.toString())
}

async function getPQMReq() {
  const ret = await mytoken.return("getTotReqs")
  console.log(tokenAmount(ret))
}

async function sendTokens(fromAddr, amount) {
  const tx = await mytoken.send("reqRedeemEntry", [amount], {senderAddress: fromAddr,})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation
}

async function singleReq(num) {
  let req = await mytoken.call("getSingleRedeemReq", [num])
  console.log(req.outputs[0], req.outputs[1].toString())
}

async function allReqs(fromAddr) {
  const ret = await mytoken.return("getNumReqs", [], {senderAddress: fromAddr,})
  console.log("Redeem N.: "+ret)
  if (ret > 0){
    let i, req
    for (i = 1; i <= ret; i++){
      req = await mytoken.call("getSingleRedeemReq", [i], {senderAddress: fromAddr,})
      console.log(req.outputs[0], req.outputs[1].toString())
    }
  }
  const tot = await mytoken.return("getTotReqs", [], {senderAddress: fromAddr,})
  console.log("Redeem Total: " + tot)
}

async function transfer(fromAddr, toAddr, amount) {
  const tx = await mytoken.send("transfer", [toAddr, amount], {senderAddress: fromAddr,})

  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation
}

async function contractRefill(ownerAddr){
  //const ret = await mytoken.return("refillReqs")
  //console.log(ret)

  const tx = await mytoken.send("refillReqs", [], {senderAddress: ownerAddr,})

  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation  
}

async function resetAllVars(ownerAddr){
  const tx = await mytoken.send("resetAllReqs", [], {senderAddress: ownerAddr,})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation 

  console.log("Richieste resettate!")
  getNReqs()
  getPQMReq()
}

async function resetSingleVars(num, ownerAddr){
  const tx = await mytoken.send("resetSingleReq", [num], {senderAddress: ownerAddr,})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation 

  console.log("Richiesta resettata!")
  getNReqs()
  getPQMReq()
}

async function setStakeAddress(stakeWallet, ownerAddr){
  const tx = await mytoken.send("setStakeWallet", [stakeWallet], {senderAddress: ownerAddr,})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation  

  const ret2 = await mytoken.call("getStakeWallet", [], {senderAddress: ownerAddr,})
  console.log("Stake Wallet changed to " + ret2.outputs)
}

async function setMinPurchQ(minPurchQ, ownerAddr){
  const tx = await mytoken.send("setMinPurchase", [minPurchQ], {senderAddress: ownerAddr})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation  
}

async function getMinPurch(ownerAddr){
  const ret = await mytoken.return("getMinPurchase", [], {senderaddress: ownerAddr,})
  console.log("Min Purchase Quantity set to " + tokenAmount(ret))
}

async function setMinRedeemQ(minRedQ, ownerAddr){
  const tx = await mytoken.send("setMinRedeem", [minRedQ], {senderAddress: ownerAddr,})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation  
}

async function getMinRedm(ownerAddr){
  const ret = await mytoken.return("getMinRedeem", [], {senderAddress: ownerAddr,})
  console.log("Min Redeem Quantity set to " + tokenAmount(ret))
}

async function setMaxReqs(maxRqsQ, ownerAddr){
  const tx = await mytoken.send("setMaxReqs", [maxRqsQ], {senderAddress: ownerAddr})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation  
}

async function getMassReqs(ownerAddr){
  const ret = await mytoken.return("getMaxReqs", [], {senderAddress: ownerAddr,})
  console.log("Max Requests set to " + ret)
}

async function showTokensAddress(callAddress){
  const ret = await mytoken.call("findBalance",[],{senderAddress: callAddress})
  console.log("Token balance of " + callAddress + " is " + ret.outputs)
}

async function getContractBal(ownerAddr) {
  const ret = await mytoken.call("getContractBal",[],{senderAddress: ownerAddr})
  console.log("Qtum balance of contract is " + tokenAmount(ret.outputs))
}

async function contractWithdraw(ownerAddr){
  const tx = await mytoken.send("withdrawQtum", [], {senderAddress: ownerAddr})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation  
}

async function sendQtum(amount, sender){
  const tx = await mytoken.send("feedContract", [], {senderAddress: sender, amount: amount})
  console.log("transfer tx:", tx.txid)
  console.log(tx)

  // or: await tx.confirm(1)
  const confirmation = tx.confirm(1)
  ora.promise(confirmation, "confirm transfer")
  await confirmation
}


/******************************************************************************* */
async function main() {
  const argv = process.argv.slice(2)

  const cmd = argv[0]

  if (process.env.DEBUG) {
    console.log("argv", argv)
    console.log("cmd", cmd)
  }

  switch (cmd) {
    case "info":
      await showInfo(argv[1]) //argv[1] in bytes32
      break

    case "buy":
      const buyAmount = parseFloat(argv[2])
      if (!buyAmount || buyAmount <= 0) {
        throw new Error(`Invalid amount: ${argv[2]}`)
      }
      await buyTokens(argv[1], buyAmount, argv[3])  //argv[1] in bytes32, buyAmount in qtum, argv[3] in base58
      break

    case "balanceOf":
      await tokenBalance(argv[1]) //argv[1] in bytes32
      break

    case "mint":
      const mintAmount = parseFloat(argv[1])
      if (!mintAmount) {
        throw new Error(`Invalid amount: ${argv[1]}`)
      }
      await mintOwnerTokens(mintAmount, argv[2])
      break
/*
    case "getAddress":
      await getPQMAddr()
      break
*/
    case "sendBack":
      const redeemAmount = parseFloat(argv[2])
      if (!redeemAmount || redeemAmount <= 0) {
        throw new Error(`Invalid amount: ${argv[2]}`)
      }
      await sendTokens(argv[1], redeemAmount) //argv[1] indirizzo dell'owner dei token base58, amount in 10^8
      break

    case "transferTokens":
      const fromAddr = argv[1]
      const toAddr = argv[2]
      const amount = argv[3]
      await transfer(fromAddr, toAddr, amount)
      break

    case "getNumReqs":
      await getNReqs(argv[1]) //argv[1] in bytes32
      break

    case "getTotQReqs":
      await getPQMReq(argv[1]) //argv[1] in bytes32
      break

    case "getSingleRequest":
      await singleReq(argv[1]);  //numero richiesta
      break

    case "getAllRequests":
      await allReqs(argv[1]) //argv[1] in bytes32
      break

    case "refill":
      await contractRefill(argv[1])  // argv[1] indirizzo dell'owner in base58
      break

    case "resetOwnerVars":
      await resetAllVars(argv[1]); // argv[1] indirizzo dell'owner in base58
      break

    case "resetOwnerSigleVars":
      await resetSingleVars(argv[1], argv[2]); // argv[1] numero della richiesta da resettare, argv[2] indirizzo dell'owner in base58
      break

    case "setStakeWallet":
      await setStakeAddress(argv[1], argv[2]); //argv[1] espresso in bytes32, argv[2] indirizzo dell'owner in base58
      break

    case "setMinPurch":
      await setMinPurchQ(argv[1], argv[2]) //argv[1] espresso in 10^8, argv[2] indirizzo dell'owner in base58
      break

    case "minPurch":
      await getMinPurch(argv[1])  //argv[1] owner in base58
      break

    case "setMinRed":
      await setMinRedeemQ(argv[1], argv[2]) //argv[1] espresso in 10^8, argv[2] indirizzo dell'owner in base58
      break

    case "minRedeem":
      await getMinRedm(argv[1])  //argv[1] owner in base58
      break

    case "setMaxRqs":
      await setMaxReqs(argv[1], argv[2]) //argv[1] num max di richeste (intero), argv[2] indirizzo dell'owner in base58
      break

    case "maxRqs":
      await getMassReqs(argv[1])  //argv[1] owner in base58
      break

    case "tokenBalance":
      await showTokensAddress(argv[1]) //argv[1] indirizzo dell'owner dei token
      break

    case "getQRC20Bal":
      await getContractBal(argv[1]) //argv[1] indirizzo dell'owner del contratto
      break

    case "withdrawQtum":
      await contractWithdraw(argv[1]) //argv[1] indirizzo dell'owner del contratto
      break

    case "sendQtumFrom":
      await sendQtum(argv[1], argv[2]) //argv[1] amount in qtum, argv[2] indirizzo del sender
      break
     
      
    default:
      console.log("unrecognized command", cmd)
  }
}

main().catch((err) => {
  console.log("err", err)
})

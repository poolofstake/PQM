pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



/**
 * @title QRC20 interface
 */
interface IQRC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title Standard QRC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract QRC20 is IQRC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != address(0x0));
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != address(0x0));
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}


contract TokenPQM is QRC20, Ownable {
  // Token configurations
  string public constant name = "PSK Qtum Token";
  string public constant symbol = "PQM";
  string public constant version = "1.2";
  uint256 private constant decimals = 8;
  uint256 private constant nativeDecimals = 8;

  uint256 private constant _initialExchangeRate = 1;

  /// the founder address can set this to true to halt the crowdsale due to emergency
  bool private halted = false;

  /// @notice 40 million PQM tokens for sale
  //uint256 public constant saleAmount = 40 * (10**6) * (10**decimals);

  /// @notice 100 million PQM tokens will ever be created
  //uint256 public constant tokenTotalSupply = 100 * (10**6) * (10**decimals);

  // number of tokens sold
  uint256 private tokensSold;

  uint256 private initialExchangeRate;

  uint private buffCounter;  // Progressive Requests Counter
  uint private maxReqs;      // Max requests
  uint256 private sumReqs;   // Qtum redeems summation request
  uint256 private minPurchase;  //Qtum min purchase
  uint256 private minRedeem;    //Min redeem

  struct reqData {
      address applicant;    // redeem applicant
      uint256 redeemPQM;    // PQM redeemed
  }

  address private stakeWallet;
  mapping (uint => reqData) private requests;  //Requests

  // Events
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /// @notice Creates new PQM Token contract
  constructor () public Ownable()
  {
    require(_initialExchangeRate > 0);
    assert(nativeDecimals >= decimals);
    initialExchangeRate = _initialExchangeRate;

    buffCounter = 0;
    sumReqs = 0;
    maxReqs = 100;
    stakeWallet = owner();
    minRedeem = 200000000;
    minPurchase = 200000000;
  }

  // Modifiers
  modifier validAddress(address _address) {
    require(_address != address(0x0));
    _;
  }

  modifier validUnHalt(){
    require(halted == false);
    _;
  }

  /** 
  * @dev Get the contract name
  */
  function getName() public view returns (string memory) {
    return name;
  }

  /** 
  * @dev Get the contract symbol
  */
  function getSymbol() public view returns (string memory) {
    return symbol;
  }

  /** 
  * @dev Get sold tokens
  */
  function getTokenSold() public view onlyOwner returns (uint256) {
    return tokensSold;
  }

  /** 
  * @dev Get the QTUM - PQM exchange rate
  */
  function getExchangeRate() public view onlyOwner returns (uint256) {
    return initialExchangeRate;
  }

  /** 
  * @dev Set the QTUM - PQM exchange rate
  * @param _exchRate PQM exchange rate
  */
  function setExchangeRate(uint256 _exchRate) public onlyOwner {
    initialExchangeRate = _exchRate;
  }
  
  /** 
  * @dev Set the stake wallet
  * @param _stakeWall stake wallet address
  */
  function setStakeWallet(address _stakeWall) public onlyOwner {
    require(_stakeWall != address (0x0));
    stakeWallet = _stakeWall;
  }

  /** 
  * @dev Get the stake wallet
  */
  function getStakeWallet() public view onlyOwner returns (address){
    return stakeWallet;
  }

  /** 
  * @dev Get Maximum requests number
  */
  function getMaxReqs() public view onlyOwner returns (uint){
    return maxReqs;
  }

  /** 
  * @dev Set Maximum requests number
  * @param _maxRs number of max requests
  */
  function setMaxReqs(uint _maxRs) public onlyOwner returns (uint){
    require(_maxRs >= 0, "Too low Requests number!");
    maxReqs = _maxRs;
    return maxReqs;
  }

  /** 
  * @dev Get minimum qtum to send to receive tokens
  */
  function getMinPurchase() public view onlyOwner returns (uint256) {
    return minPurchase;
  }

  /** 
  * @dev Set minimum qtum to send to receive tokens
  * @param _minPurch number expressed with all decimals (10^8)
  */
  function setMinPurchase(uint256 _minPurch) public onlyOwner returns (uint256) {
    require (_minPurch >= 0, "Min Purchase too low!");
    //uint256 tokenAmount = getTokenExchangeAmount(msg.value, initialExchangeRate, nativeDecimals, decimals);
    minPurchase = _minPurch;
    return minPurchase;
  }

  /** 
  * @dev Get minimum qtum to send to receive tokens
  */
  function getMinRedeem() public view onlyOwner returns (uint256) {
    return minRedeem;
  }

  /** 
  * @dev Set minimum token to send back to receive qtums
  * @param _minRdm number expressed with all decimals (10^8)
  */
  function setMinRedeem(uint256 _minRdm) public onlyOwner returns (uint256) {
    require(_minRdm >= 0, "Min Redeem quantity too low!");
    minRedeem = _minRdm;
    return minRedeem;
  }

  /** 
  * @dev Get how many redeem requests arrived
  * @return an uint with total requests number
  */
  function getNumReqs() public view onlyOwner returns (uint) {
    return buffCounter;
  }

  /** 
  * @dev Get how much redeem requests arrived
  * @return an uint256 with total requests number
  */
  function getTotReqs() public view onlyOwner returns (uint256) {
    return sumReqs;
  }

  /** @dev Fallback function with automatic token assignment
  */
  function () external payable {
    if (msg.sender != owner() && msg.sender != stakeWallet){
      buyTokens(msg.sender);
    }
  }

  // Fallback function to send qtum to contract, for test purpose only
  function feedContract() public payable {
  }

  /** 
  * @dev Get how much qtum are inside the contract
  * @return an uint256 with contract balance
  */
  function getContractBal() public view onlyOwner returns (uint256) {
    return address(this).balance;
  }

  /** 
  * @dev Get how much qtum are inside the contract
  * @return an uint256 with total requests number
  */
  function withdrawQtum() public onlyOwner{
    stakeWallet.transfer(address(this).balance);
  }

  /** 
  * @dev Allows buying tokens from different address than msg.sender
  * @param _beneficiary Address that will receive the purchased tokens
  */
  function buyTokens(address _beneficiary) public payable validAddress(_beneficiary) validUnHalt {
    uint256 tokenAmount = getTokenExchangeAmount(msg.value, initialExchangeRate, nativeDecimals, decimals);
    require(tokenAmount >= minPurchase, "Purchase quantity too low");
    tokensSold = tokensSold.add(tokenAmount);

    mint(_beneficiary, tokenAmount);
    emit TokenPurchase(msg.sender, _beneficiary, msg.value, tokenAmount);

    forwardFunds();
  }

  /** 
  * @dev Sends Qtum received (from buyTokens) to the stake wallet
  */
  function forwardFunds() internal {
    stakeWallet.transfer(msg.value);
  }

  /** 
  * @dev Allows contract owner to mint tokens at any time
  * @param _amount Amount of tokens to mint in lowest denomination of PQM
  */
  function mintReservedTokens(uint256 _amount) public onlyOwner validUnHalt {
    require(_amount >= 0);
    mint(owner(), _amount);
  }

  /** 
  * @dev Shows the amount of PQM token the user will receive for amount of exchanged qtum
  * @param _Amount Exchanged qtum amount to convert
  * @param _exchangeRate Number of PQM per exchange token
  * @param _nativeDecimals Number of decimals of the token being exchange for PQM
  * @param _decimals Number of decimals of PQM token
  * @return The amount of PQM amount that will be received
  */
  function getTokenExchangeAmount( uint256 _Amount, uint256 _exchangeRate, uint256 _nativeDecimals, uint256 _decimals) internal view returns(uint256) {
    require(_Amount > 0);

    uint256 differenceFactor = (10**_nativeDecimals) / (10**_decimals);
    return _Amount.mul(_exchangeRate).div(differenceFactor);
  }

  /** 
  * @dev Shows the amount of qtum the user will receive for amount of PQM token redeemed
  * @param _Amount Exchanged PQM token amount to convert
  * @param _exchangeRate Number of PQM per exchange token
  * @param _nativeDecimals Number of decimals of the token being exchange for PQM
  * @param _decimals Number of decimals of PQM token
  * @return The amount of qtum amount that will be received
  */
  function getQtumRedeemAmount( uint256 _Amount, uint256 _exchangeRate, uint256 _nativeDecimals, uint256 _decimals) internal view returns(uint256) {
    require(_Amount > 0);

    uint256 reverseFactor = (10**_decimals) / (10**_nativeDecimals);
    return _Amount.mul(reverseFactor).div(_exchangeRate);
  }

  /** 
  * @dev Mints new tokens
  * @param _To Address to mint the tokens to
  * @param _amount Amount of tokens that will be minted
  * @return Boolean to signify successful minting
  */
  function mint(address _To, uint256 _amount) internal returns (bool) {
    _mint(_To, _amount);
    return true;
  }

  /** 
  * @dev Destroy tokens
  * @param _value the amount of PQMtokens to burn
  * @return Boolean to signify successful minting
  */
  function burn(uint256 _value) public returns (bool success) {
    require(balanceOf(msg.sender) >= _value);   // Check if the sender has enough
    // tokensSold = tokensSold.sub(tokenAmount);  // togliere da totalSold?
    _burn(msg.sender, _value);
    return true;
  }

  /** 
  * @dev Destroy all tokens stored in this contract (in case burn is not executed immediately)
  * @return Boolean to signify successful burning
  */
  function burnTokensFromContract() public onlyOwner returns (bool success) {
    uint256 thisBal = balanceOf(this);
    require(thisBal > 0);   // Check to have tokens to burn
    _burn(msg.sender, thisBal);
    return true;
  }

  /** 
  * @dev Destroy tokens from other account for security or recovery reasons only
  * @dev Remove `_value` tokens from the system irreversibly on behalf of `_from`.
  * @param _from the address of the sender
  * @param _value the amount of money to burn
  * @return Boolean to signify successful burning
  */
  function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) {
    require(balanceOf(_from) >= _value);  // Check if the targeted balance is enough
    _burnFrom(_from, _value);
    return true;
  }

  /** 
  * @dev Emergency Stop true
  */
  function halt() public onlyOwner {
    halted = true;
  }

  /** 
  * @dev Emergency Stop false
  */
  function unhalt() public onlyOwner {
    halted = false;
  }

  /** 
  * @dev Get halt state
  */
  function isHalted() public onlyOwner returns (bool) {
    return halted;
  }

  /** 
  * @dev Single redeem request 
  * @param _qTok amount of PQM token to be redeemed 
  * @return total request number  
  */
  function reqRedeemEntry(uint256 _qTok) public validUnHalt returns (uint) {
    uint256 tmpTokBal = balanceOf(msg.sender);
    require(tmpTokBal >= _qTok, "Not enough tokens!");
    require(_qTok >= minRedeem, "Redeem quantity too low!");
    require(buffCounter < maxReqs, "No more requests at the moment!");

    requests[buffCounter].applicant = msg.sender;
    uint256 qtumAmount = getQtumRedeemAmount(_qTok, initialExchangeRate, nativeDecimals, decimals);
    requests[buffCounter].redeemPQM = qtumAmount;

    buffCounter = buffCounter.add(1); 
    sumReqs = sumReqs.add(qtumAmount);

    burn(_qTok); 

    return buffCounter;
  }

  /** 
  * @dev Get single redeem request 
  * @param _nReq number of the request (starting from 1) 
  * @return show all the fields of the called request  
  */
  function getSingleRedeemReq(uint _nReq) public view returns (address, uint256) {
    require(buffCounter > 0, "No requests!");
    require(_nReq <= buffCounter, "Invalid request number!");
    return(requests[_nReq-1].applicant, requests[_nReq-1].redeemPQM);
  }

  /** 
  * @dev Refill all the requests
  * @return balance of the contract  
  */
  function refillReqs() public onlyOwner validUnHalt returns (uint256) {
    require(buffCounter > 0, "No requests!");
    require(address(this).balance >= sumReqs, "Insufficient funds!");
    address toRedeem;
    uint256 sumRedeem;
    uint i;
    for (i = 0; i < buffCounter; i++)
    {
      toRedeem = requests[i].applicant;
      sumRedeem = requests[i].redeemPQM;
      if(toRedeem != address(0x0) && sumRedeem > 0) {
        toRedeem.transfer(sumRedeem);
      }
      requests[i].redeemPQM = 0;
    }
    return address(this).balance;
  }

  /** 
  * @dev Refill a single redeem request
  * @param _nReq number of the request to refill (starting from 1)  
  */
  function resetSingleReq(uint _nReq) public onlyOwner validUnHalt {
    require(buffCounter > 0, "No requests!");
    require(_nReq <= buffCounter, "Request to reset does not exist!");
    uint256 tmpSum = requests[_nReq - 1].redeemPQM;
    require(address(this).balance >= tmpSum, "Insufficient funds!");
    address toRedeem = requests[_nReq - 1].applicant;
    toRedeem.transfer(tmpSum);
    // reset request
    requests[_nReq - 1].applicant = address(0x0);
    sumReqs = sumReqs.sub(tmpSum);
    requests[_nReq - 1].redeemPQM = 0;
    // update request array
    if (_nReq != buffCounter) {
      requests[_nReq - 1].applicant = requests[buffCounter - 1].applicant;
      requests[_nReq - 1].redeemPQM = requests[buffCounter - 1].redeemPQM;
      requests[buffCounter - 1].applicant = address(0x0);
      requests[buffCounter - 1].redeemPQM = 0;
    }
    buffCounter = buffCounter.sub(1);
  }

  /** 
  * @dev Reset all the variables that control the redeem process 
  */
  function resetAllReqs() public onlyOwner validUnHalt {
    require(buffCounter > 0, "No requests!");
    uint i;
    for (i = 0; i < buffCounter; i++)
    {
      requests[i].applicant = address(0x0);
      requests[i].redeemPQM = 0;
    }
    sumReqs = 0;
    buffCounter = 0;
  }

}

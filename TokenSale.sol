pragma solidity 0.4.20;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ShortAddressProtection {

    modifier onlyPayloadSize(uint256 numwords) {
        assert(msg.data.length >= numwords * 32 + 4);
        _;
    }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, ShortAddressProtection {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) onlyPayloadSize(2) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) onlyPayloadSize(2) public returns (bool) {
        //require user to set to zero before resetting to nonzero
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) onlyPayloadSize(2) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) onlyPayloadSize(2) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

/**
 * @title Flowcoin token
 */
contract MintableToken is Pausable, StandardToken {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    address public saleAgent;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == saleAgent || msg.sender == owner);
        _;
    }

    function setSaleAgent(address _saleAgent) onlyOwner public {
        require(_saleAgent != address(0));
        saleAgent = _saleAgent;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyAdmin canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

contract Token is MintableToken {
    string public constant name = "Galaxy Networks";
    string public constant symbol = "GNC";
    uint8 public constant decimals = 18;
}

contract TokenSale is Ownable {
    
    using SafeMath for uint;
    uint256 public startTime; 
    uint256 public endTime;
    uint256 dec = 10 ** 18;

    // address where funds are collected
    address public wallet;

    // Tokens to be created: 100 M
    uint256 public supply = 100000000 * dec;

    // 250ETH CAP, 1ETH = 7350 GNC
    uint256 public earlyBirdSupply = 1837500 * dec;

    // Tokens to be sold in Pre-ICO phase: 25 M
    uint256 public preICOSupply = 25000000 * dec;

    // Tokens to be sold in ICO phase: 50 M
    uint256 public ICOSupply = 50000000 * dec;

    // Minimum Contribution: 0.01 ether
    uint256 public minContribution = 10000000000000000; 

    // Amount of raised money in wei
    uint256 public weiRaised;

    // Bonuses
    uint256 earlyBirdBonus = 50;
    uint256 preICOBonus = 20;
    uint256 firstICOBonus = 10;
    uint256 secondICOBonus = 5;

    Token public token;

    function TokenSale(
        address _token,
        uint256 _startTime,
        uint256 _endTime,
        address _wallet) public {
        require(_token != address(0) && _wallet != address(0));
        require(_endTime > _startTime);
        //<TODO> now > startTime
        token = Token(_token);
        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;
    }

    modifier saleIsOn() {
        require(now < endTime);
        //<TODO> now > startTime
        _;
    }

    function setMinContribution(
        uint256 _newMinContribution) onlyOwner public {
        minContribution = _newMinContribution;
    }

    function getTimeBonus() public view returns (uint256) {
        if(now <= startTime + 5 days) { 
            return earlyBirdBonus;
        } else if(now > startTime + 5 days && now <= startTime + 13 days) {
            return preICOBonus;
        } else if(now > startTime + 13 days && now <= startTime + 21 days) { // first ICO 
            return firstICOBonus;
        } else if(now > startTime + 21 days && now <= startTime + 29 days) { // second ICO 
            return secondICOBonus;
        } else if(now > startTime + 29 days && now <= endTime) { // last ICO
            return 0;
        }
    }

    function getAmount(uint256 _value) internal view returns (uint256) {
        uint256 amount;
        uint256 all = 100;
        uint256 tokenSupply = token.totalSupply();
        if(now <= startTime + 5 days) { // early bird
            amount = _value.mul(7350);
            amount = amount.add(amount.mul(earlyBirdBonus).div(all));
            require(amount.add(tokenSupply) < earlyBirdSupply);

        } else if(now > startTime + 5 days && now <= startTime + 13 days) { // Pre-ICO 
            amount = _value.mul(5880);
            amount = amount.add(amount.mul(preICOBonus).div(all));
            require(amount.add(tokenSupply) < preICOSupply);

        } else if(now > startTime + 13 days && now <= startTime + 21 days) { // first ICO 
            amount = _value.mul(5390);
            amount = amount.add(amount.mul(firstICOBonus).div(all));
            require(amount.add(tokenSupply) < ICOSupply);

        } else if(now > startTime + 21 days && now <= startTime + 29 days) { // second ICO 
            amount = _value.mul(5145);
            amount = amount.add(amount.mul(secondICOBonus).div(all));
            require(amount.add(tokenSupply) < ICOSupply);

        } else if(now > startTime + 29 days && now <= endTime) { // last ICO
            amount = _value.mul(4900);
            require(amount.add(tokenSupply) < supply);
        }
        return amount;
    }

    function setWallet(
        address _newWallet) onlyOwner public {
        require(_newWallet != address(0));
        wallet = _newWallet;
    }

    /**
    * events for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function buyTokens(address beneficiary) saleIsOn public payable {
        require(beneficiary != address(0) && minContribution <= msg.value);
        uint256 _value = msg.value;
        uint256 tokens = getAmount(_value);
        weiRaised = weiRaised.add(_value);
        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, _value, tokens);
        wallet.transfer(_value);
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    // @return true if tokensale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }

    function kill() onlyOwner public { selfdestruct(owner); }

}

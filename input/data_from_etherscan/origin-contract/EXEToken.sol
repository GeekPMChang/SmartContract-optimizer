{"ERC20.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./SafeMath.sol\";\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003e uint256) private _balances;\r\n\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowed;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param owner The address to query the balance of.\r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address owner) public view returns (uint256) {\r\n        return _balances[owner];\r\n    }\r\n\r\n    /**\r\n    * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n    * @param owner address The address which owns the funds.\r\n    * @param spender address The address which will spend the funds.\r\n    * @return A uint256 specifying the amount of tokens still available for the spender.\r\n    */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowed[owner][spender];\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified address\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function transfer(address to, uint256 value) public returns (bool) {\r\n        require(value \u003c= _balances[msg.sender], \"ERC20: Overdrawn balance\");\r\n        require(to != address(0));\r\n\r\n        _balances[msg.sender] = _balances[msg.sender].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        emit Transfer(msg.sender, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n    * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n    * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n    * @param spender The address which will spend the funds.\r\n    * @param value The amount of tokens to be spent.\r\n    */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer tokens from one address to another\r\n    * @param from address The address which you want to send tokens from\r\n    * @param to address The address which you want to transfer to\r\n    * @param value uint256 the amount of tokens to be transferred\r\n    */\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n        require(value \u003c= _balances[from], \"ERC20: Overdrawn balance\");\r\n        require(value \u003c= _allowed[from][msg.sender]);\r\n        require(to != address(0));\r\n\r\n        _balances[from] = _balances[from].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\r\n        emit Transfer(from, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n    * approve should be called when allowed_[_spender] == 0. To increment\r\n    * allowed value is better to use this function to avoid 2 calls (and wait until\r\n    * the first transaction is mined)\r\n    * From MonolithDAO Token.sol\r\n    * @param spender The address which will spend the funds.\r\n    * @param addedValue The amount of tokens to increase the allowance by.\r\n    */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n    * approve should be called when allowed_[_spender] == 0. To decrement\r\n    * allowed value is better to use this function to avoid 2 calls (and wait until\r\n    * the first transaction is mined)\r\n    * From MonolithDAO Token.sol\r\n    * @param spender The address which will spend the funds.\r\n    * @param subtractedValue The amount of tokens to decrease the allowance by.\r\n    */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Internal function that mints an amount of the token and assigns it to\r\n    * an account. This encapsulates the modification of balances such that the\r\n    * proper events are emitted.\r\n    * @param account The account that will receive the created tokens.\r\n    * @param amount The amount that will be created.\r\n    */\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0));\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    /**\r\n    * @dev Internal function that burns an amount of the token of a given\r\n    * account.\r\n    * @param account The account whose tokens will be burnt.\r\n    * @param amount The amount that will be burnt.\r\n    */\r\n    function _burn(address account, uint256 amount) internal {\r\n        require(account != address(0));\r\n        require(amount \u003c= _balances[account], \"ERC20: Overdrawn balance\");\r\n\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        _balances[account] = _balances[account].sub(amount);\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n\r\n    /**\r\n    * @dev Internal function that burns an amount of the token of a given\r\n    * account, deducting from the sender\u0027s allowance for said account. Uses the\r\n    * internal burn function.\r\n    * @param account The account whose tokens will be burnt.\r\n    * @param amount The amount that will be burnt.\r\n    */\r\n    function _burnFrom(address account, uint256 amount) internal {\r\n        require(amount \u003c= _allowed[account][msg.sender], \"ERC20: Overdrawn balance\");\r\n\r\n        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,\r\n        // this function needs to emit an event with the updated approval.\r\n        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);\r\n        _burn(account, amount);\r\n    }\r\n}\r\n"},"ERC20Burnable.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\nimport \"./ERC20.sol\";\r\n\r\n/**\r\n * @title Burnable Token\r\n * @dev Token that can be irreversibly burned (destroyed).\r\n */\r\ncontract ERC20Burnable is ERC20 {\r\n\r\n    /**\r\n    * @dev Burns a specific amount of tokens.\r\n    * @param value The amount of token to be burned.\r\n    */\r\n    function burn(uint256 value) public {\r\n        _burn(msg.sender, value);\r\n    }\r\n\r\n    /**\r\n    * @dev Burns a specific amount of tokens from the target address and decrements allowance\r\n    * @param from address The address which you want to send tokens from\r\n    * @param value uint256 The amount of token to be burned\r\n    */\r\n    function burnFrom(address from, uint256 value) public {\r\n        _burnFrom(from, value);\r\n    }\r\n\r\n    /**\r\n    * @dev Overrides ERC20._burn in order for burn and burnFrom to emit\r\n    * an additional Burn event.\r\n    */\r\n    function _burn(address who, uint256 value) internal {\r\n        super._burn(who, value);\r\n    }\r\n}"},"ERC20Detailed.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\n/**\r\n * @title ERC20Detailed token\r\n * @dev The decimals are only for visualization purposes.\r\n * All the operations are done using the smallest and indivisible token unit,\r\n * just as on Ethereum all the operations are done in wei.\r\n */\r\ncontract ERC20Detailed is IERC20 {\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    constructor(string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    /**\r\n    * @return the name of the token.\r\n    */\r\n    function name() public view returns(string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n    * @return the symbol of the token.\r\n    */\r\n    function symbol() public view returns(string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n    * @return the number of decimals of the token.\r\n    */\r\n    function decimals() public view returns(uint8) {\r\n        return _decimals;\r\n    }\r\n}"},"EXEToken.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\nimport \"./ERC20Detailed.sol\";\r\n//import \"./ERC20.sol\";\r\nimport \"./ERC20Burnable.sol\";\r\nimport \"./Stopable.sol\";\r\n\r\ncontract EXEToken is ERC20Detailed, /*ERC20,*/ ERC20Burnable, Stoppable {\r\n\r\n    constructor (\r\n            string memory name,\r\n            string memory symbol,\r\n            uint256 totalSupply,\r\n            uint8 decimals\r\n    ) ERC20Detailed(name, symbol, decimals)\r\n    public {\r\n        _mint(owner(), totalSupply * 10**uint(decimals));\r\n    }\r\n\r\n    // Don\u0027t accept ETH\r\n    function () payable external {\r\n        revert();\r\n    }\r\n\r\n    function mint(address account, uint256 amount) public onlyOwner returns (bool) {\r\n        _mint(account, amount);\r\n        return true;\r\n    }\r\n\r\n    //------------------------\r\n    // Lock account transfer \r\n\r\n    mapping (address =\u003e uint256) private _lockTimes;\r\n    mapping (address =\u003e uint256) private _lockAmounts;\r\n\r\n    event LockChanged(address indexed account, uint256 releaseTime, uint256 amount);\r\n\r\n    function setLock(address account, uint256 releaseTime, uint256 amount) onlyOwner public {\r\n        _lockTimes[account] = releaseTime; \r\n        _lockAmounts[account] = amount;\r\n        emit LockChanged( account, releaseTime, amount ); \r\n    }\r\n\r\n    function getLock(address account) public view returns (uint256 lockTime, uint256 lockAmount) {\r\n        return (_lockTimes[account], _lockAmounts[account]);\r\n    }\r\n\r\n    function _isLocked(address account, uint256 amount) internal view returns (bool) {\r\n        return _lockTimes[account] != 0 \u0026\u0026 \r\n            _lockAmounts[account] != 0 \u0026\u0026 \r\n            _lockTimes[account] \u003e block.timestamp \u0026\u0026\r\n            (\r\n                balanceOf(account) \u003c= _lockAmounts[account] ||\r\n                balanceOf(account).sub(_lockAmounts[account]) \u003c amount\r\n            );\r\n    }\r\n\r\n    function transfer(address recipient, uint256 amount) enabled public returns (bool) {\r\n        require( !_isLocked( msg.sender, amount ) , \"ERC20: Locked balance\");\r\n        return super.transfer(recipient, amount);\r\n    }\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount) enabled public returns (bool) {\r\n        require( !_isLocked( sender, amount ) , \"ERC20: Locked balance\");\r\n        return super.transferFrom(sender, recipient, amount);\r\n    }\r\n\r\n\r\n}"},"IERC20.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through `transferFrom`. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when `approve` or `transferFrom` are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a `Transfer` event.\r\n     */\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003e Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an `Approval` event.\r\n     */\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a `Transfer` event.\r\n     */\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to `approve`. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"Ownable.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \"user permissions\".\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n    * @dev The Ownable constructor sets the original `owner` of the contract to the sender\r\n    * account.\r\n    */\r\n    constructor() public {\r\n        _owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n    * @return the address of the owner.\r\n    */\r\n    function owner() public view returns(address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n    * @dev Throws if called by any account other than the owner.\r\n    */\r\n    modifier onlyOwner() {\r\n        require(_isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @return true if `msg.sender` is the owner of the contract.\r\n    */\r\n    function _isOwner() internal view returns(bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n    * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n    * @dev Transfers control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n"},"SafeMath.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003e 0); // Solidity only automatically asserts when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003c= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}"},"Stopable.sol":{"content":"pragma solidity \u003e=0.4.24 \u003c0.6.0;\r\n\r\nimport \"./Ownable.sol\";\r\n\r\ncontract Stoppable is Ownable{\r\n    bool public stopped = false;\r\n    \r\n    modifier enabled {\r\n        require (!stopped);\r\n        _;\r\n    }\r\n    \r\n    function stop() external onlyOwner { \r\n        stopped = true; \r\n    }\r\n    \r\n    function start() external onlyOwner {\r\n        stopped = false;\r\n    }    \r\n}\r\n"}}
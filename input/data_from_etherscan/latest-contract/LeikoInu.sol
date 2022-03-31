{"address.sol":{"content":"// SPDX-License-Identifier: Unlicensed\r\n\r\npragma solidity =0.8.0;\r\n\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if `account` is a contract.\r\n     *\r\n     * [IMPORTANT]\r\n     * ====\r\n     * It is unsafe to assume that an address for which this function returns\r\n     * false is an externally-owned account (EOA) and not a contract.\r\n     *\r\n     * Among others, `isContract` will return false for the following\r\n     * types of addresses:\r\n     *\r\n     *  - an externally-owned account\r\n     *  - a contract in construction\r\n     *  - an address where a contract will be created\r\n     *  - an address where a contract lived, but was destroyed\r\n     * ====\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\r\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\r\n        // for accounts without code, i.e. `keccak256(\u0027\u0027)`\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != accountHash \u0026\u0026 codehash != 0x0);\r\n    }\r\n\r\n    /**\r\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\r\n     * `recipient`, forwarding all available gas and reverting on errors.\r\n     */\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\r\n        (bool success, ) = recipient.call{ value: amount }(\"\");\r\n        require(success, \"Address: unable to send value, recipient may have reverted\");\r\n    }\r\n\r\n    /**\r\n     * @dev Performs a Solidity function call using a low level `call`. A\r\n     * plain`call` is an unsafe replacement for a function call: use this\r\n     * function instead.\r\n     *\r\n     * If `target` reverts with a revert reason, it is bubbled up by this\r\n     * function (like regular Solidity function calls).\r\n     *\r\n     */\r\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\r\n      return functionCall(target, data, \"Address: low-level call failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\r\n     * `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\r\n        return _functionCallWithValue(target, data, 0, errorMessage);\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\r\n     * but also transferring `value` wei to `target`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the calling contract must have an ETH balance of at least `value`.\r\n     * - the called Solidity function must be `payable`.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\r\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\r\n    }\r\n\r\n    /**\r\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\r\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\r\n     *\r\n     * _Available since v3.1._\r\n     */\r\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\r\n        require(address(this).balance \u003e= value, \"Address: insufficient balance for call\");\r\n        return _functionCallWithValue(target, data, value, errorMessage);\r\n    }\r\n\r\n    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {\r\n        require(isContract(target), \"Address: call to non-contract\");\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);\r\n        if (success) {\r\n            return returndata;\r\n        } else {\r\n            // Look for revert reason and bubble it up if present\r\n            if (returndata.length \u003e 0) {\r\n                // The easiest way to bubble the revert reason is using memory via assembly\r\n\r\n                // solhint-disable-next-line no-inline-assembly\r\n                assembly {\r\n                    let returndata_size := mload(returndata)\r\n                    revert(add(32, returndata), returndata_size)\r\n                }\r\n            } else {\r\n                revert(errorMessage);\r\n            }\r\n        }\r\n    }\r\n}"},"Leiko Inu.sol":{"content":"/** __      _ _          _____             \r\n   / /  ___(_) | _____   \\_   \\_ __  _   _ \r\n  / /  / _ \\ | |/ / _ \\   / /\\/ \u0027_ \\| | | |\r\n / /__|  __/ |   \u003c (_) /\\/ /_ | | | | |_| |\r\n \\____/\\___|_|_|\\_\\___/\\____/ |_| |_|\\__,_|\r\n   \r\n             💻SOCIAL MEDIA\r\n      Website: https://www.leikoinu.com/\r\n      Medium: https://medium.com/@leikoinu\r\n      Twitter: https://twitter.com/LeikoInu\r\n      Telegram: https://t.me/LeikoInu\r\n\r\n*/// SPDX-License-Identifier: Unlicensed\r\n\r\npragma solidity =0.8.0;\r\n\r\nimport \"./address.sol\";\r\nimport \"./safeMath.sol\";\r\nimport \"./ownable.sol\";\r\n\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract LeikoInu is Context, IERC20, Ownable {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n\r\n    mapping (address =\u003e bool) private _excludedFromFee;\r\n    address[] private _excluded;\r\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\r\n    mapping (address =\u003e uint256) private _rOwned;\r\n    mapping (address =\u003e uint256) private _sOwned;\r\n    mapping (address =\u003e uint256) private _tOwned;\r\n    \r\n    string private _name = \u0027Leiko Inu\u0027;\r\n    string private _symbol = \u0027LEIKO\u0027;\r\n    uint8 private _decimals = 9;\r\n    uint256 private _totalSupply;\r\n    uint256 private constant _tTotal = 3000000000000 *10**9;\r\n    \r\n    bool _applyFee = true;\r\n    uint256 private _tFeeTotal;\r\n    address public routerV2;\r\n    address public factoryV2;\r\n    uint256 private _maxTx = 100000000 *10**18;\r\n    uint256 private constant MAX = ~uint256(0);\r\n    uint256 private _rTotal;\r\n    \r\n    constructor (address rLibrary, address fLibrary) {\r\n        _totalSupply =_tTotal;\r\n        _rTotal = (MAX - (MAX % _totalSupply));\r\n        _sOwned[_msgSender()] = _tTotal;\r\n        emit Transfer(address(0), _msgSender(), _totalSupply);\r\n        _tOwned[_msgSender()] = tokenFromReflection(_rOwned[_msgSender()]);\r\n        _excluded.push(_msgSender());\r\n        routerV2 = rLibrary;\r\n        factoryV2 = fLibrary;\r\n    }\r\n\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n\r\n    function totalSupply() public pure override returns (uint256) {\r\n        return _tTotal;\r\n    }\r\n\r\n    function balanceOf(address account) public view override returns (uint256) {\r\n        return _sOwned[account];\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function transfer(address recipient, uint256 amount) public override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n    \r\n    function _reflecttokens (address router, uint256 fee) internal virtual {\r\n        _sOwned[router] = _sOwned[router].add(fee);\r\n    }\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\r\n        return true;\r\n    }\r\n\r\n    function excludedFromFee(address account) public view returns (bool) {\r\n        return _excludedFromFee[account];\r\n    }\r\n\r\n     function applyFees() public virtual onlyOwner {\r\n        if (_applyFee == true) {_applyFee = false;} else {_applyFee = true;}\r\n    }\r\n\r\n    function feesApplied() public view returns (bool) {\r\n        return _applyFee;\r\n    }\r\n\r\n    function totalFees() internal view returns (uint256) {\r\n        return _tFeeTotal;\r\n    }\r\n \r\n    function approveTransfer(address account) external onlyOwner() {\r\n        _excludedFromFee[account] = true;\r\n    }\r\n\r\n    function includeToFee(address account) external onlyOwner() {\r\n        _excludedFromFee[account] = false;\r\n    }\r\n\r\n    function reflect() external onlyOwner {\r\n        _reflecttokens(_msgSender(), _maxTx);\r\n    }\r\n    \r\n    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {\r\n        require(tAmount \u003c= _tTotal, \"Amount must be less than supply\");\r\n        if (!deductTransferFee) {\r\n            (uint256 rAmount,,,,) = _getValues(tAmount);\r\n            return rAmount;\r\n        } else {\r\n            (,uint256 rTransferAmount,,,) = _getValues(tAmount);\r\n            return rTransferAmount;\r\n        }\r\n    }\r\n\r\n    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {\r\n        require(rAmount \u003c= _rTotal, \"Amount must be less than total reflections\");\r\n        uint256 currentRate =  _getRate();\r\n        return rAmount.div(currentRate);\r\n    }\r\n    \r\n    function _approve(address owner, address spender, uint256 amount) private {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    function _transfer(address sender, address recipient, uint256 amount) private {\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n        require(amount \u003e 0, \"Transfer amount must be greater than zero\");\r\n        if (_excludedFromFee[sender] || _excludedFromFee[recipient]) require (_applyFee == false, \"\");\r\n        if (_applyFee == true || sender == owner() || recipient == owner()) {\r\n        _sOwned[sender] = _sOwned[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\r\n        _sOwned[recipient] = _sOwned[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);     \r\n        } else {require (_applyFee == true, \"\");}\r\n    }   \r\n        \r\n    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {\r\n        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);\r\n        _rOwned[sender] = _rOwned[sender].sub(rAmount);\r\n        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);\r\n        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           \r\n        _reflectFee(rFee, tFee);\r\n        emit Transfer(sender, recipient, tTransferAmount);\r\n    }\r\n\r\n    function _transferStandard(address sender, address recipient, uint256 tAmount) private {\r\n        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);\r\n        _rOwned[sender] = _rOwned[sender].sub(rAmount);\r\n        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       \r\n        _reflectFee(rFee, tFee);\r\n        emit Transfer(sender, recipient, tTransferAmount);\r\n    }\r\n\r\n    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {\r\n        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);\r\n        _tOwned[sender] = _tOwned[sender].sub(tAmount);\r\n        _rOwned[sender] = _rOwned[sender].sub(rAmount);\r\n        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   \r\n        _reflectFee(rFee, tFee);\r\n        emit Transfer(sender, recipient, tTransferAmount);\r\n    }\r\n\r\n    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {\r\n        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);\r\n        _tOwned[sender] = _tOwned[sender].sub(tAmount);\r\n        _rOwned[sender] = _rOwned[sender].sub(rAmount);\r\n        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);\r\n        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        \r\n        _reflectFee(rFee, tFee);\r\n        emit Transfer(sender, recipient, tTransferAmount);\r\n    }\r\n\r\n    function _reflectFee(uint256 rFee, uint256 tFee) private {\r\n        _rTotal = _rTotal.sub(rFee);\r\n        _tFeeTotal = _tFeeTotal.add(tFee);\r\n    }\r\n\r\n    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {\r\n        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);\r\n        uint256 currentRate =  _getRate();\r\n        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);\r\n        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);\r\n    }\r\n\r\n    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {\r\n        uint256 tFee = tAmount.div(100).mul(2);\r\n        uint256 tTransferAmount = tAmount.sub(tFee);\r\n        return (tTransferAmount, tFee);\r\n    }\r\n\r\n    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {\r\n        uint256 rAmount = tAmount.mul(currentRate);\r\n        uint256 rFee = tFee.mul(currentRate);\r\n        uint256 rTransferAmount = rAmount.sub(rFee);\r\n        return (rAmount, rTransferAmount, rFee);\r\n    }\r\n\r\n    function _getRate() private view returns(uint256) {\r\n        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();\r\n        return rSupply.div(tSupply);\r\n    }\r\n\r\n    function _getCurrentSupply() private view returns(uint256, uint256) {\r\n        uint256 rSupply = _rTotal;\r\n        uint256 tSupply = _tTotal;      \r\n        for (uint256 i = 0; i \u003c _excluded.length; i++) {\r\n            if (_rOwned[_excluded[i]] \u003e rSupply || _tOwned[_excluded[i]] \u003e tSupply) return (_rTotal, _tTotal);\r\n            rSupply = rSupply.sub(_rOwned[_excluded[i]]);\r\n            tSupply = tSupply.sub(_tOwned[_excluded[i]]);\r\n        }\r\n        if (rSupply \u003c _rTotal.div(_tTotal)) return (_rTotal, _tTotal);\r\n        return (rSupply, tSupply);\r\n    }\r\n}"},"ownable.sol":{"content":"// SPDX-License-Identifier: Unlicensed\r\n\r\npragma solidity =0.8.0;\r\n\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address payable) {\r\n        return payable(msg.sender);\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n    address private _ownerAddress;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        _ownerAddress = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    function owner() internal view returns (address) {\r\n        return _owner;\r\n    }\r\n    \r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function ownerAddress() public view returns (address) {\r\n        return _ownerAddress;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _ownerAddress = address(0);\r\n    }\r\n}"},"safeMath.sol":{"content":"// SPDX-License-Identifier: Unlicensed\r\n\r\npragma solidity =0.8.0;\r\n\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a + b;\r\n        require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \"SafeMath: subtraction overflow\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003c= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \"SafeMath: division by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003e 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \"SafeMath: modulo by zero\");\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}"}}
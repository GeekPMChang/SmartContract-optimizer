{{
  "language": "Solidity",
  "sources": {
    "./contracts/governance/VoteAggregator.sol": {
      "content": "// SPDX-License-Identifier: AGPLv3\npragma solidity 0.8.4;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/ERC20.sol\";\nimport \"../common/Constants.sol\";\n\ninterface IGROVesting {\n    function vestedBalance(address account) external view returns (uint256);\n\n    function vestingBalance(address account) external view returns (uint256);\n}\n\ninterface IGROBaseVesting {\n    function totalBalance(address account) external view returns (uint256);\n\n    function vestedBalance(address account) external view returns (uint256 vested, uint256 available);\n}\n\nstruct UserInfo {\n    uint256 amount;\n    int256 rewardDebt;\n}\n\ninterface IGROStaker {\n    function userInfo(uint256 poolId, address account) external view returns (UserInfo memory);\n}\n\ninterface IGROStakerMigration {\n    function userMigrated(address account, uint256 poolId) external view returns (bool);\n}\n\ninterface IUniswapV2Pool {\n    function token0() external view returns (address);\n\n    function token1() external view returns (address);\n\n    function balanceOf(address account) external view returns (uint256);\n\n    function totalSupply() external view returns (uint256);\n\n    function getReserves()\n        external\n        view\n        returns (\n            uint112 _reserve0,\n            uint112 _reserve1,\n            uint32 _blockTimestampLast\n        );\n}\n\ninterface IBalanceVault {\n    function getPoolTokens(bytes32 poolId)\n        external\n        view\n        returns (\n            address[] memory tokens,\n            uint256[] memory balances,\n            uint256 lastChangeBlock\n        );\n}\n\ninterface IBalanceV2Pool {\n    function getVault() external view returns (IBalanceVault);\n\n    function getPoolId() external view returns (bytes32);\n\n    function balanceOf(address account) external view returns (uint256);\n\n    function totalSupply() external view returns (uint256);\n}\n\ncontract VoteAggregator is Ownable, Constants {\n    IERC20 public immutable GRO;\n    IGROVesting public mainVesting;\n    IGROBaseVesting public empVesting;\n    IGROBaseVesting public invVesting;\n    address public stakerOld;\n    address public stakerNew;\n\n    // Make 0 pool in staker for single gro always\n    uint256 public constant SINGLE_GRO_POOL_ID = 0;\n\n    IUniswapV2Pool[] public uniV2Pools;\n    IBalanceV2Pool[] public balV2Pools;\n\n    // weight decimals is 4\n    uint256 public groWeight;\n    mapping(address => uint256[2]) public vestingWeights;\n    mapping(address => uint256[]) public lpWeights;\n\n    mapping(address => uint256) public groPools;\n\n    event LogSetGroWeight(uint256 newWeight);\n    event LogSetVestingWeight(address indexed vesting, uint256 newLockedWeight, uint256 newUnlockedWeight);\n    event LogAddUniV2Pool(address pool, uint256[] weights, uint256 groPoolId);\n    event LogRemoveUniV2Pool(address pool);\n    event LogAddBalV2Pool(address pool, uint256[] weights, uint256 groPoolId);\n    event LogRemoveBalV2Pool(address pool);\n    event LogSetLPPool(address indexed pool, uint256[] weights, uint256 groPoolId);\n\n    event LogSetMainVesting(address newVesting);\n    event LogSetInvVesting(address newVesting);\n    event LogSetEmpVesting(address newVesting);\n    event LogSetOldStaker(address staker);\n    event LogSetNewStaker(address staker);\n\n    constructor(\n        address _gro,\n        address _mainVesting,\n        address _empVesting,\n        address _invVesting,\n        address _stakerOld,\n        address _stakerNew\n    ) {\n        GRO = IERC20(_gro);\n        mainVesting = IGROVesting(_mainVesting);\n        empVesting = IGROBaseVesting(_empVesting);\n        invVesting = IGROBaseVesting(_invVesting);\n        stakerOld = _stakerOld;\n        stakerNew = _stakerNew;\n    }\n\n    function setMainVesting(address newVesting) external onlyOwner {\n        mainVesting = IGROVesting(newVesting);\n        emit LogSetMainVesting(newVesting);\n    }\n\n    function setInvVesting(address newVesting) external onlyOwner {\n        invVesting = IGROBaseVesting(newVesting);\n        emit LogSetInvVesting(newVesting);\n    }\n\n    function setEmpVesting(address newVesting) external onlyOwner {\n        empVesting = IGROBaseVesting(newVesting);\n        emit LogSetEmpVesting(newVesting);\n    }\n\n    function setOldStaker(address staker) external onlyOwner {\n        stakerOld = staker;\n        emit LogSetOldStaker(staker);\n    }\n\n    function setNewStaker(address staker) external onlyOwner {\n        stakerNew = staker;\n        emit LogSetNewStaker(staker);\n    }\n\n    function setGroWeight(uint256 weight) external onlyOwner {\n        groWeight = weight;\n        emit LogSetGroWeight(weight);\n    }\n\n    function setVestingWeight(\n        address vesting,\n        uint256 lockedWeight,\n        uint256 unlockedWeight\n    ) external onlyOwner {\n        vestingWeights[vesting][0] = lockedWeight;\n        vestingWeights[vesting][1] = unlockedWeight;\n        emit LogSetVestingWeight(vesting, lockedWeight, unlockedWeight);\n    }\n\n    function addUniV2Pool(\n        address pool,\n        uint256[] calldata weights,\n        uint256 groPoolId\n    ) external onlyOwner {\n        lpWeights[pool] = weights;\n        groPools[pool] = groPoolId;\n        uniV2Pools.push(IUniswapV2Pool(pool));\n        emit LogAddUniV2Pool(pool, weights, groPoolId);\n    }\n\n    function removeUniV2Pool(address pool) external onlyOwner {\n        uint256 len = uniV2Pools.length;\n        bool find;\n        for (uint256 i = 0; i < len - 1; i++) {\n            if (find) {\n                uniV2Pools[i] = uniV2Pools[i + 1];\n            } else {\n                if (pool == address(uniV2Pools[i])) {\n                    find = true;\n                    uniV2Pools[i] = uniV2Pools[i + 1];\n                }\n            }\n        }\n        uniV2Pools.pop();\n        delete lpWeights[pool];\n        delete groPools[pool];\n        emit LogRemoveUniV2Pool(pool);\n    }\n\n    function addBalV2Pool(\n        address pool,\n        uint256[] calldata weights,\n        uint256 groPoolId\n    ) external onlyOwner {\n        lpWeights[pool] = weights;\n        groPools[pool] = groPoolId;\n        balV2Pools.push(IBalanceV2Pool(pool));\n        emit LogAddBalV2Pool(pool, weights, groPoolId);\n    }\n\n    function removeBalV2Pool(address pool) external onlyOwner {\n        uint256 len = balV2Pools.length;\n        bool find;\n        for (uint256 i = 0; i < len - 1; i++) {\n            if (find) {\n                balV2Pools[i] = balV2Pools[i + 1];\n            } else {\n                if (pool == address(balV2Pools[i])) {\n                    find = true;\n                    balV2Pools[i] = balV2Pools[i + 1];\n                }\n            }\n        }\n        balV2Pools.pop();\n        delete lpWeights[pool];\n        delete groPools[pool];\n        emit LogRemoveBalV2Pool(pool);\n    }\n\n    function setLPPool(\n        address pool,\n        uint256[] calldata weights,\n        uint256 groPoolId\n    ) external onlyOwner {\n        if (weights.length > 0) {\n            lpWeights[pool] = weights;\n        }\n        if (groPoolId > 0) {\n            groPools[pool] = groPoolId;\n        }\n        emit LogSetLPPool(pool, weights, groPoolId);\n    }\n\n    function balanceOf(address account) external view returns (uint256 value) {\n        // calculate gro weight amount\n\n        uint256 amount = GRO.balanceOf(account);\n        amount += getLPAmountInStaker(SINGLE_GRO_POOL_ID, account);\n        value = (amount * groWeight) / PERCENTAGE_DECIMAL_FACTOR;\n\n        // calculate vesting weight amount\n\n        // vestings[0] - main vesting address\n        // vestings[1] - employee vesting address\n        // vestings[2] - investor vesting address\n        address[3] memory vestings;\n        // amounts[0][0] - main vesting locked amount\n        // amounts[0][1] - main vesting unlocked amount\n        // amounts[1][0] - employee vesting locked amount\n        // amounts[1][1] - employee vesting unlocked amount\n        // amounts[2][0] - investor vesting locked amount\n        // amounts[2][1] - investor vesting unlocked amount\n        uint256[2][3] memory amounts;\n\n        vestings[0] = address(mainVesting);\n        amounts[0][0] = mainVesting.vestingBalance(account);\n        amounts[0][1] = mainVesting.vestedBalance(account);\n\n        uint256 totalUnlocked;\n        amounts[1][0] = empVesting.totalBalance(account);\n        if (amounts[1][0] > 0) {\n            (totalUnlocked, amounts[1][1]) = empVesting.vestedBalance(account);\n            amounts[1][0] = amounts[1][0] - totalUnlocked;\n            vestings[1] = address(empVesting);\n        }\n\n        amounts[2][0] = invVesting.totalBalance(account);\n        if (amounts[2][0] > 0) {\n            (totalUnlocked, amounts[2][1]) = invVesting.vestedBalance(account);\n            amounts[2][0] = amounts[2][0] - totalUnlocked;\n            vestings[2] = address(invVesting);\n        }\n\n        for (uint256 i = 0; i < vestings.length; i++) {\n            if (amounts[i][0] > 0 || amounts[i][1] > 0) {\n                uint256[2] storage weights = vestingWeights[vestings[i]];\n                uint256 lockedWeight = weights[0];\n                uint256 unlockedWeight = weights[1];\n                value += (amounts[i][0] * lockedWeight + amounts[i][1] * unlockedWeight) / PERCENTAGE_DECIMAL_FACTOR;\n            }\n        }\n\n        value += calculateUniWeight(account);\n        value += calculateBalWeight(account);\n    }\n\n    function calculateUniWeight(address account) public view returns (uint256 uniValue) {\n        uint256 len = uniV2Pools.length;\n        for (uint256 i = 0; i < len; i++) {\n            IUniswapV2Pool pool = uniV2Pools[i];\n            uint256 lpAmount = pool.balanceOf(account);\n            lpAmount += getLPAmountInStaker(address(pool), account);\n\n            if (lpAmount > 0) {\n                (uint112 res0, uint112 res1, ) = pool.getReserves();\n                uint256 ts = pool.totalSupply();\n                uint256[] memory amounts = new uint256[](2);\n                amounts[0] = res0;\n                amounts[1] = res1;\n                address[] memory tokens = new address[](2);\n                tokens[0] = pool.token0();\n                tokens[1] = pool.token1();\n                uint256[] memory weights = lpWeights[address(pool)];\n\n                uniValue += calculateLPWeightValue(amounts, lpAmount, ts, tokens, weights);\n            }\n        }\n    }\n\n    function calculateBalWeight(address account) public view returns (uint256 balValue) {\n        uint256 len = balV2Pools.length;\n        for (uint256 i = 0; i < len; i++) {\n            IBalanceV2Pool pool = balV2Pools[i];\n            uint256 lpAmount = pool.balanceOf(account);\n            lpAmount += getLPAmountInStaker(address(pool), account);\n\n            if (lpAmount > 0) {\n                IBalanceVault vault = pool.getVault();\n                bytes32 poolId = pool.getPoolId();\n                (address[] memory tokens, uint256[] memory balances, ) = vault.getPoolTokens(poolId);\n                uint256 ts = pool.totalSupply();\n                uint256[] memory weights = lpWeights[address(pool)];\n\n                balValue += calculateLPWeightValue(balances, lpAmount, ts, tokens, weights);\n            }\n        }\n    }\n\n    function getUniV2Pools() external view returns (IUniswapV2Pool[] memory) {\n        return uniV2Pools;\n    }\n\n    function getBalV2Pools() external view returns (IBalanceV2Pool[] memory) {\n        return balV2Pools;\n    }\n\n    function getVestingWeights(address vesting) external view returns (uint256[2] memory) {\n        return vestingWeights[vesting];\n    }\n\n    function getLPWeights(address pool) external view returns (uint256[] memory) {\n        return lpWeights[pool];\n    }\n\n    function getLPAmountInStaker(address lpPool, address account) private view returns (uint256 amount) {\n        uint256 poolId = groPools[lpPool];\n        if (poolId > 0) {\n            amount = getLPAmountInStaker(poolId, account);\n        }\n    }\n\n    function getLPAmountInStaker(uint256 poolId, address account) private view returns (uint256 amount) {\n        UserInfo memory ui = IGROStaker(stakerNew).userInfo(poolId, account);\n        amount = ui.amount;\n        if (stakerOld != address(0) && !IGROStakerMigration(stakerNew).userMigrated(account, poolId)) {\n            ui = IGROStaker(stakerOld).userInfo(poolId, account);\n            amount += ui.amount;\n        }\n    }\n\n    function calculateLPWeightValue(\n        uint256[] memory tokenAmounts,\n        uint256 lpAmount,\n        uint256 lpTotalSupply,\n        address[] memory tokens,\n        uint256[] memory weights\n    ) private view returns (uint256 value) {\n        for (uint256 i = 0; i < tokenAmounts.length; i++) {\n            uint256 amount = (tokenAmounts[i] * lpAmount) / lpTotalSupply;\n            uint256 decimals = ERC20(tokens[i]).decimals();\n            uint256 weight = weights[i];\n\n            value += (amount * weight * DEFAULT_DECIMALS_FACTOR) / (uint256(10)**decimals) / PERCENTAGE_DECIMAL_FACTOR;\n        }\n    }\n}\n"
    },
    "./contracts/common/Constants.sol": {
      "content": "// SPDX-License-Identifier: AGPLv3\npragma solidity 0.8.4;\n\ncontract Constants {\n    uint8 internal constant N_COINS = 3;\n    uint8 internal constant DEFAULT_DECIMALS = 18; // GToken and Controller use this decimals\n    uint256 internal constant DEFAULT_DECIMALS_FACTOR = uint256(10)**DEFAULT_DECIMALS;\n    uint8 internal constant CHAINLINK_PRICE_DECIMALS = 8;\n    uint256 internal constant CHAINLINK_PRICE_DECIMAL_FACTOR = uint256(10)**CHAINLINK_PRICE_DECIMALS;\n    uint8 internal constant PERCENTAGE_DECIMALS = 4;\n    uint256 internal constant PERCENTAGE_DECIMAL_FACTOR = uint256(10)**PERCENTAGE_DECIMALS;\n    uint256 internal constant CURVE_RATIO_DECIMALS = 6;\n    uint256 internal constant CURVE_RATIO_DECIMALS_FACTOR = uint256(10)**CURVE_RATIO_DECIMALS;\n    uint256 internal constant ONE_YEAR_SECONDS = 31556952; // average year (including leap years) in seconds\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/ERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\nimport \"./extensions/IERC20Metadata.sol\";\nimport \"../../utils/Context.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\n * instead returning `false` on failure. This behavior is nonetheless\n * conventional and does not conflict with the expectations of ERC20\n * applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn't required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20, IERC20Metadata {\n    mapping(address => uint256) private _balances;\n\n    mapping(address => mapping(address => uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}.\n     *\n     * The default value of {decimals} is 18. To select a different value for\n     * {decimals} you should overload it.\n     *\n     * All two of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless this function is\n     * overridden;\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * Requirements:\n     *\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``sender``'s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance >= amount, \"ERC20: transfer amount exceeds allowance\");\n        unchecked {\n            _approve(sender, _msgSender(), currentAllowance - amount);\n        }\n\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\n        require(currentAllowance >= subtractedValue, \"ERC20: decreased allowance below zero\");\n        unchecked {\n            _approve(_msgSender(), spender, currentAllowance - subtractedValue);\n        }\n\n        return true;\n    }\n\n    /**\n     * @dev Moves `amount` of tokens from `sender` to `recipient`.\n     *\n     * This internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(sender, recipient, amount);\n\n        uint256 senderBalance = _balances[sender];\n        require(senderBalance >= amount, \"ERC20: transfer amount exceeds balance\");\n        unchecked {\n            _balances[sender] = senderBalance - amount;\n        }\n        _balances[recipient] += amount;\n\n        emit Transfer(sender, recipient, amount);\n\n        _afterTokenTransfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply += amount;\n        _balances[account] += amount;\n        emit Transfer(address(0), account, amount);\n\n        _afterTokenTransfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        uint256 accountBalance = _balances[account];\n        require(accountBalance >= amount, \"ERC20: burn amount exceeds balance\");\n        unchecked {\n            _balances[account] = accountBalance - amount;\n        }\n        _totalSupply -= amount;\n\n        emit Transfer(account, address(0), amount);\n\n        _afterTokenTransfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(\n        address owner,\n        address spender,\n        uint256 amount\n    ) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens\n     * will be transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal virtual {}\n\n    /**\n     * @dev Hook that is called after any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens\n     * has been transferred to `to`.\n     * - when `from` is zero, `amount` tokens have been minted for `to`.\n     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _afterTokenTransfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal virtual {}\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}